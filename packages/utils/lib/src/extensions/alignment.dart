part of extensions;

extension AlignmentExt on String {
  Alignment toAlignment() {
    switch (this) {
      case 'Alignment.topLeft':
        return const Alignment(-1.0, -1.0);
      case 'Alignment.topCenter':
        return const Alignment(0.0, -1.0);
      case 'Alignment.topRight':
        return const Alignment(1.0, -1.0);
      case 'Alignment.centerLeft':
        return const Alignment(-1.0, 0.0);
      case 'Alignment.center':
        return const Alignment(0.0, 0.0);
      case 'Alignment.centerRight':
        return const Alignment(1.0, 0.0);
      case 'Alignment.bottomLeft':
        return const Alignment(-1.0, 1.0);
      case 'Alignment.bottomCenter':
        return const Alignment(0.0, 1.0);
      case 'Alignment.bottomRight':
        return const Alignment(1.0, 1.0);
      default:
        return const Alignment(0.0, 0.0);
    }
  }
}
