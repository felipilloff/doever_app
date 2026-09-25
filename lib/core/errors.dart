enum FailureKind { validation, persistence, notification, unexpected }

class AppFailure implements Exception {
  const AppFailure(this.kind);
  final FailureKind kind;
}
