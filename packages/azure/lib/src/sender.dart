part of 'azure.dart';

abstract class IRetries {
  const IRetries();
  int nextMSec();
  Future<int> delay() async {
    final msecs = nextMSec();
    if (msecs < 0) return -msecs;
    print('delayed: $msecs');
    await Future.delayed(Duration(milliseconds: msecs));
    return 0;
  }
}

class AzureRequest {
  AzureRequest(this.method, this.uri);
  final headers = <String, String>{};
  Uri uri;
  String method;
  List<int>? bodyBytes;
  Request toHttpRequest() {
    final res = Request(method, uri)..headers.addEntries(headers.entries);
    if (bodyBytes != null) res.bodyBytes = bodyBytes!;
    return res;
  }
}

class AzureResponse<T> {
  // input
  StreamedResponse? response;
  int error = ErrorCodes.no;
  String? errorReason;
  Exception? errorDetail;
  AzureRequest? oldRequest;

  // output
  T? result;
}

typedef FinishRequest = void Function(AzureRequest req);
typedef FinalizeResponse<T> = Future<ContinueResult?> Function(AzureResponse<T> resp);
enum ContinueResult { doBreak, doContinue, doWait, doRethrow }

class ErrorCodes {
  ErrorCodes._();
  static const no = 0;
  static const notFound = 404; // EntityNotFound, TableNotFound
  static const conflict = 409; // EntityAlreadyExists, TableAlreadyExists, TableBeingDeleted
  static const eTagConflict = 412; // Precondition Failed
  static const bussy = 500; // 500, 503, 504
  static const otherHttpSend = 600; // other statusCode >= 400

  static const noInternet = 601;
  static const exception1 = 602;
  static const exception2 = 603;
  static const timeout = 604;

  static int computeStatusCode(int statusCode) {
    switch (statusCode) {
      case conflict:
      case notFound:
      case eTagConflict:
        return statusCode;
      case 500:
      case 503:
      case 504:
        return bussy;
      default:
        return statusCode < 400 ? 0 : otherHttpSend;
    }
  }

  static void statusCodeToResponse(AzureResponse resp) {
    resp.error = computeStatusCode(resp.response!.statusCode);
    resp.errorReason = resp.response!.reasonPhrase;
  }

  static void exceptionToResponse(AzureResponse resp, Exception e) {
    final res = e.toString();
    final match = _regExp.firstMatch(res);
    if (match == null) {
      resp.error = exception1;
      resp.errorReason = res;
    } else {
      resp.error = exception2;
      resp.errorReason = 'errno=${match.group(1)}';
    }
  }
}

final _regExp = RegExp(
  r'^.*errno.*?([0-9]+).*$',
  caseSensitive: false,
  multiLine: true,
);

class SendPar {
  SendPar({this.retries, this.debugSimulateLongRequest = 0, this.exceptionToResponse});
  IRetries? retries;
  final int debugSimulateLongRequest; // simulate long-time Http request
  final void Function(AzureResponse resp, Exception e)? exceptionToResponse;
}

abstract class Sender {
  Future<AzureResponse<T>?> send<T>({
    AzureRequest? request,
    Future<AzureRequest?> getRequest()?,
    required FinalizeResponse<T> finalizeResponse,
    SendPar? sendPar,
  }) async {
    assert((request == null) != (getRequest == null));
    final sp = sendPar ?? SendPar();
    sp.retries ??= RetriesSimple._instance;
    _debugCanceled = false;
    final client = Client();
    AzureResponse<T>? resp;

    try {
      while (true) {
        if (_debugCanceled) return null;

        if (getRequest != null) {
          request = await getRequest();
          resp ??= AzureResponse<T>();
        } else {
          resp = AzureResponse<T>();
        }
        resp.oldRequest = request;

        if (request == null) return null;

        try {
          final internetOK = await connectedByOne4();
          if (_debugCanceled) return null;
          if (!internetOK) {
            resp.error = ErrorCodes.noInternet;
          } else {
            assert(dpCounter('send attempts'));

            resp.response = await client.send(request.toHttpRequest());
            if (_debugCanceled) return resp;

            if (sp.debugSimulateLongRequest > 0) {
              await Future.delayed(Duration(milliseconds: sp.debugSimulateLongRequest));
              if (_debugCanceled) return resp;
            }
            ErrorCodes.statusCodeToResponse(resp);
          }
        } on Exception catch (e) {
          if (!await connectedByOne4()) {
            resp.error = ErrorCodes.noInternet;
          } else {
            ErrorCodes.exceptionToResponse(resp, e);
          }
        }

        assert(resp.error != ErrorCodes.no || resp.response != null);

        assert(resp.error != ErrorCodes.no || dpCounter('send_ok'));
        assert(resp.error == ErrorCodes.no || (dpCounter('send_error') && dpCounter(resp.errorReason ?? resp.error.toString())));

        ContinueResult continueResult;
        switch (resp.error) {
          case ErrorCodes.noInternet:
          case ErrorCodes.bussy:
            continueResult = ContinueResult.doWait;
            break;
          case ErrorCodes.exception1:
          case ErrorCodes.exception2:
            continueResult = ContinueResult.doRethrow;
            break;
          default:
            continueResult = (await finalizeResponse(resp)) ?? ContinueResult.doBreak;
            break;
        }

        switch (continueResult) {
          case ContinueResult.doBreak:
            return resp;
          case ContinueResult.doContinue:
            continue; // continue due more requests (e.g. multi part query)
          case ContinueResult.doWait:
            final res = await sp.retries!.delay();
            if (res != 0) {
              resp.error = res;
              return Future.error(resp.error);
            }
            resp = null; // continue due error
            continue;
          case ContinueResult.doRethrow:
            return Future.error(resp.error);
        }
      }
    } finally {
      client.close();
    }
  }

  void debugCancel() => _debugCanceled = true;

  var _debugCanceled = false;
}

class RetriesSimple extends IRetries {
  int baseMsec = 4000;
  int maxSec = 0;
  @override
  int nextMSec() {
    if (maxSec > 0 && baseMsec > maxSec) {
      return -ErrorCodes.timeout;
    }
    return baseMsec > 30000 ? baseMsec : baseMsec *= 2;
  }

  static final _instance = RetriesSimple();
}
