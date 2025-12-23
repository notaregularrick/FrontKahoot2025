import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontkahoot2526/core/exceptions/app_exception.dart';
import 'package:frontkahoot2526/features/games/multiplayer/presentation/providers/multiplayer_game_notifier.dart';
import 'package:frontkahoot2526/features/library/presentation/models/library_colors.dart';
import 'package:go_router/go_router.dart';

class JoinGameScreen extends ConsumerStatefulWidget {
  const JoinGameScreen({super.key});

  @override
  ConsumerState<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends ConsumerState<JoinGameScreen> {
  final _pinController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(multiplayerGameNotifierProvider);
    final bool isLoading = stateAsync.isLoading;

    ref.listen(multiplayerGameNotifierProvider, (previous, next) {
      if (next is AsyncError) {
        //valor de error que puede tener el AsyncValue
        String errorMessage = 'Ocurrió un error inesperado';
        if (next.error is AppException) {
          errorMessage = (next.error as AppException).message;
        } else {
          errorMessage = next.error.toString();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primaryRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (next is AsyncData && !next.isLoading && !next.hasError) {
        if (next.value?.myPlayerId != null) {
          context.go('/game');
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Unirse a un juego"),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.sports_esports,
                  size: 80,
                  color: AppColors.primaryRed.withValues(alpha: 0.8),
                ),
                const SizedBox(height: 10),
                Text(
                  "¡Únete a jugar!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 40),

                //PIN
                _buildLabel("PIN del Juego (6 dígitos)"),
                TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueText,
                  ),
                  textAlign: TextAlign.center,
                  decoration: _buildInputDecoration(hint: "Ej: 123456"),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingresa el PIN';
                    if (value.length != 6)
                      return 'PIN inválido (deben ser 6 dígitos)';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                //Nickname
                _buildLabel("Nickname"),
                TextFormField(
                  controller: _nicknameController,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlueText,
                  ),
                  textAlign: TextAlign.center,
                  decoration: _buildInputDecoration(
                    hint: "Tu nickname cool aquí",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa tu nickname';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                //Botón para unirse
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "UNIRSE",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                //QR sin implementar aún
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () {
                    //mensaje de que aún no está implementado
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Escáner QR próximamente :D"),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.darkBlueText,
                  ),
                  label: Text(
                    "Escanear código QR",
                    style: TextStyle(
                      color: AppColors.darkBlueText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      ref
          .read(multiplayerGameNotifierProvider.notifier)
          .joinGame(
            _pinController.text.trim(),
            _nicknameController.text.trim(),
          );
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.darkBlueText.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }
}
