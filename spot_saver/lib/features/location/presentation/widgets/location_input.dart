import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spot_saver/core/secrets/app_secrets.dart';
import 'package:spot_saver/core/usecase/usecase.dart';
import 'package:spot_saver/features/location/domain/usecases/get_current_location.dart';
import '../pages/map_page.dart';

class LocationInput extends StatefulWidget {
  final Function(double, double) onSelectLocation;
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationInput({
    super.key,
    required this.onSelectLocation,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LatLng? _pickedLocation;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _pickedLocation =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  void _getCurrentLocation() async {
    final getCurrentLocation = GetIt.instance<GetCurrentLocation>();

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final locationEither = await getCurrentLocation(NoParams());
      locationEither.fold(
        (failure) {
          setState(() {
            _isGettingLocation = false;
          });
        },
        (locationEntity) {
          final lat = locationEntity.latitude;
          final lng = locationEntity.longitude;

          setState(() {
            _pickedLocation = LatLng(lat, lng);
            _isGettingLocation = false;
          });

          widget.onSelectLocation(lat, lng);
        },
      );
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (ctx) => const MapScreen(
          isSelecting: true,
        ),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    setState(() {
      _pickedLocation = pickedLocation;
    });

    widget.onSelectLocation(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: _isGettingLocation
              ? const CircularProgressIndicator()
              : _pickedLocation == null
                  ? const Text(
                      'No Location Chosen',
                      textAlign: TextAlign.center,
                    )
                  : Image.network(
                      'https://maps.googleapis.com/maps/api/staticmap?center=${_pickedLocation!.latitude},${_pickedLocation!.longitude}&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C${_pickedLocation!.latitude},${_pickedLocation!.longitude}&key=${AppSecrets.googleMapApiKey}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text(
                  'Get current location',
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _getCurrentLocation,
              ),
            ),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.map),
                label: const Text(
                  'Select on map',
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: _selectOnMap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
