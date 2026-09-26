enum FailureKind {
  validation,
  persistence,
  notification,
  backgroundImage,
  unexpected,
}

class AppFailure implements Exception {
  const AppFailure(this.kind);
  final FailureKind kind;
}
