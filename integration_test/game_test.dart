// import 'dart:async';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:transoxiana/main.dart' as app;

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//   testWidgets("starting campaign", (WidgetTester tester) async {
//     await tester.runAsync(() async {
//       await app.main();

//       // await tester.pumpAndSettle();
//       // await tester.pump(Duration(seconds: 60));
//       await pumpForSeconds(tester, 20); //skip FlameSplashScreen

//       // find the start campaign button
//       final Finder startCampaignButton = find.byKey(const Key('startCampaignButton'));
//       expect(startCampaignButton, findsOneWidget);

//       // tap the start campaign button
//       await tester.tap(startCampaignButton);

//       await pumpForSeconds(tester, 10); //skip loading

//       // verify status bar exists and has the correct starting season
//       final Finder statusBarWidget = find.byKey(const Key('statusBar'));
//       expect(statusBarWidget.evaluate().length, 1);
//       // expect(find.text('Winter 1216'), findsOneWidget); //TODO: fix

//       // find the end turn button
//       final Finder endCampaignTurnButton =
//           find.byKey(const Key('endCampaignTurnButton'));
//       expect(endCampaignTurnButton, findsOneWidget);

//       // tap the end turn button
//       await tester.tap(endCampaignTurnButton);

//       await pumpForSeconds(tester, 8); //show the real time section

//       // verify the season has changed
//       // expect(find.text('Spring 1216'), findsOneWidget); //TODO: fix
//     });
//   });
// }

// Future<void> pumpForSeconds(WidgetTester tester, int seconds) async {
//   bool timerDone = false;
//   Timer(Duration(seconds: seconds), () => timerDone = true);
//   while (timerDone != true) {
//     await tester.pump();
//   }
// }
