enum GameStatus {
  connecting, // Conectando al juego
  lobby,    // Esperando jugadores
  question, // Pregunta activa 
  results,  // Resultados de la pregunta
  end       // Podio final
}

enum GameRole {
  host,
  player,
  none
}