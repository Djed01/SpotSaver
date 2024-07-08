part of 'location_bloc.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final LocationEntity location;

  LocationLoaded({required this.location});
}

class LocationError extends LocationState {
  final String message;
  LocationError(this.message);
}
