part of game;

class GameApp extends StatelessWidget {
  const GameApp({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    /// We assume there will be no routes inside material app
    /// because all routes should be handled by [GameNavigator]
    /// and [TransoxianaGameWidget]
    /// overlays to have valid access to gameRef

    return MaterialApp(
      theme: UiThemes.defaultTheme,
      localizationsDelegates: const [
        // 1
        S.delegate,
        // 2
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Transoxiana',
      restorationScopeId: 'Transoxiana',
      home: Scaffold(
        key: scaffoldKey,
        restorationId: 'TransoxianaGameWidget',
        body: const TransoxianaGameWidget(),
      ),
    );
  }
}
