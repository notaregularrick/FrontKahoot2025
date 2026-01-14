enum GameStatus {
  none,
  lobby, 
  question,
  answerSubmitted, 
  results, 
  end, 
}

enum ConnectionStatus {
  connecting, 
  connected, 
  disconected, 
  error,  
}

extension GameStatusParser on String {
  GameStatus? toGameStatus() {
    switch (this) {
      case 'GAME_STARTED': 
      case 'NEW_QUESTION':
        return GameStatus.question;

      case 'SHOW_LEADERBOARD':
        return GameStatus.results;

      case 'GAME_ENDED':
        return GameStatus.end;

      default:
        return null; 
    }
  }
}

enum GameRole { host, player, none }
