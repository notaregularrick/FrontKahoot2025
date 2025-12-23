import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/providers/backend_provider.dart';

class ChangeBackendScreen extends ConsumerWidget {
  const ChangeBackendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escuchamos el valor actual del enum (BackendType.back1 o back2)
    final currentBackend = ref.watch(backendProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración de Backend"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta informativa superior
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Backend Activo:",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 5),
                Text(
                  currentBackend.name, // "Backend 1"
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentBackend.url, // "http://10.0.2.2..."
                  style: TextStyle(color: Colors.grey.shade700),
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
          
          // Generamos la lista de opciones basada en el Enum automáticamente
          Expanded(
            child: ListView(
              children: BackendType.values.map((type) {
                return RadioListTile<BackendType>(
                  title: Text(type.name),       // Usa el getter .name de tu extensión
                  subtitle: Text(type.url),     // Usa el getter .url de tu extensión
                  value: type,                  // El valor que representa este renglón
                  groupValue: currentBackend,   // El valor actualmente seleccionado en el provider
                  activeColor: Colors.blue,
                  onChanged: (BackendType? value) {
                    if (value != null) {
                      // Llamamos a tu función setUrl que ahora recibe un ENUM
                      ref.read(backendProvider.notifier).changeBackend(value);
                      
                      // Feedback visual opcional
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Cambiado a ${value.name}")),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}