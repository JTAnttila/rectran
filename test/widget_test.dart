import 'package:flutter_test/flutter_test.dart';
import 'package:rectran/main.dart';

void main() {
  group('AppBootstrap Widget Tests', () {
    testWidgets('renders navigation destinations', (tester) async {
      await tester.pumpWidget(const AppBootstrap());
      await tester.pumpAndSettle();

      expect(find.text('Record'), findsOneWidget);
      expect(find.text('Transcripts'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders recording screen by default', (tester) async {
      await tester.pumpWidget(const AppBootstrap());
      await tester.pumpAndSettle();

      expect(find.text('Voice Recorder'), findsOneWidget);
      expect(find.text('Transcriptions'), findsNothing);
    });
  });
}