import 'package:flutter_test/flutter_test.dart';
import 'package:sav_ds_example/main.dart';

void main() {
  testWidgets('Gallery boots without errors', (tester) async {
    await tester.pumpWidget(const SavApp());
    await tester.pump();

    // The gallery title is rendered on first frame.
    expect(find.text('Sav Design System'), findsWidgets);
  });
}
