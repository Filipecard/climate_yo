import 'package:dio/dio.dart';

class RequestDataBase {
  String baseUrl = 'http://localhost:3000/data';

  Future<Response> getData() async {
    try {
      return await Dio().get(baseUrl);
    } catch (e) {
      return responseError();
    }
  }

  Future<Response> postData(
      String cidade, String estado, dynamic jsonData) async {
    try {
      cidade = cidade.toLowerCase();
      estado = estado.toLowerCase();
      return await Dio().post('$baseUrl/$cidade./$estado', data: jsonData);
    } catch (e) {
      return responseError();
    }
  }

  Future<Response> deleteData(
      String cidade, String estado, dynamic jsonData) async {
    try {
      cidade = cidade.toLowerCase();
      estado = estado.toLowerCase();
      return await Dio().delete('$baseUrl/$cidade./$estado');
    } catch (e) {
      return responseError();
    }
  }

  Response responseError() {
    return Response(
        statusCode: 400, requestOptions: RequestOptions(path: baseUrl));
  }
}
