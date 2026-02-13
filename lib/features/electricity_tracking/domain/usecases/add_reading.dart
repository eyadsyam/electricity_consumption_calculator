import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading.dart';
import '../repositories/electricity_repository.dart';

/// Use case for adding a new electricity reading
class AddReading implements UseCase<Reading, AddReadingParams> {
  final ElectricityRepository repository;

  AddReading(this.repository);

  @override
  Future<Either<Failure, Reading>> call(AddReadingParams params) async {
    // Validate inputs
    if (params.newReading <= params.oldReading) {
      return const Left(
        ValidationFailure(
          message: 'New reading must be greater than old reading',
        ),
      );
    }

    return await repository.addReading(
      oldReading: params.oldReading,
      newReading: params.newReading,
      month: params.month,
    );
  }
}

/// Parameters for AddReading use case
class AddReadingParams {
  final int oldReading;
  final int newReading;
  final String month;

  const AddReadingParams({
    required this.oldReading,
    required this.newReading,
    required this.month,
  });
}
