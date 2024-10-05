import 'dart:math';

import 'package:flutter/material.dart';
import 'package:balti_ludo/ludo_player.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'constants.dart';

class LudoProvider extends ChangeNotifier {
  bool _isMoving = false;
  bool _stopMoving = false;
  LudoGameState _gameState = LudoGameState.throwDice;
  LudoGameState get gameState => _gameState;

  LudoPlayerType _currentTurn = LudoPlayerType.green;
  int _diceResult = 0;
  int get diceResult => _diceResult.clamp(1, 6);

  bool _diceStarted = false;
  bool get diceStarted => _diceStarted;

  LudoPlayer get currentPlayer => players.firstWhere((element) => element.type == _currentTurn);

  final List<LudoPlayer> players = [];
  final List<LudoPlayerType> winners = [];

  // New variables for new rules
  bool _automaticDiceRoll = true;
  bool get automaticDiceRoll => _automaticDiceRoll;

  int _playerCount = 4;
  bool _teamMode = false;

  List<int> _storedMoves = [];

  LudoPlayer player(LudoPlayerType type) => players.firstWhere((element) => element.type == type);

  void setAutomaticDiceRoll(bool value) {
    _automaticDiceRoll = value;
    notifyListeners();
  }

  void setPlayerCount(int count) {
    _playerCount = count.clamp(2, 4);
    notifyListeners();
  }

  void setTeamMode(bool value) {
    _teamMode = value;
    notifyListeners();
  }

  bool checkToKill(LudoPlayerType type, int index, int step, List<List<double>> path) {
    bool killSomeone = false;
    for (var player in players) {
      if (player.type == type) continue;
      for (int i = 0; i < player.pawns.length; i++) {
        var pawn = player.pawns[i];
        if (pawn.step > -1 && !LudoPath.safeArea.map((e) => e.toString()).contains(player.path[pawn.step].toString())) {
          if (player.path[pawn.step].toString() == path[step - 1].toString()) {
            if (!isDeadEnd(player.type, i)) {
              killSomeone = true;
              player.movePawn(i, -1);
              notifyListeners();
            } else if (isStackableKill(type, index, player.type, i)) {
              killSomeone = true;
              player.movePawn(i, -1);
              player.movePawn(player.pawns.indexWhere((p) => p.step == pawn.step && p.index != i), -1);
              notifyListeners();
            }
          }
        }
      }
    }
    return killSomeone;
  }

  bool isDeadEnd(LudoPlayerType type, int index) {
    var player = this.player(type);
    var pawn = player.pawns[index];
    return player.pawns.where((p) => p.step == pawn.step).length == 2;
  }

  bool isStackableKill(LudoPlayerType attackerType, int attackerIndex, LudoPlayerType defenderType, int defenderIndex) {
    var attacker = player(attackerType);
    var defender = player(defenderType);
    var attackerPawn = attacker.pawns[attackerIndex];
    var defenderPawn = defender.pawns[defenderIndex];

    if (!isDeadEnd(defenderType, defenderIndex)) return false;
    if (LudoPath.safeArea.contains(defender.path[defenderPawn.step])) return false;

    var attackerStack = attacker.pawns.where((p) => p.step == attackerPawn.step).length;
    var defenderStack = defender.pawns.where((p) => p.step == defenderPawn.step).length;

    return attackerStack == defenderStack + 1;
  }

  void throwDice() async {
    if (_gameState != LudoGameState.throwDice) return;
    _diceStarted = true;
    notifyListeners();
    Audio.rollDice();

    if (winners.contains(currentPlayer.type)) {
      nextTurn();
      return;
    }

    currentPlayer.highlightAllPawns(false);

    Future.delayed(const Duration(seconds: 1)).then((value) {
      _diceStarted = false;
      var random = Random();
      _diceResult = random.nextInt(6) + 1;
      notifyListeners();

      if (_diceResult == 6) {
        _storedMoves.add(_diceResult);
        _gameState = LudoGameState.throwDice;
      } else {
        _storedMoves.add(_diceResult);
        _gameState = LudoGameState.pickPawn;
        currentPlayer.highlightOutside();
      }

      for (var i = 0; i < currentPlayer.pawns.length; i++) {
        var pawn = currentPlayer.pawns[i];
        if ((pawn.step + _storedMoves.reduce((a, b) => a + b)) > currentPlayer.path.length - 1) {
          currentPlayer.highlightPawn(i, false);
        }
      }

      if (currentPlayer.pawns.every((element) => !element.highlight)) {
        nextTurn();
      }
      notifyListeners();
    });
  }

  void move(LudoPlayerType type, int index, int step) async {
    if (_isMoving) return;
    _isMoving = true;
    _gameState = LudoGameState.moving;

    currentPlayer.highlightAllPawns(false);

    var selectedPlayer = player(type);
    for (int i = selectedPlayer.pawns[index].step + 1; i <= step; i++) {
      if (_stopMoving) break;
      selectedPlayer.movePawn(index, i);
      await Audio.playMove();
      notifyListeners();
      if (_stopMoving) break;
    }

    bool killed = checkToKill(type, index, step, selectedPlayer.path);
    if (killed) {
      _gameState = LudoGameState.throwDice;
      _isMoving = false;
      Audio.playKill();
      _storedMoves.clear();
      notifyListeners();
      return;
    }

    validateWin(type);

    if (_storedMoves.isNotEmpty) {
      _storedMoves.removeAt(0);
      if (_storedMoves.isEmpty) {
        nextTurn();
      } else {
        _gameState = LudoGameState.pickPawn;
      }
    } else {
      nextTurn();
    }

    _isMoving = false;
    notifyListeners();
  }

  void nextTurn() {
    _storedMoves.clear();
    int currentIndex = players.indexWhere((player) => player.type == _currentTurn);
    int nextIndex = (currentIndex + 1) % players.length;
    _currentTurn = players[nextIndex].type;

    if (winners.contains(_currentTurn)) return nextTurn();
    _gameState = LudoGameState.throwDice;
    notifyListeners();
  }

  void validateWin(LudoPlayerType color) {
    if (winners.map((e) => e.name).contains(color.name)) return;
    if (player(color).pawns.map((e) => e.step).every((element) => element == player(color).path.length - 1)) {
      winners.add(color);
      notifyListeners();
    }

    if (winners.length == players.length - 1) {
      _gameState = LudoGameState.finish;
    }
  }

  void startGame() {
    winners.clear();
    players.clear();
    List<LudoPlayerType> allTypes = [LudoPlayerType.green, LudoPlayerType.yellow, LudoPlayerType.blue, LudoPlayerType.red];
    for (int i = 0; i < _playerCount; i++) {
      players.add(LudoPlayer(allTypes[i]));
    }
    _storedMoves.clear();
  }

  @override
  void dispose() {
    _stopMoving = true;
    super.dispose();
  }

  static LudoProvider read(BuildContext context) => context.read();
}