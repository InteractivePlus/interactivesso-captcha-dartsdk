import 'dart:convert';

import 'package:http/http.dart' as http;

class CaptchaAPIError{
  final int errorCode;
  final String? errorDescription;
  CaptchaAPIError({
    required this.errorCode,
    this.errorDescription
  });
  @override
  String toString() => 'CaptchaAPIError[errCode=' + errorCode.toString() + (errorDescription != null ? ',errorDescription=' + errorDescription! : '') + ']';
}

CaptchaAPIError _errTransferMap_ZH(int? errorCode) {
  switch(errorCode){
    case 2: 
      return CaptchaAPIError(errorCode: 2, errorDescription: "验证码不存在");
    case 14:
      return CaptchaAPIError(errorCode: 14, errorDescription: "验证码或通信密钥不正确");
    case 20:
      return CaptchaAPIError(errorCode: 14, errorDescription: "参数错误");
    case 1:
    default:
      return CaptchaAPIError(errorCode: 1, errorDescription: "未知内部错误");
  }
}

CaptchaAPIError _errTransferMap_EN(int? errorCode) {
  switch(errorCode){
    case 2: 
      return CaptchaAPIError(errorCode: 2, errorDescription: "Captcha non-existant");
    case 14:
      return CaptchaAPIError(errorCode: 14, errorDescription: "Phrase is incorrect");
    case 20:
      return CaptchaAPIError(errorCode: 14, errorDescription: "Parameter Error");
    case 1:
    default:
      return CaptchaAPIError(errorCode: 1, errorDescription: "Unknown Inner Error");
  }
}

const defaultAPIUrl = 'https://sso-captcha.interactiveplus.org';

class APIReturnData<T>{
  final int errorCode;
  final T? data;
  APIReturnData({
    required this.errorCode,
    this.data
  });
  static APIReturnData<T> fromJson<T,TSerialized>(Map<String,dynamic> json, T Function(TSerialized dataSerialized) convertDataFunc) => APIReturnData(
    errorCode: json['errorCode'] as int,
    data: json['data'] == null ? null : convertDataFunc(json['data'])
  );
  @override
  String toString() => 'APIReturnData<${T.toString()}>[errorCode=${errorCode.toString()}' + (data != null ? ',data=' + data.toString() : '') + ']';
}

class CaptchaData{
  final int width;
  final int height;
  final String jpegBase64;
  final int phraseLen;
  List<int> get jpegData => base64.decode(jpegBase64);
  CaptchaData({
    required this.width,
    required this.height,
    required this.jpegBase64,
    required this.phraseLen
  });
  factory CaptchaData.fromJson(Map<String,dynamic> json) => CaptchaData(
    width: json['width'] as int, 
    height: json['height'] as int, 
    jpegBase64: json['jpegBase64'] as String, 
    phraseLen: json['phraseLen'] as int
  );
  Map<String,dynamic> toJson(){
    return {
      'width': width,
      'height': height,
      'jpegBase64': jpegBase64,
      'phraseLen': phraseLen
    };
  }
  @override
  String toString() => 'CaptchaData[width=$width,height=$height,jpegBase64:$jpegBase64,phraseLen:$phraseLen]';
}

class CaptchaInfo{
  final String captchaId;
  final int expireTime;
  final CaptchaData captchaData;
  CaptchaInfo({
    required this.captchaId,
    required this.expireTime,
    required this.captchaData
  });
  factory CaptchaInfo.fromJson(Map<String,dynamic> json) => CaptchaInfo(
    captchaId: json['captcha_id'] as String, 
    expireTime: json['expire_time'] as int, 
    captchaData: CaptchaData.fromJson(json['captcha_data'])
  );
  
  Map<String,dynamic> toJson() => {
    'captcha_id' : captchaId,
    'expire_time': expireTime,
    'captcha_data': captchaData
  };
  @override
  String toString()=> 'CaptchaInfo[captchaId=$captchaId,expireTime=$expireTime,captchaData=${captchaData.toString()}]';
}

class CheckCaptchaStatusInfo{
  final String scope;
  CheckCaptchaStatusInfo({
    required this.scope
  });
  factory CheckCaptchaStatusInfo.fromJson(Map<String,dynamic> json) => CheckCaptchaStatusInfo(
    scope: json['scope'] as String
  );
  Map<String,dynamic> toJson() => {
    'scope': scope
  };
  @override
  String toString() => 'CheckCaptchaStatusInfo[scope=$scope]';
}

class SSOCaptchaServerSDK{
  late String _serverUrl;
  String get serverUrl => _serverUrl;
  set serverUrl(String value){
    if(value.endsWith('/')){
      _serverUrl = value.substring(0,value.length - 1);
    }else{
      _serverUrl = value;
    }
  }
  SSOCaptchaServerSDK({String serverUrl = defaultAPIUrl}){
    this.serverUrl = serverUrl;
  }
  Future<CaptchaInfo> getCaptcha(String scope, [String lang = 'en']) async {
    final errTransferFunc = lang == 'zh' ? _errTransferMap_ZH : _errTransferMap_EN;
    var httpResponse = await http.get(
      Uri.parse(serverUrl + '/captcha?scope=' + Uri.encodeComponent(scope))
    );
    late dynamic decodedResponseMap;
    
    try{
      decodedResponseMap = json.decode(httpResponse.body);
    }catch(e){
      throw errTransferFunc(1);
    }

    if(decodedResponseMap is! Map<String,dynamic>){
      throw errTransferFunc(1);
    }
    late APIReturnData<CaptchaInfo> decodedResponse;

    try{
      decodedResponse = APIReturnData.fromJson(decodedResponseMap, CaptchaInfo.fromJson);
    }catch(e){
      throw errTransferFunc(1);
    }

    if (decodedResponse.errorCode != 0 || httpResponse.statusCode != 201 || decodedResponse.data == null) {
      throw errTransferFunc(1);
    }else{
      return decodedResponse.data!;
    }
  }
  Future<void> submitCaptcha(String captchaId, String phrase, [String lang = 'en']) async {
    final errTransferFunc = lang == 'zh' ? _errTransferMap_ZH : _errTransferMap_EN;
    var httpResponse = await http.get(
      Uri.parse(serverUrl + '/captcha/' + Uri.encodeComponent(captchaId) + '/submitResult?phrase=' + Uri.encodeComponent(phrase))
    );

    if (httpResponse.statusCode != 200) {
      if(httpResponse.body.isEmpty){
        throw errTransferFunc(1);
      }else{
        late dynamic decodedResponseMap;
        try{
          decodedResponseMap = json.decode(httpResponse.body);
        }catch(e){
          throw errTransferFunc(1);
        }

        if(decodedResponseMap is! Map<String,dynamic>){
          throw errTransferFunc(1);
        }
        late APIReturnData<CaptchaInfo> decodedResponse;

        try{
          decodedResponse = APIReturnData.fromJson(decodedResponseMap, CaptchaInfo.fromJson);
        }catch(e){
          throw errTransferFunc(1);
        }

        throw errTransferFunc(decodedResponse.errorCode);
      }
    }else{
      return;
    }
  }
  Future<CheckCaptchaStatusInfo> getSubmitStatus(String captchaId, String secretPhrase, [String lang = 'en']) async{
    final errTransferFunc = lang == 'zh' ? _errTransferMap_ZH : _errTransferMap_EN;
    var httpResponse = await http.get(
      Uri.parse(serverUrl + '/captcha/' + Uri.encodeComponent(captchaId) + '/submitStatus?secret_phrase=' + Uri.encodeComponent(secretPhrase))
    );
    late dynamic decodedResponseMap;
    
    try{
      decodedResponseMap = json.decode(httpResponse.body);
    }catch(e){
      throw errTransferFunc(1);
    }

    if(decodedResponseMap is! Map<String,dynamic>){
      throw errTransferFunc(1);
    }
    late APIReturnData<CheckCaptchaStatusInfo> decodedResponse;

    try{
      decodedResponse = APIReturnData.fromJson(decodedResponseMap, CheckCaptchaStatusInfo.fromJson);
    }catch(e){
      throw errTransferFunc(1);
    }
    if(httpResponse.statusCode != 200 || decodedResponse.errorCode != 0){
      throw errTransferFunc(decodedResponse.errorCode);
    }else if(decodedResponse.data == null){
      throw errTransferFunc(1);
    }else{
      return decodedResponse.data!;
    }
  }
}