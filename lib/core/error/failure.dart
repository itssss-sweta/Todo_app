abstract class Failure {
  final String message;
  Failure(this.message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}
