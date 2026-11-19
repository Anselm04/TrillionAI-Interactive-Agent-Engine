import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trillionai_interactive_demo/avatar.dart';
void main(){testWidgets('avatar exposes accessible state',(tester)async{
 await tester.pumpWidget(const MaterialApp(home:AgentAvatar(state:'speaking')));
 expect(find.bySemanticsLabel('Agent speaking'),findsOneWidget);
 await tester.pump(const Duration(milliseconds:100));
 expect(tester.takeException(),isNull);
});}
