import 'package:flutter_test/flutter_test.dart';
import 'package:trillionai_interactive_demo/avatar/visemes.dart';
void main(){
 test('phoneme groups and stress markers map correctly',(){
  expect(phonemeToViseme('M'),Viseme.closed);
  expect(phonemeToViseme('AA1'),Viseme.open);
  expect(phonemeToViseme('UW0'),Viseme.round);
  expect(phonemeToViseme('unknown'),Viseme.rest);
 });
 test('timeline handles gaps, boundaries and transitions',(){
  final t=VisemeTimeline([const PhonemeCue(100,300,'AA'),const PhonemeCue(300,500,'M')]);
  expect(t.sample(0).opening,.05);
  expect(t.sample(200).opening,1);
  expect(t.sample(300).opening,.5);
  expect(t.sample(400).opening,0);
  expect(t.sample(500).opening,.05);
 });
 test('invalid or overlapping timings rejected',(){
  expect(()=>VisemeTimeline([const PhonemeCue(0,50,'M'),const PhonemeCue(40,60,'AA')]),throwsArgumentError);
  expect(()=>VisemeTimeline([const PhonemeCue(1,1,'M')]),throwsArgumentError);
 });
}
