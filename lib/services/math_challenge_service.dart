import 'dart:math';
import '../models/alarm.dart';

/// Mathematical challenge for alarm unlock
class MathChallenge {
  final String question;
  final int answer;
  final String operation;

  const MathChallenge({
    required this.question,
    required this.answer,
    required this.operation,
  });
}

/// Service for generating math challenges to unlock alarms
class MathChallengeService {
  static MathChallengeService? _instance;
  static final _random = Random();

  /// Private constructor
  MathChallengeService._();

  /// Singleton instance
  static MathChallengeService get instance {
    _instance ??= MathChallengeService._();
    return _instance!;
  }

  /// Generate a math challenge based on difficulty and operations
  MathChallenge generateChallenge(
    MathDifficulty difficulty,
    MathOperations operations,
  ) {
    switch (operations) {
      case MathOperations.additionOnly:
        return _generateAddition(difficulty);
      case MathOperations.subtractionOnly:
        return _generateSubtraction(difficulty);
      case MathOperations.multiplicationOnly:
        return _generateMultiplication(difficulty);
      case MathOperations.mixed:
        final ops = [
          MathOperations.additionOnly,
          MathOperations.subtractionOnly,
          MathOperations.multiplicationOnly,
        ];
        final randomOp = ops[_random.nextInt(ops.length)];
        return generateChallenge(difficulty, randomOp);
    }
  }

  /// Generate addition challenge based on difficulty
  MathChallenge _generateAddition(MathDifficulty difficulty) {
    final range = _getNumberRange(difficulty);
    final a = _random.nextInt(range) + 1;
    final b = _random.nextInt(range) + 1;
    return MathChallenge(
      question: '$a + $b = ?',
      answer: a + b,
      operation: 'addition',
    );
  }

  /// Generate subtraction challenge based on difficulty
  MathChallenge _generateSubtraction(MathDifficulty difficulty) {
    final range = _getNumberRange(difficulty);
    final a = _random.nextInt(range) + 10; // Ensure positive result
    final b = _random.nextInt(a); // b is always less than a
    return MathChallenge(
      question: '$a - $b = ?',
      answer: a - b,
      operation: 'subtraction',
    );
  }

  /// Generate multiplication challenge based on difficulty
  MathChallenge _generateMultiplication(MathDifficulty difficulty) {
    late int a, b;

    switch (difficulty) {
      case MathDifficulty.easy:
        a = _random.nextInt(10) + 1; // 1-10
        b = _random.nextInt(10) + 1; // 1-10
        break;
      case MathDifficulty.medium:
        a = _random.nextInt(12) + 1; // 1-12
        b = _random.nextInt(12) + 1; // 1-12
        break;
      case MathDifficulty.hard:
        a = _random.nextInt(15) + 1; // 1-15
        b = _random.nextInt(15) + 1; // 1-15
        break;
    }

    return MathChallenge(
      question: '$a × $b = ?',
      answer: a * b,
      operation: 'multiplication',
    );
  }

  /// Get number range based on difficulty
  int _getNumberRange(MathDifficulty difficulty) {
    switch (difficulty) {
      case MathDifficulty.easy:
        return 50;
      case MathDifficulty.medium:
        return 100;
      case MathDifficulty.hard:
        return 200;
    }
  }
}
