// ...existing code...
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionSub;

  Future<bool> _ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Starts foreground location tracking and updates Firestore doc for [userId].
  /// Returns the subscription so caller can cancel if needed.
  Future<StreamSubscription<Position>?> startTracking(
    String id, {
    int distanceFilterMeters = 10,
  }) async {
    final ok = await _ensurePermission();
    if (!ok) return null;

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: distanceFilterMeters,
    );

    _positionSub =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position pos) async {
            try {
              await FirebaseFirestore.instance.collection('users').doc(id).set({
                'location': {'lat': pos.latitude, 'lng': pos.longitude},
                'locationUpdatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
            } catch (e) {
              // optional: print or report error
              print('LocationService: failed to write location: $e');
            }
          },
          onError: (e) {
            print('LocationService stream error: $e');
          },
        );

    return _positionSub;
  }

  Future<void> stopTracking() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }
}
