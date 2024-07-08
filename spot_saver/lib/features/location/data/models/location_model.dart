import 'package:location/location.dart';
import 'package:spot_saver/features/location/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    required super.latitude,
    required super.longitude,
  });

  factory LocationModel.fromLocationData(LocationData location) {
    return LocationModel(
      latitude: location.latitude!,
      longitude: location.longitude!,
    );
  }
}
