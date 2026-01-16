import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/backend_provider.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class ChangeBackendScreen extends ConsumerStatefulWidget {
  const ChangeBackendScreen({super.key});

  @override
  ConsumerState<ChangeBackendScreen> createState() =>
      _ChangeBackendScreenState();
}

class _ChangeBackendScreenState extends ConsumerState<ChangeBackendScreen> {
  late BackendType _pendingBackend;
  late BackendType _initialBackend;

  @override
  void initState() {
    super.initState();
    _pendingBackend = ref.read(backendProvider);
    _initialBackend = _pendingBackend;
  }

  Future<void> _saveChanges() async {
    // 1. Capturamos el notificador del backend para usarlo después de navegar
    final backendNotifier = ref.read(backendProvider.notifier);
    
    // 2. Hacemos Logout para limpiar credenciales viejas
    await ref.read(authNotifierProvider.notifier).logout();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Conectado a ${_pendingBackend.name}. Inicia sesión nuevamente.",
            style: const TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      
      // 3. Navegamos PRIMERO a una ruta pública (Inicio/Login)
      // Esto desmonta las pantallas protegidas (como ProfilePage) que podrían 
      // intentar recargar datos automáticamente y causar errores 401.
      context.go('/inicio');
      
      // 4. Cambiamos el backend después de un breve delay
      // para dar tiempo a que la navegación complete y limpie el árbol de widgets.
      Future.delayed(const Duration(milliseconds: 100), () {
        backendNotifier.changeBackend(_pendingBackend);
      });
    }
  }

  // Helper para construir los RadioListTile personalizados
  Widget _buildRadioOption(BackendType type) {
    final isSelected = _pendingBackend == type;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<BackendType>(
        title: Text(
          type.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue[800] : Colors.black87,
          ),
        ),
        subtitle: Text(
          type.url,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        value: type,
        groupValue: _pendingBackend,
        activeColor: Colors.blue[800],
        onChanged: (BackendType? value) {
          if (value != null) {
            setState(() {
              _pendingBackend = value;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuración de Backend")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta informativa
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Usando actualmente:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _initialBackend.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _initialBackend.url,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Selecciona un entorno:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),

          // Lista de Opciones
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: BackendType.values.map((type) {
                return _buildRadioOption(type);
              }).toList(),
            ),
          ),

          // --- BOTÓN DE GUARDAR ---
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveChanges,
              child: const Text(
                "GUARDAR Y APLICAR",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class ChangeBackendScreen extends ConsumerWidget {
//   const ChangeBackendScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 1. Escuchamos el valor actual del enum (BackendType.back1 o back2)
//     final currentBackend = ref.watch(backendProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Configuración de Backend"),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Tarjeta informativa superior
//           Container(
//             padding: const EdgeInsets.all(20),
//             width: double.infinity,
//             color: Colors.blue.shade50,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Backend Activo:",
//                   style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   currentBackend.name, // "Backend 1"
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   currentBackend.url,
//                   style: TextStyle(color: Colors.grey.shade700),
//                 ),
//               ],
//             ),
//           ),
          
//           const SizedBox(height: 20),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.0),
//             child: Text(
//               "Selecciona un entorno:",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//           ),
          
//           // Generamos la lista de opciones basada en el Enum automáticamente
//           Expanded(
//             child: ListView(
//               children: BackendType.values.map((type) {
//                 return RadioListTile<BackendType>(
//                   title: Text(type.name),       // Usa el getter .name de tu extensión
//                   subtitle: Text(type.url),     // Usa el getter .url de tu extensión
//                   value: type,                  // El valor que representa este renglón
//                   groupValue: currentBackend,   // El valor actualmente seleccionado en el provider
//                   activeColor: Colors.blue,
//                   onChanged: (BackendType? value) {
//                     if (value != null) {
//                       // Llamamos a tu función setUrl que ahora recibe un ENUM
//                       ref.read(backendProvider.notifier).changeBackend(value);
                      
//                       // Feedback visual opcional
//                       ScaffoldMessenger.of(context).clearSnackBars();
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Cambiado a ${value.name}")),
//                       );
//                     }
//                   },
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }