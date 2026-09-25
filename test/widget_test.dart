import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_bassar/main.dart';
import 'package:movie_bassar/features/home/home_screen.dart';

void main() {
  testWidgets('CineVault App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CineVaultApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
