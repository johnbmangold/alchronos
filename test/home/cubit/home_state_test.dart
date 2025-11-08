import 'package:alchronos/app_database.dart';
import 'package:alchronos/home/cubit/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeState', () {
    group('HomeInitial', () {
      test('is instance of HomeState', () {
        final state = HomeInitial();

        expect(state, isA<HomeState>());
      });
    });

    group('HomeStart', () {
      test('is instance of HomeState', () {
        final state = HomeStart();

        expect(state, isA<HomeState>());
      });
    });

    group('HomeError', () {
      test('is instance of HomeState', () {
        final state = HomeError('Error message');

        expect(state, isA<HomeState>());
      });

      test('contains error message', () {
        const message = 'Test error message';
        final state = HomeError(message);

        expect(state.message, message);
      });
    });

    group('HomeRunning', () {
      test('is instance of HomeState', () {
        final partialRunData = PartialRunData(
          id: 1,
          endTime: DateTime(2024, 1, 1),
          secondsRemaining: 60,
        );
        final state = HomeRunning(
          partialRunData: partialRunData,
          totalDurationInSeconds: 60,
        );

        expect(state, isA<HomeState>());
      });

      test('defaults isPaused to false', () {
        final partialRunData = PartialRunData(
          id: 1,
          endTime: DateTime(2024, 1, 1),
          secondsRemaining: 60,
        );
        final state = HomeRunning(
          partialRunData: partialRunData,
          totalDurationInSeconds: 60,
        );

        expect(state.isPaused, isFalse);
        expect(state.pausedAt, isNull);
      });

      test('sets isPaused and pausedAt when provided', () {
        final partialRunData = PartialRunData(
          id: 1,
          endTime: DateTime(2024, 1, 1),
          secondsRemaining: 60,
        );
        final pausedAt = DateTime(2024, 1, 1, 0, 30);
        final state = HomeRunning(
          partialRunData: partialRunData,
          totalDurationInSeconds: 60,
          isPaused: true,
          pausedAt: pausedAt,
        );

        expect(state.isPaused, isTrue);
        expect(state.pausedAt, pausedAt);
      });

      group('copyWith', () {
        test('returns new instance with updated values', () {
          final originalPartialRunData = PartialRunData(
            id: 1,
            endTime: DateTime(2024, 1, 1),
            secondsRemaining: 60,
          );
          final originalState = HomeRunning(
            partialRunData: originalPartialRunData,
            totalDurationInSeconds: 60,
            isPaused: false,
          );

          final newPartialRunData = PartialRunData(
            id: 2,
            endTime: DateTime(2024, 1, 2),
            secondsRemaining: 120,
          );
          final newState = originalState.copyWith(
            partialRunData: newPartialRunData,
            totalDurationInSeconds: 120,
            isPaused: true,
            pausedAt: DateTime(2024, 1, 1, 0, 30),
          );

          expect(newState.partialRunData, newPartialRunData);
          expect(newState.totalDurationInSeconds, 120);
          expect(newState.isPaused, isTrue);
          expect(newState.pausedAt, isNotNull);
        });

        test('preserves original values when not provided', () {
          final originalPartialRunData = PartialRunData(
            id: 1,
            endTime: DateTime(2024, 1, 1),
            secondsRemaining: 60,
          );
          final originalState = HomeRunning(
            partialRunData: originalPartialRunData,
            totalDurationInSeconds: 60,
            isPaused: false,
          );

          final newState = originalState.copyWith(isPaused: true);

          expect(newState.partialRunData, originalPartialRunData);
          expect(newState.totalDurationInSeconds, 60);
          expect(newState.isPaused, isTrue);
          expect(newState.pausedAt, isNull);
        });
      });
    });
  });
}

