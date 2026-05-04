import 'package:emo_outlet/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EmoOutletApp());
    await tester.pumpAndSettle();

    expect(find.text('Emo Outlet'), findsNothing);
    expect(find.byType(EmoOutletApp), findsOneWidget);
  });
}
