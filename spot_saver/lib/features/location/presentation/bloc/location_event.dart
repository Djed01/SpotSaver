part of 'location_bloc.dart';

@immutable
sealed class LocationEvent {}

class GetLocationEvent extends LocationEvent {}
