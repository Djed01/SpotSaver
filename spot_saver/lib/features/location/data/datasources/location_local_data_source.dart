import 'package:fpdart/fpdart.dart';
import 'package:location/location.dart';
import 'package:spot_saver/core/error/failures.dart';
import 'package:spot_saver/features/location/data/models/location_model.dart';
import 'package:spot_saver/features/location/domain/entities/location_entity.dart';

abstract interface class LocationLocalDataSource {
  Future<Either<Failure, LocationEntity>> getCurrentLocation();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final Location location;

  LocationLocalDataSourceImpl({required this.location});

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return Left(ServiceDisabledFailure());
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return Left(PermissionDeniedFailure());
        }
      }

      final locationData = await location.getLocation();
      final locationEntity = LocationModel.fromLocationData(locationData);
      return Right(locationEntity);
    } catch (e) {
      return Left(LocationFailure());
    }
  }
}
