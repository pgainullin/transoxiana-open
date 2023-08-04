import 'package:equatable/equatable.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

@immutable

/// Use [title] to access overlay
class GameOverlay<T extends FlameGame> extends Equatable {
  const GameOverlay({
    required this.builder,
    required final String title,
    required this.prefix,
  }) : _title = title;
  final OverlayWidgetBuilder<T> builder;
  final String _title;
  final String prefix;

  /// Use [title] to access overlay
  String get title => '$prefix$_title';
  MapEntry<String, OverlayWidgetBuilder<T>> toMapEntry() =>
      MapEntry(title, builder);

  static GameOverlay byPrefixedTitle(final String titleWithPrefix) =>
      GameOverlay(
        builder: (final _, final __) => Container(),
        prefix: '',
        title: titleWithPrefix,
      );

  @override
  List<Object?> get props => [title];
  @override
  bool? get stringify => true;
}
