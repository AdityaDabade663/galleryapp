import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/app/modules/home/bindings/home_binding.dart';
import 'package:gallery/app/modules/home/views/home_view.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('HomeView renders Upload and Images tabs properly', (
    WidgetTester tester,
  ) async {
    HomeBinding().dependencies();

    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));

    // Initial tab: Upload
    expect(find.text('Upload'), findsOneWidget);
    expect(find.text('Images'), findsOneWidget);
    expect(find.text('Browser Gallery'), findsOneWidget);
    expect(find.text('Open camera'), findsOneWidget);

    // Switch to Images tab
    await tester.tap(find.text('Images'));
    await tester.pumpAndSettle();

    // Verify Images grid is rendered with demo items
    expect(find.text('Reference Name 1'), findsOneWidget);
    expect(find.text('Reference Name 2'), findsOneWidget);
  });
}
