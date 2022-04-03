part of 'azure.dart';

class SendPar {
  SendPar();
  SendPar.init({this.debugWriteWaitMsec, this.waitForConnectionPar, this.retries});
  int? debugWriteWaitMsec; // simulate long-time Http request
  WaitForConnectionPar? waitForConnectionPar;
  IRetries? retries;
  FinalizeResponse? finalizeResponse;
}

class AzureRequest {
  AzureRequest(this.method, this.uri);
  final headers = <String, String>{};
  Uri uri;
  String method;
  List<int>? bodyBytes;
  Request toRequest() {
    final res = Request(method, uri)..headers.addEntries(headers.entries);
    if (bodyBytes != null) res.bodyBytes = bodyBytes!;
    return res;
  }
}

typedef FinishRequest = void Function(AzureRequest req);
typedef FinalizeResponse<T> = Future<ContinueResult?> Function(AzureResponse<T> resp);
enum ContinueResult { doBreak, doContinue, doWait, doRethrow }

class AzureResponse<T> {
  // input
  StreamedResponse? response;
  late int error;
  String? errorReason;
  Exception? errorDetail;
  AzureRequest? oldRequest;

  // output
  T? result;

  ContinueResult? standardResponseProcesed() {
    switch (error) {
      case ErrorCodes.no:
        return null;
      case ErrorCodes.httpSend_errorNo:
      case ErrorCodes.bussy:
        return ContinueResult.doWait;
      default:
        return ContinueResult.doRethrow;
    }
  }
}

class ErrorCodes {
  ErrorCodes._();
  static const no = 0;
  static const notFound = 404;
  static const insertConflict = 409;
  static const eTagConflict = 412;
  static const bussy = 500;
  static const noInternet = 600;
  static const otherHttpSend = 601;
  static const otherResponseError = 602;
  static const httpSend_errorNo = 603;

// const CLIENT_SEND_ERROR = 600;
// //const DEVICE_ID_DURING_MERGE = 601;
// const NO_INTERNET = 602;
// const NO_INTERNET_MOCK = 603;

  static int fromResponse(int statusCode) {
    switch (statusCode) {
      case insertConflict:
      case notFound:
      case eTagConflict:
        return statusCode;
      case 500:
      case 503:
      case 504:
        return bussy;
      default:
        return statusCode < 400 ? 0 : otherResponseError;
    }
  }

  static void fromException(AzureResponse resp, Exception e) {
    final res = e.toString();
    final match = _regExp.firstMatch(res);
    if (match == null) {
      resp.error = otherHttpSend;
      resp.errorReason = res;
    } else {
      resp.errorReason = 'errno=${match.group(1)}';
      resp.error = httpSend_errorNo;
    }
  }
}

final _regExp = RegExp(
  r'^.*errno.*?([0-9]+).*$',
  caseSensitive: false,
  multiLine: true,
);

class Sender {
  Future<AzureResponse<T>?> send<T>(AzureRequest? request, SendPar sendPar, {Future<AzureRequest?> getRequest()?}) async {
    assert(sendPar.finalizeResponse != null);
    assert((request == null) != (getRequest == null));
    debugCanceled = false;
    final client = Client();
    try {
      while (true) {
        if (debugCanceled) return null;

        if (getRequest != null) request = await getRequest();
        if (request == null) return null;
        final resp = AzureResponse<T>()..oldRequest = request;

        try {
          final internetOK = await waitForConnection(sendPar.waitForConnectionPar);
          if (debugCanceled) return null;
          if (!internetOK) {
            resp.error = ErrorCodes.noInternet;
          } else {
            assert(dpCounter('send attempts'));

            resp.response = await client.send(request.toRequest());

            assert(resp.error != ErrorCodes.no || dpCounter('send_ok'));
            if (debugCanceled) return resp;
            if (sendPar.debugWriteWaitMsec != null) {
              await Future.delayed(Duration(milliseconds: sendPar.debugWriteWaitMsec!));
            }
            resp.error = ErrorCodes.fromResponse(resp.response!.statusCode);
            resp.errorReason = resp.response!.reasonPhrase;
          }
        } on Exception catch (e) {
          ErrorCodes.fromException(resp, e);
        }

        assert(resp.error != ErrorCodes.no || resp.response != null);
        assert(resp.error != ErrorCodes.no || dpCounter('send_ok'));
        assert(resp.error == ErrorCodes.no || (dpCounter('send_error') && dpCounter(resp.errorReason ?? resp.error.toString())));

        resp.result = null;
        final future = sendPar.finalizeResponse!(resp);
        final continueResult = (await future) ?? ContinueResult.doBreak;

        switch (continueResult) {
          case ContinueResult.doBreak:
            return resp;
          case ContinueResult.doContinue:
            continue;
          case ContinueResult.doWait:
            final retries = sendPar.retries ?? initRetries;
            await retries.delay();
            continue;
          case ContinueResult.doRethrow:
            // return Future.error(resp.errorDetail ?? resp.error);
            return Future.error(resp.error);
        }
      }
    } finally {
      client.close();
    }
  }

  static final initRetries = RetriesSimple();
  void debugCancel() => debugCanceled = true;

  var debugCanceled = false;
}

class DebugRetries extends IRetries {
  DebugRetries();
  final _random = Random();
  @override
  int nextMSec() => _random.nextInt(120000);
}
