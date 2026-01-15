import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FcmService._internal();
  static final FcmService instance = FcmService._internal();

  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('Token FCM: $token');
      return token;
    } catch (e) {
      print('Error al obtener token FCM: $e');
      return null;
    }
  }
}
