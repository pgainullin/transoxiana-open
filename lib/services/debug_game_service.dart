enum VisibilityState {
  hidden,
  whatPlayerSee,
  whatEnemiesSee,
}

class DebugGameService {
  DebugGameService();

  VisibilityState fogOfWarVisibility = VisibilityState.whatPlayerSee;
}
