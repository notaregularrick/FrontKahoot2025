import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateKahootScreen extends StatelessWidget {
  const CreateKahootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color redBackground = const Color(0xFFF44336);
    final Color lightGray = Colors.grey[200]!;

    final List<Map<String, dynamic>> categories = [
      {'name': 'Estudio', 'icon': Icons.school},
      {'name': 'Familia', 'icon': Icons.family_restroom},
      {'name': 'Noche de juegos', 'icon': Icons.sports_esports},
      {'name': 'Celebración', 'icon': Icons.celebration},
      {'name': 'Proyectos', 'icon': Icons.work},
      {'name': 'Calentamiento', 'icon': Icons.local_fire_department},
      {'name': 'Trivia', 'icon': Icons.quiz},
      {'name': 'De temporada', 'icon': Icons.calendar_today},
      {'name': 'Social', 'icon': Icons.people},
    ];

    return Scaffold(
      backgroundColor: redBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Título "Crear"
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Crear',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección "Crea tú mismo"
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crea tú mismo',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Card "Lienzos en blanco"
                          GestureDetector(
                            onTap: () {
                              context.go('/create-kahoot/from-scratch');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: lightGray,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Icono morado con cuadrados
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.purple[600],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 4,
                                          top: 4,
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.purple[400],
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const Positioned(
                                          right: 4,
                                          bottom: 4,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Texto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Lienzos en blanco',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Toma el control total de la creación de kahoots',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Flecha
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.grey[600],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sección "Plantillas"
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header con "Plantillas" y "Ver todos"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Plantillas',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Ver todas las plantillas
                                },
                                child: const Text(
                                  'Ver todos',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Carrusel de categorías
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Filtrar por categoría
                                    },
                                    icon: Icon(
                                      category['icon'] as IconData,
                                      size: 20,
                                    ),
                                    label: Text(category['name'] as String),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: lightGray,
                                      foregroundColor: Colors.black,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Grid de plantillas
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: 4, // Mostrar 4 plantillas de ejemplo
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: lightGray,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header de la plantilla
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Plantilla',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Área de imagen/preview (blanco)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
