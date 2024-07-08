import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/features/location/domain/entities/location_entity.dart';

abstract interface class LocationRepository {
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
}
