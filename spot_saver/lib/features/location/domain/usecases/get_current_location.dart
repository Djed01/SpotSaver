import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/location/domain/entities/location_entity.dart';
import 'package:spot_saver/features/location/domain/repositories/location_repository.dart';

class GetCurrentLocation implements UseCase<LocationEntity, NoParams> {
  final LocationRepository repository;

  GetCurrentLocation(this.repository);

  @override
  Future<Either<Failure, LocationEntity>> call(NoParams params) async {
    return await repository.getCurrentLocation();
  }
}
