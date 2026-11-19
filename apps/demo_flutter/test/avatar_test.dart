import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trillionai_interactive_demo/avatar.dart';

void main() {
  testWidgets('avatar exposes accessible state', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AgentAvatar(state: 'speaking')),
    ));
    expect(find.bySemanticsLabel('Agent speaking'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
