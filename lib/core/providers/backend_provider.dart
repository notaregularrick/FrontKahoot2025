import 'package:flutter_riverpod/flutter_riverpod.dart';

// // 1. Un provider simple para acceder a SharedPreferences (ya inicializado en el main)
// final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
//   throw UnimplementedError(); // Se sobreescribe en el main.dart
// });

// 2. El Notifier que controla la URL
enum BackendType { backOmega, backAlpha }

extension BackendTypeExtension on BackendType {
  String get name {
    switch (this) {
      case BackendType.backOmega:
        return "Backend Omega";
      case BackendType.backAlpha:
        return "Backend Alpha";
    }
  }

  String get url {
    //modificar según las de los equipos
    switch (this) {
      case BackendType.backOmega:
        return "https://backcomun-mzvy.onrender.com";
      case BackendType.backAlpha:
        return "https://quizzy-backend-1-zpvc.onrender.com/api";
    }
  }
}

class BackendNotifier extends Notifier<BackendType> {
  @override
  BackendType build() {
    return BackendType.backOmega; // Valor por defecto inicial
  }

  // Función para cambiar la URL desde la UI
  void changeBackend(BackendType type) {
    state = type;

    //state = newUrl; // Esto notifica a quien escuche (Dio)

    // Guardamos para la próxima vez
    // final prefs = ref.read(sharedPrefsProvider);
    // prefs.setString('api_url', newUrl);
  }
}

// 3. El provider expuesto
final backendProvider = NotifierProvider<BackendNotifier, BackendType>(
  BackendNotifier.new,
);
