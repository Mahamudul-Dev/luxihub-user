import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/maps_config.dart';
import '../../../../core/domain/entities/job_request.dart';
import '../../../../core/theme/app_colors.dart';

class JobTrackingMap extends StatefulWidget {
  final JobRequest job;
  const JobTrackingMap({super.key, required this.job});

  @override
  State<JobTrackingMap> createState() => _JobTrackingMapState();
}

class _JobTrackingMapState extends State<JobTrackingMap> {
  GoogleMapController? _mapController;

  LatLng? _clientPosition;
  LatLng? _providerPosition;
  List<LatLng> _routePoints = [];

  StreamSubscription<Position>? _locationSub;
  StreamSubscription<List<Map<String, dynamic>>>? _providerSub;

  bool _fetchingRoute = false;
  LatLng? _lastFetchedProviderPos;

  // Only re-fetch route when provider moves more than this distance (meters).
  static const double _rerouteThreshold = 50;

  static const _clientMarkerId = MarkerId('client');
  static const _providerMarkerId = MarkerId('provider');
  static const _routePolylineId = PolylineId('route');

  @override
  void initState() {
    super.initState();
    _clientPosition = LatLng(widget.job.clientLat, widget.job.clientLng);
    _startClientTracking();
    if (widget.job.providerId != null) {
      _startProviderTracking(widget.job.providerId!);
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _providerSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Location streams ───────────────────────────────────────────────────────

  Future<void> _startClientTracking() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      if (!mounted) return;
      setState(() => _clientPosition = LatLng(pos.latitude, pos.longitude));
      // Re-fetch route when client moves (destination changed).
      _fetchRoute(force: true);
    });
  }

  void _startProviderTracking(String providerId) {
    _providerSub = Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', providerId)
        .listen((rows) {
          if (rows.isEmpty || !mounted) return;
          final row = rows.first;
          final lat = (row['service_lat'] as num?)?.toDouble();
          final lng = (row['service_lng'] as num?)?.toDouble();
          if (lat == null || lng == null) return;
          setState(() => _providerPosition = LatLng(lat, lng));
          _fetchRoute();
        });
  }

  // ── Directions API ─────────────────────────────────────────────────────────

  Future<void> _fetchRoute({bool force = false}) async {
    if (_providerPosition == null || _clientPosition == null) return;
    if (_fetchingRoute) return;

    // Skip if provider hasn't moved enough (unless forced).
    if (!force && _lastFetchedProviderPos != null) {
      final moved = Geolocator.distanceBetween(
        _lastFetchedProviderPos!.latitude,
        _lastFetchedProviderPos!.longitude,
        _providerPosition!.latitude,
        _providerPosition!.longitude,
      );
      if (moved < _rerouteThreshold) return;
    }

    setState(() => _fetchingRoute = true);
    _lastFetchedProviderPos = _providerPosition;

    try {
      final result = await PolylinePoints().getRouteBetweenCoordinates(
        googleApiKey: MapsConfig.googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(
              _providerPosition!.latitude, _providerPosition!.longitude),
          destination: PointLatLng(
              _clientPosition!.latitude, _clientPosition!.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (!mounted) return;

      if (result.points.isNotEmpty) {
        setState(() {
          _routePoints =
              result.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
        });
        _fitBounds();
      }
    } catch (_) {
      // Silently fall back to straight-line polyline.
    } finally {
      if (mounted) setState(() => _fetchingRoute = false);
    }
  }

  // ── Camera ─────────────────────────────────────────────────────────────────

  void _fitBounds() {
    if (_mapController == null) return;
    if (_clientPosition == null || _providerPosition == null) return;

    // Fit to all route points for the most accurate view; fall back to endpoints.
    final points = _routePoints.isNotEmpty
        ? _routePoints
        : [_clientPosition!, _providerPosition!];

    final lats = points.map((p) => p.latitude);
    final lngs = points.map((p) => p.longitude);

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(lats.reduce(min), lngs.reduce(min)),
          northeast: LatLng(lats.reduce(max), lngs.reduce(max)),
        ),
        80,
      ),
    );
  }

  // ── Map objects ────────────────────────────────────────────────────────────

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};
    if (_clientPosition != null) {
      markers.add(Marker(
        markerId: _clientMarkerId,
        position: _clientPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'You'),
      ));
    }
    if (_providerPosition != null) {
      markers.add(Marker(
        markerId: _providerMarkerId,
        position: _providerPosition!,
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: widget.job.providerName ?? 'Provider'),
      ));
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (_clientPosition == null || _providerPosition == null) return {};

    // Use real road route when available; show a thin dashed line while loading.
    final hasRoute = _routePoints.isNotEmpty;
    return {
      Polyline(
        polylineId: _routePolylineId,
        points: hasRoute ? _routePoints : [_providerPosition!, _clientPosition!],
        color: hasRoute ? AppColors.primary : Colors.grey,
        width: hasRoute ? 5 : 2,
        geodesic: !hasRoute,
        patterns: hasRoute ? [] : [PatternItem.dash(12), PatternItem.gap(8)],
      ),
    };
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  double? _distanceKm() {
    if (_clientPosition == null || _providerPosition == null) return null;
    return Geolocator.distanceBetween(
          _clientPosition!.latitude,
          _clientPosition!.longitude,
          _providerPosition!.latitude,
          _providerPosition!.longitude,
        ) /
        1000;
  }

  String _formatDistance(double km) => km < 1
      ? '${(km * 1000).toStringAsFixed(0)} m away'
      : '${km.toStringAsFixed(1)} km away';

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final distanceKm = _distanceKm();
    final initialTarget =
        _clientPosition ?? LatLng(widget.job.clientLat, widget.job.clientLng);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // ── Google Map ─────────────────────────────────────────────────
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _fitBounds();
            },
            initialCameraPosition:
                CameraPosition(target: initialTarget, zoom: 14),
            markers: _buildMarkers(),
            polylines: _buildPolylines(),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // ── Distance badge ─────────────────────────────────────────────
          if (distanceKm != null)
            Positioned(
              top: 12,
              left: 60,
              right: 60,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car_rounded,
                          size: 15, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        _formatDistance(distanceKm),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── LIVE / loading badge ───────────────────────────────────────
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _fetchingRoute
                    ? Colors.orange.shade600
                    : Colors.green.shade600,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_fetchingRoute)
                    const SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: Colors.white),
                    )
                  else
                    const Icon(Icons.circle, color: Colors.white, size: 7),
                  const SizedBox(width: 4),
                  Text(
                    _fetchingRoute ? 'ROUTING' : 'LIVE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
