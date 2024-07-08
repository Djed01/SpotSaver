import 'package:fpdart/fpdart.dart';
import 'package:spot_saver/features/location/data/datasources/location_local_data_source.dart';
import 'package:spot_saver/features/location/domain/entities/location_entity.dart';
import 'package:spot_saver/features/location/domain/repositories/location_repository.dart';

import '../../../../core/error/failures.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource dataSource;

  LocationRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    return await dataSource.getCurrentLocation();
  }
}
