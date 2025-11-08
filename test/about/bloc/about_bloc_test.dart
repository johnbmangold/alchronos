import 'package:alchronos/about/bloc/about_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AboutBloc', () {
    late AboutBloc aboutBloc;

    setUp(() {
      aboutBloc = AboutBloc();
    });

    tearDown(() {
      aboutBloc.close();
    });

    test('initial state is AboutInitial', () {
      expect(aboutBloc.state, isA<AboutInitial>());
    });

    test('emits no new states when AboutEvent is added', () {
      final initialState = aboutBloc.state;
      aboutBloc.add(AboutEvent());
      // Since AboutBloc doesn't handle events, state should remain the same
      expect(aboutBloc.state, initialState);
    });
  });
}

