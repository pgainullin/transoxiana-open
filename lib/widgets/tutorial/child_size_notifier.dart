import 'package:flutter/widgets.dart';

/// This widget gets size of child
/// source: https://stackoverflow.com/questions/58000495/how-to-get-child-widget-size-for-animation-values-in-parent
class ChildSizeNotifier extends StatelessWidget {
  const ChildSizeNotifier({
    required this.builder,
    required this.notifier,
    final Key? key,
    this.child,
  }) : super(key: key);
  final ValueNotifier<Size> notifier;
  final ValueWidgetBuilder<Size> builder;
  final Widget? child;

  @override
  Widget build(final BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (final _) {
        final size = (context.findRenderObject() as RenderBox?)?.size;
        if (size == Size.zero || size == null) return;
        notifier.value = size;
      },
    );
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: builder,
      child: child,
    );
  }
}
