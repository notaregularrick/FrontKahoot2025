import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  SecureStorageService._internal();

  static final SecureStorageService instance =
      SecureStorageService._internal();

  Future<void> saveToken(String? token) async {
    if(token!=null) await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<void> saveGeminiApiKey(String key) async {
    await _storage.write(key: 'gemini_api_key', value: key);
  }

  Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: 'gemini_api_key');
  }

  Future<void> deleteGeminiApiKey() async {
    await _storage.delete(key: 'gemini_api_key');
  }
}
