class Failure {
  final String message;
  Failure([this.message = 'An unexpected error occured.']);
}

// Failure classes
class ServiceDisabledFailure extends Failure {}

class PermissionDeniedFailure extends Failure {}

class LocationFailure extends Failure {}
