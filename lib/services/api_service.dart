import 'package:dio/dio.dart';
import '../env/app_env.dart';

class ApiService {
  final Dio _dio;
  ApiService({String? token})
      : _dio = Dio(BaseOptions(
    baseUrl: '${AppEnv.apiBaseUrl}/api',
    headers: token != null ? {'Authorization': 'Bearer $token'} : null,
  ));

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<void> logout() async {
    await _dio.post('/logout');
  }

  Future<List<dynamic>> fetchItineraries() async {
    final response = await _dio.get('/designated-itineraries');
    return response.data['data'];
  }

  Future<List<dynamic>> fetchTodayItineraries() async {
    final response = await _dio.get('/designated-itineraries/for-today');
    return response.data;
  }

  Future<Map<String, dynamic>> fetchPlaceDetails(int itineraryId, int placeId, String date) async {
    final response = await _dio.get('/designated-itineraries/$itineraryId/places/$placeId/date/$date');
    return response.data;
  }
}
