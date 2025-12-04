import 'package:flutter/material.dart';

class GameTimerWidget extends StatelessWidget {
  final int totalSeconds;

  const GameTimerWidget({super.key, required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      // TweenAnimationBuilder hace la magia: anima de 1.0 (lleno) a 0.0 (vacío)
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 0.0),
        duration: Duration(seconds: totalSeconds),
        builder: (context, value, child) {

          final int secondsLeft = (totalSeconds * value).ceil();

          Color progressColor = Colors.green;
          if (value < 0.6) progressColor = Colors.orange;
          if (value < 0.3) progressColor = Colors.red;

          return Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),

              Center(
                child: Text(
                  '$secondsLeft',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: progressColor, 
                  ),
                ),
              ),
            ],
          );
        },
        onEnd: () {
        },
      ),
    );
  }
}
