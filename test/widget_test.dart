import 'package:flutter_test/flutter_test.dart';

import 'package:sav_ds/main.dart';
import 'package:sav_ds/components/app_button.dart';

void main() {
  testWidgets('Button gallery renders buttons successfully', (tester) async {
    await tester.pumpWidget(const SavApp());
    expect(find.byType(AppButton), findsWidgets);
    expect(find.text('Preview Button'), findsOneWidget);
    expect(find.text('Primary Regular'), findsOneWidget);
    expect(find.text('Secondary Small'), findsOneWidget);
  });
}
