import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/generated/json/base/json_convert_content.dart';

class HttpRequest {
  static final Dio dio = Dio();

  static Future<T> request<T>(String url, {String method = "get", Map<String, dynamic> params}) async {
    final options = Options(method: method);
    //处理https证书
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // 验证证书
        //if(cert.pem==PEM){
        //  return true;
        //}
        return true;
      };
    };
    try {
      Response response = await dio.request(url, queryParameters: params, options: options);
      return JsonConvert.fromJsonAsT<T>(response.data);
    } on DioError catch (e) {
      return Future.error(e);
    }
  }
}
