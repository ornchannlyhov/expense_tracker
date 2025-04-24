// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class AuthService with ChangeNotifier {
  final Dio _dio = getDioInstance();
  final FlutterSecureStorage _storage = getSecureStorageInstance();

  User? _user;
  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthService() {
    tryAutoLogin();
  }

  void _setState({bool loading = false, String? error}) {
    _isLoading = loading;
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _setState(loading: true, error: null);
    try {
      final response = await _dio.post('/auth/login',
          data: {'username': username, 'password': password});

      if (response.statusCode == 200 &&
          response.data?['token'] != null &&
          response.data?['user'] != null) {
        _token = response.data['token'];
        _user = User.fromJson(response.data['user']);
        await _storage.write(key: kAuthTokenKey, value: _token);
        _isAuthenticated = true;
        _setState(loading: false);
        notifyListeners();
        return true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data?['message'] ?? "Invalid response from server",
        );
      }
    } catch (e) {
      await _handleAuthError(e, "Login failed");
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    _setState(loading: true, error: null);
    try {
      final response = await _dio.post('/auth/register',
          data: {'username': username, 'email': email, 'password': password});

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Auto login after successful registration
        final loggedIn = await login(username, password);
        if (loggedIn) {
          return true;
        } else {
          throw DioException(
              message: "Login after registration failed",
              requestOptions: response.requestOptions);
        }
      } else {
        throw DioException(
            requestOptions: response.requestOptions, response: response);
      }
    } catch (e) {
      await _handleAuthError(e, "Registration failed");
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();
    final storedToken = await _storage.read(key: kAuthTokenKey);
    if (storedToken == null || storedToken.isEmpty) {
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _token = storedToken;
    _isAuthenticated = true;

    try {
      final response = await _dio.get('/auth/profile');
      if (response.statusCode == 200 && response.data?['user'] != null) {
        _user = User.fromJson(response.data['user']);
      } else {
        print(
            "Warning: Could not fetch profile during auto-login. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Auto-login profile fetch failed: $e");
      if (e is DioException && e.response?.statusCode == 401) {
        await logout();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _isAuthenticated = false;
    await _storage.delete(key: kAuthTokenKey);
    notifyListeners();
  }

  Future<void> _handleAuthError(Object e, String defaultMessage) async {
    _token = null;
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
    String message = _parseDioError(e, defaultMessage);
    _setState(loading: false, error: message);
    if (e is DioException && e.response?.statusCode == 401) {
      await _storage.delete(key: kAuthTokenKey);
    }
  }

  String _parseDioError(Object e, String defaultMessage) {
    if (e is DioException) {
      if (e.response?.data != null) {
        var data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
        if (data is Map && data.containsKey('error')) {
          return data['error'].toString();
        }
        return data.toString();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Network error.';
      }
      return e.message ?? defaultMessage;
    }
    return 'An unexpected error occurred: ${e.toString()}';
  }
}
