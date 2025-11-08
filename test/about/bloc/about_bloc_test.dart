import 'dart:async';

import 'package:alchronos/about/bloc/about_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AboutBloc', () {
    late AboutBloc aboutBloc;

    setUp(() {
      aboutBloc = AboutBloc();
    });

    tearDown(() {
      unawaited(aboutBloc.close());
    });

    test('initial state is AboutInitial', () {
      expect(aboutBloc.state, isA<AboutInitial>());
    });

    test('state remains AboutInitial', () {
      // AboutBloc doesn't handle events, so state should remain AboutInitial
      expect(aboutBloc.state, isA<AboutInitial>());
    });
  });
}
