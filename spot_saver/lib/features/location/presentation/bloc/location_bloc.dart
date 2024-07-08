import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/location/domain/entities/location_entity.dart';
import 'package:spot_saver/features/location/domain/usecases/get_current_location.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetCurrentLocation getCurrentLocation;

  LocationBloc({required this.getCurrentLocation}) : super(LocationInitial()) {
    on<GetLocationEvent>((event, emit) async {
      emit(LocationLoading());
      final res = await getCurrentLocation(NoParams());
      res.fold((l) => emit(LocationError(l.message)),
          (r) => emit(LocationLoaded(location: r)));
    });
  }
}
