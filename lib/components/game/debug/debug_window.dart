part of game;

class DebugWindow extends StatefulWidget {
  const DebugWindow({
    required this.openedTop,
    required this.openedRight,
    required this.closedTop,
    required this.closedRight,
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  static const width = 500.0;
  static const height = 400.0;
  final double openedTop;
  final double openedRight;
  final double closedTop;
  final double closedRight;
  @override
  State<DebugWindow> createState() => _DebugWindowState();
}

class _DebugWindowState extends State<DebugWindow> {
  bool isOpen = true;

  @override
  Widget build(final BuildContext context) {
    if (!isOpen) {
      return Positioned(
        right: widget.closedRight,
        top: widget.closedTop,
        child: SizedBox(
          width: 80,
          child: ElevatedButton(
            onPressed: () {
              isOpen = true;
              setState(() {});
            },
            child: const Text('debug'),
          ),
        ),
      );
    }

    return Positioned(
      right: widget.openedRight,
      top: widget.openedTop,
      width: DebugWindow.width,
      height: DebugWindow.height,
      child: Material(
        textStyle: const TextStyle(color: Colors.white),
        color: Colors.transparent,
        child: Theme(
          data: ThemeData.dark(),
          child: ColoredBox(
            color: Colors.black54,
            child: DefaultTabController(
              length: 6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        isOpen = false;
                        setState(() {});
                      },
                      child: const Text('hide'),
                    ),
                  ),
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Camera'),
                      Tab(text: 'Campaign'),
                      Tab(text: 'Battle'),
                      Tab(text: 'Campaign Saves'),
                      Tab(text: 'Controls'),
                      Tab(text: 'Tutorials'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _CameraDebugView(game: widget.game),
                        _CampaignDebugRuntimeDataView(game: widget.game),
                        _BattleDebugView(game: widget.game),
                        _DebugSavesList(game: widget.game),
                        _DebugControlsView(game: widget.game),
                        _TutorialDebugView(game: widget.game),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
