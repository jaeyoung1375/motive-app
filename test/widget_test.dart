import 'package:flutter_test/flutter_test.dart';

import 'package:motive_app_toy/main.dart';

void main() {
  testWidgets('shows the starter placeholder text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('GUIDE.md의 Step 1부터 직접 타이핑해보세요'), findsOneWidget);
  });
}
