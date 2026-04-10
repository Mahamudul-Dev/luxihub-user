import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../config/utils.dart';
import '../theme/app_colors.dart';

class MapPlaceholderWidget extends StatelessWidget {
  const MapPlaceholderWidget({
    super.key,

    // Location
    this.latitude = 51.5074,   // defaults to London
    this.longitude = -0.1278,

    // Appearance
    this.height,
    this.borderRadius,
    this.initialZoom = 14.0,
    this.pinColor,
    this.pinSize = 40,
    this.interactive = false,
  });

  /// Latitude of the pin. Defaults to London.
  final double latitude;

  /// Longitude of the pin. Defaults to London.
  final double longitude;

  final double? height;
  final double? borderRadius;

  /// Map zoom level (1–18). Defaults to 14.
  final double initialZoom;

  /// Color of the location pin. Defaults to [AppColors.primary].
  final Color? pinColor;
  final double pinSize;

  /// Set to true to allow panning/zooming. False by default (display only).
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitude, longitude);
    final radius = borderRadius ?? Utils.defaultBorderRadius * 2;

    final map = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: initialZoom,
          interactionOptions: InteractionOptions(
            flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.luxihub_user',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: pinSize,
                height: pinSize,
                child: Icon(
                  Icons.location_on,
                  color: pinColor ?? AppColors.primary,
                  size: pinSize,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (height != null) {
      return SizedBox(height: height, child: map);
    }
    return map;
  }
}
