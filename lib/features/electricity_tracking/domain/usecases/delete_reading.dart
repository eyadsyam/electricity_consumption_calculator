import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/electricity_repository.dart';

/// Use case for deleting a reading
class DeleteReading implements UseCase<void, DeleteReadingParams> {
  final ElectricityRepository repository;

  DeleteReading(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReadingParams params) async {
    return await repository.deleteReading(
      month: params.month,
      index: params.index,
    );
  }
}

/// Parameters for DeleteReading use case
class DeleteReadingParams {
  final String month;
  final int index;

  const DeleteReadingParams({required this.month, required this.index});
}
