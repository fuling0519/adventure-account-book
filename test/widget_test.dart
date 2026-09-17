import 'package:adventurer_pouch/app/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows the adventure navigation', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AdventurerPouchApp()));

    expect(find.text('地圖'), findsOneWidget);
    expect(find.text('背包'), findsOneWidget);
    expect(find.text('紀錄'), findsOneWidget);
  });
}
