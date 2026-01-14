import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  FcmService._internal();
  static final FcmService instance = FcmService._internal();

  /// Obtiene el token FCM del dispositivo
  /// Retorna null si no se puede obtener el token
  Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      // Log del error pero no lanzamos excepción para no bloquear el flujo
      print('Error al obtener token FCM: $e');
      return null;
    }
  }
}

