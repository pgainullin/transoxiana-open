part of tutorial_widgets;

class FloatingTip extends StatelessWidget {
  const FloatingTip({
    required this.step,
    required this.nextStep,
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final TutorialStep step;
  final TutorialStep? nextStep;
  @override
  Widget build(final BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 300,
        maxWidth: math.min(
          500,
          screenSize.width * 0.5,
        ),
      ),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          // shrinkWrap: true,
          children: [
            SingleChildScrollView(
              child: ListTile(
                // TODO(arenukvern): add markdown parser or use SimpleRichText
                title: Text(
                  step.title,
                  style: Theme.of(context).textTheme.headline4,
                ),
                subtitle: Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            ),
            SizedBox(
              height: 60.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: step.isBackButtonVisible,
                      child: TutorialBackButton(
                        game: game,
                      ),
                    ),
                    Visibility(
                      visible: step.isBackButtonVisible,
                      child: const Spacer(),
                    ),
                    Visibility(
                      visible: step.isNextButtonVisible,
                      child: TutorialNextButton(
                        step: step,
                        game: game,
                      ),
                    ),
                    const Spacer(),
                    Visibility(
                      visible: step.isCloseButtonVisible,
                      child: TutorialCloseButton(
                        step: step,
                        game: game,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
