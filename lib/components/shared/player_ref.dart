import 'package:transoxiana/components/shared/nation.dart';

/// Support class to ensure that class has [player]
abstract class PlayerRef {
  PlayerRef(this.player);
  late Nation player;
}
