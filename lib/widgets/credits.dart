import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/ui_constants.dart';
import 'package:url_launcher/url_launcher.dart';

typedef Credits = Map<String, List<Widget>>;

final Credits credits = {
  S.current.gameplayAndProgramming: [const Text('Pjotr Gainullin')],
  S.current.programming: [
    const Text('Anton Malofeev'),
    const Text('Igor Krupenja')
  ],
  S.current.art: [
    const Text('Vitaly Sorokin'),
    const Text('Vladimir Sjomkin'),
    const Text('Aleksander Nagorny')
  ],
  S.current.artConsulting: [const Text('Aleksei Nehoroshkin')],
  S.current.icons: [
    const Text('Stable Diffusion'),
    CreditsItemLink(
      text: 'Game-icons.net, ',
      linkText: 'CC BY 3.0 ${S.current.license}',
      link: 'http://creativecommons.org/licenses/by/3.0',
    ),
    CreditsItemLink(
      text: 'Icons8, ',
      linkText: S.current.license,
      link: 'https://icons8.com/license',
    ),
  ],
  S.current.soundEffects: [const Text('Sergey Aksenov')],
  S.current.music: [const Text('Maksim Nikotin')],
  S.current.otherLicences: [const Licences()],
  '': [
    Text(
      S.current.copyright(DateFormat('yyyy').format(DateTime.now())),
    )
  ],
};

class CreditsItemLink extends StatelessWidget {
  const CreditsItemLink({
    required this.text,
    required this.linkText,
    required this.link,
    super.key,
  });

  final String text;
  final String linkText;
  final String link;

  @override
  Widget build(final BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .headline3!
        .copyWith(color: UiColors.yellowPapyrus);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            style: style,
            children: [
              TextSpan(text: text),
              TextSpan(
                text: linkText,
                style: style.copyWith(decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => launchUrl(Uri.parse(link)),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class Licences extends StatelessWidget {
  const Licences({super.key});

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        getScaffoldKeyContext(),
        PageRouteBuilder(
          pageBuilder: (final context, final animation1, final animation2) =>
              const AboutDialog(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      ),
      child: Text(
        S.of(context).tapToView,
        style: Theme.of(context).textTheme.headline3!.copyWith(
              color: UiColors.yellowPapyrus,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }
}

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({
    required this.credits,
    required this.onFinish,
    final Key? key,
    this.creditItemDuration = const Duration(seconds: 10),
    this.itemsPerScreen = 4,
  })  : assert(credits.length > 0, 'You have to pass at least one child'),
        super(key: key);

  final Credits credits;
  final Duration creditItemDuration;
  final int itemsPerScreen;

  /// The only required option, callback to be invoked when animation finished
  final ValueChanged<BuildContext> onFinish;

  @override
  _CreditsScreenState createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with SingleTickerProviderStateMixin {
  late Animation<int> animation;
  late AnimationController controller;
  int? currentIndex;
  final List<CreditsItem> _widgets = [];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: widget.creditItemDuration * (widget.credits.length - 1),
      vsync: this,
    );

    animation = StepTween(
      begin: 1,
      end: widget.itemsPerScreen * widget.credits.length,
    ).animate(controller)
      ..addStatusListener((final status) {
        if (status == AnimationStatus.completed) onFinish();
      })
      ..addListener(() {
        final int newIndex = animation.value - 1;
        if (currentIndex != newIndex && newIndex < widget.credits.length) {
          setState(() {
            currentIndex = newIndex;
            _widgets.add(
              CreditsItem(
                title: widget.credits.keys.elementAt(newIndex),
                duration: widget.creditItemDuration,
                children: widget.credits.values.elementAt(newIndex),
              ),
            );
          });
        } else if (newIndex == widget.credits.length) {
          controller.forward(from: controller.upperBound);
        }
      });

    controller.forward();
  }

  void toggleAnimation() {
    if (controller.isAnimating) {
      for (final element in _widgets) {
        element.stopAnimation();
      }
      controller.stop();
    } else {
      for (final element in _widgets) {
        element.restartAnimation();
      }
      controller.forward();
    }
  }

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: toggleAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Stack(
          children: _widgets,
        ),
      ),
    );
  }

  Future<void> onFinish() async {
    await Future.delayed(
      widget.creditItemDuration * (1 / widget.itemsPerScreen),
    );

    if (mounted) widget.onFinish(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class CreditsItem extends StatefulWidget {
  CreditsItem({
    required this.title,
    required this.duration,
    required this.children,
    final Key? key,
  }) : super(key: key);

  final String title;
  final Duration duration;
  final List<Widget> children;
  late VoidCallback stopAnimation;
  late VoidCallback restartAnimation;

  @override
  _CreditsItemState createState() => _CreditsItemState();
}

//assume fixed screen height and widget.child height not exceeding screen height
class _CreditsItemState extends State<CreditsItem>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = Tween<double>(begin: 1.0, end: -1.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    widget.stopAnimation = () => controller.stop();
    widget.restartAnimation = () => controller.forward();

    startAnimation();
  }

  Future<void> startAnimation() async {
    controller.value = 0.0;
    await controller.forward();
  }

  @override
  Widget build(final BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final style = Theme.of(context)
        .textTheme
        .headline3!
        .copyWith(color: UiColors.yellowPapyrus);

    return Positioned(
      top: screenSize.height * animation.value,
      width: screenSize.width,
      child: Center(
        child: DefaultTextStyle(
          style: style,
          child: Column(
            children: [
              Text(widget.title, style: style.copyWith(fontSize: 40)),
              const SizedBox(height: 10),
              ...widget.children
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
