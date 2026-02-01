import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading.dart';
import '../repositories/electricity_repository.dart';

/// Use case for getting readings for a specific month
class GetReadingsForMonth implements UseCase<List<Reading>, String> {
  final ElectricityRepository repository;

  GetReadingsForMonth(this.repository);

  @override
  Future<Either<Failure, List<Reading>>> call(String month) async {
    return await repository.getReadingsForMonth(month);
  }
}

/// Use case for getting all readings
class GetAllReadings implements UseCase<Map<String, List<Reading>>, NoParams> {
  final ElectricityRepository repository;

  GetAllReadings(this.repository);

  @override
  Future<Either<Failure, Map<String, List<Reading>>>> call(
    NoParams params,
  ) async {
    return await repository.getAllReadings();
  }
}
