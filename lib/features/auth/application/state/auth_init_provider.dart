import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_initializer.dart';

final authInitProvider = FutureProvider<void>((ref) async {
  final initializer = AuthInitializer(ref);
  await initializer.init();
});
