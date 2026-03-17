import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService {

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        "Content-Type": "application/json"
      },
    ),
  );

  /*
  PUBLIC POST — no token (register, login)
  */
  Future<Response> post(String endpoint, Map data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Something went wrong";
    }
  }

  /*
  AUTHENTICATED POST — with token (items, suggestions)
  */
  Future<Response> authPost(String endpoint, Map data) async {
    try {
      String? token = await StorageService.getToken();
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Something went wrong";
    }
  }

  /*
  GET — with token
  */
  Future<Response> get(String endpoint) async {
    try {
      String? token = await StorageService.getToken();
      return await _dio.get(
        endpoint,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Something went wrong";
    }
  }

  /*
  PUT — with token
  */
  Future<Response> put(String endpoint, Map data) async {
    try {
      String? token = await StorageService.getToken();
      return await _dio.put(
        endpoint,
        data: data,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Something went wrong";
    }
  }

  /*
  DELETE — with token
  */
  Future<Response> delete(String endpoint) async {
    try {
      String? token = await StorageService.getToken();
      return await _dio.delete(
        endpoint,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Something went wrong";
    }
  }

}