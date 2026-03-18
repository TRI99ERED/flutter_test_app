import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:test_app/src/features/themes/app_theme.dart';

enum MapMarkerSize {
  small(Size(18, 24)),
  medium(Size(24, 32)),
  large(Size(32, 42));

  final Size size;
  const MapMarkerSize(this.size);
}

enum MyLocationMarkerSize {
  small(16),
  medium(20),
  large(24);

  final double size;
  const MyLocationMarkerSize(this.size);
}

class AppMap extends StatefulWidget {
  final LatLng center;
  final double zoom;
  final List<AppMarker>? markers;
  final bool showUserLocation;
  final MyLocationMarkerSize userLocationMarkerSize;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<AppMarker?>? onMarkerTapped;

  const AppMap({
    super.key,
    required this.center,
    required this.zoom,
    this.markers,
    this.showUserLocation = true,
    this.userLocationMarkerSize = MyLocationMarkerSize.small,
    this.onMapCreated,
    this.onMarkerTapped,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  BitmapDescriptor? _smallMarkerSelectedIcon;
  BitmapDescriptor? _mediumMarkerSelectedIcon;
  BitmapDescriptor? _largeMarkerSelectedIcon;
  BitmapDescriptor? _smallMarkerDeselectedIcon;
  BitmapDescriptor? _mediumMarkerDeselectedIcon;
  BitmapDescriptor? _largeMarkerDeselectedIcon;
  BitmapDescriptor? _locationMarkerIcon;

  late final LatLng _center = widget.center;
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initializeMarker();

    _requestLocationPermissionAndStartListening();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermissionAndStartListening() async {
    try {
      final permission = await Geolocator.checkPermission();
      debugPrint('Current location permission: $permission');

      LocationPermission finalPermission = permission;

      if (permission == LocationPermission.denied) {
        debugPrint('Permission denied, requesting...');
        finalPermission = await Geolocator.requestPermission();
        debugPrint('Permission after request: $finalPermission');
      }

      if (finalPermission == LocationPermission.whileInUse ||
          finalPermission == LocationPermission.always) {
        debugPrint('Permission granted, starting location listening');
        _startListeningToLocation();
      } else if (finalPermission == LocationPermission.deniedForever) {
        debugPrint(
          'Location permission denied forever. User needs to enable it in settings.',
        );
      } else {
        debugPrint('Location permission not granted: $finalPermission');
      }
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
    }
  }

  void _startListeningToLocation() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            debugPrint(
              'Location updated: ${position.latitude}, ${position.longitude}',
            );
            _userLocation = LatLng(position.latitude, position.longitude);
          },
          onError: (error) {
            debugPrint('Error getting location: $error');
          },
        );
  }

  Future<BitmapDescriptor> _createCustomPinMarker(
    Size size,
    bool isSelected,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final radius = size.width / 2;

    final trianglePaint = Paint()
      ..color = isSelected
          ? Theme.of(context).extension<AppTheme>()?.highlightDarkestColor ??
                const Color(0xFF006FFD)
          : Theme.of(context).extension<AppTheme>()?.backgroundWeakestColor ??
                const Color(0xFFC5C6CC)
      ..style = PaintingStyle.fill;

    final cx = radius;
    final cy = radius;
    final py = size.height;
    final d = py - cy;

    final ty = cy + (radius * radius) / d;
    final dx = radius * sqrt((d * d - radius * radius)) / d;

    final path = Path();
    path.moveTo(cx - dx, ty);
    path.lineTo(cx + dx, ty);
    path.lineTo(radius, size.height);
    path.close();

    canvas.drawPath(path, trianglePaint);

    final outerCirclePaint = Paint()
      ..color = isSelected
          ? Theme.of(context).extension<AppTheme>()?.highlightDarkestColor ??
                const Color(0xFF006FFD)
          : Theme.of(context).extension<AppTheme>()?.backgroundWeakestColor ??
                const Color(0xFFC5C6CC);

    canvas.drawCircle(Offset(radius, radius), radius, outerCirclePaint);

    final innerCirclePaint = Paint()
      ..color =
          Theme.of(context).extension<AppTheme>()?.backgroundStrongestColor ??
          const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset(radius, radius), radius / 3, innerCirclePaint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  Future<BitmapDescriptor> _createCustomMyLocationMarker(double radius) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final outerCirclePaint = Paint()
      ..color =
          Theme.of(context).extension<AppTheme>()?.highlightLightColor ??
          const Color(0xFFB4DBFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(radius * 2, radius * 2),
      radius * 2,
      outerCirclePaint,
    );

    final middleCirclePaint = Paint()
      ..color =
          Theme.of(context).extension<AppTheme>()?.backgroundStrongestColor ??
          const Color(0xFFFFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(radius * 2, radius * 2),
      radius,
      middleCirclePaint,
    );

    final innerCirclePaint = Paint()
      ..color =
          Theme.of(context).extension<AppTheme>()?.highlightDarkestColor ??
          const Color(0xFF006FFD);
    canvas.drawCircle(
      Offset(radius * 2, radius * 2),
      radius * 0.5,
      innerCirclePaint,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(
      (radius * 4).toInt(),
      (radius * 4).toInt(),
    );
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(bytes);
  }

  Future<void> _initializeMarker() async {
    _smallMarkerSelectedIcon = await _createCustomPinMarker(
      MapMarkerSize.small.size,
      true,
    );
    _mediumMarkerSelectedIcon = await _createCustomPinMarker(
      MapMarkerSize.medium.size,
      true,
    );
    _largeMarkerSelectedIcon = await _createCustomPinMarker(
      MapMarkerSize.large.size,
      true,
    );
    _smallMarkerDeselectedIcon = await _createCustomPinMarker(
      MapMarkerSize.small.size,
      false,
    );
    _mediumMarkerDeselectedIcon = await _createCustomPinMarker(
      MapMarkerSize.medium.size,
      false,
    );
    _largeMarkerDeselectedIcon = await _createCustomPinMarker(
      MapMarkerSize.large.size,
      false,
    );
    _locationMarkerIcon = await _createCustomMyLocationMarker(
      widget.userLocationMarkerSize.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final markersList = <Marker>[];

    if (_locationMarkerIcon != null &&
        _userLocation != null &&
        widget.showUserLocation) {
      markersList.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _userLocation!,
          icon: _locationMarkerIcon!,
        ),
      );
    }

    if (widget.markers != null) {
      markersList.addAll(
        List.generate(widget.markers!.length, (index) {
          final marker = widget.markers![index];
          BitmapDescriptor? icon;
          switch (marker.size) {
            case MapMarkerSize.small:
              icon = marker.isSelected
                  ? _smallMarkerSelectedIcon
                  : _smallMarkerDeselectedIcon;
              break;
            case MapMarkerSize.medium:
              icon = marker.isSelected
                  ? _mediumMarkerSelectedIcon
                  : _mediumMarkerDeselectedIcon;
              break;
            case MapMarkerSize.large:
              icon = marker.isSelected
                  ? _largeMarkerSelectedIcon
                  : _largeMarkerDeselectedIcon;
              break;
          }

          if (icon != null) {
            return Marker(
              markerId: MarkerId(marker.id),
              position: marker.position,
              icon: icon,
              infoWindow: InfoWindow(
                title: marker.title,
                snippet: marker.description,
              ),
              onTap: () {
                if (widget.onMarkerTapped != null) {
                  widget.onMarkerTapped!(marker);
                }
              },
            );
          }

          return null;
        }).whereType<Marker>().toList(),
      );
    }

    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      initialCameraPosition: CameraPosition(target: _center, zoom: widget.zoom),
      markers: Set.from(markersList),
      zoomControlsEnabled: true,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      mapType: MapType.normal,
      style: r'''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''',
    );
  }
}

class AppMarker {
  final String id;
  final LatLng position;
  final MapMarkerSize size;
  final bool isSelected;
  final String? title;
  final String? description;

  AppMarker({
    required this.id,
    required this.position,
    this.size = MapMarkerSize.small,
    this.isSelected = false,
    this.title,
    this.description,
  });
}
