import 'dart:async';
import 'package:http/http.dart';
import 'package:wikib_utils/wikb_utils.dart';

abstract class IRetries {
  int nextMSec();
  Future delay() => Future.delayed(Duration(milliseconds: nextMSec()));
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

typedef FinishRequest = void Function(AzureRequest req);
typedef FinalizeResponse<T> = Future<ContinueResult?> Function(AzureResponse<T> resp);
enum ContinueResult { doBreak, doContinue, doWait, doRethrow }

class ErrorCodes {
  ErrorCodes._();
  static const no = 0;
  static const notFound = 404;
  static const conflict = 409;
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
      case conflict:
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

abstract class Sender<T> {
  int debugSimulateLongRequest = 0; // simulate long-time Http request
  WaitForConnectionPar? waitForConnectionPar;
  var retries = initRetries;
  Future<ContinueResult?> finalizeResponse(AzureResponse<T> resp);

  Future<AzureResponse<T>?> send(AzureRequest? request, {Future<AzureRequest?> getRequest()?}) async {
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
          final internetOK = await waitForConnection(waitForConnectionPar);
          if (debugCanceled) return null;
          if (!internetOK) {
            resp.error = ErrorCodes.noInternet;
          } else {
            assert(dpCounter('send attempts'));

            resp.response = await client.send(request.toHttpRequest());

            assert(resp.error != ErrorCodes.no || dpCounter('send_ok'));
            if (debugCanceled) return resp;
            if (debugSimulateLongRequest > 0) {
              await Future.delayed(Duration(milliseconds: debugSimulateLongRequest));
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
        final future = finalizeResponse(resp);
        final continueResult = (await future) ?? ContinueResult.doBreak;

        switch (continueResult) {
          case ContinueResult.doBreak:
            return resp;
          case ContinueResult.doContinue:
            continue;
          case ContinueResult.doWait:
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

class RetriesSimple extends IRetries {
  int baseMsec = 4000;
  @override
  int nextMSec() {
    if (baseMsec > 30000) throw Exception();
    return baseMsec *= 2;
  }
}
