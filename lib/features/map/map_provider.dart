import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import '../../core/utils/context_extensions.dart';
import '../../core/widgets/app_text.dart';

/// ------------------ STATE CLASS ------------------
class MapState {
  final LatLng? currentLatLng;
  final List<String> addressSuggestions;
  final String currentLocationText;
  final String addressText;
  final String pinCodeText;
  final Set<Marker> markers;
  final List<dynamic> placeData;
  final LatLng? selectedLocation;
  final String cityText;
  final String areaText;
  final String stateText;
  final String countryText;
  final bool isLoadingLocation;

  MapState({
    this.currentLatLng,
    this.addressSuggestions = const [],
    this.currentLocationText = '',
    this.addressText = '',
    this.pinCodeText = '',
    this.markers = const {},
    this.placeData = const [],
    this.selectedLocation,
    this.cityText = '',
    this.areaText = '',
    this.stateText = '',
    this.countryText = '',
    this.isLoadingLocation = false,
  });

  MapState copyWith({
    LatLng? currentLatLng,
    List<String>? addressSuggestions,
    String? currentLocationText,
    String? addressText,
    String? pinCodeText,
    Set<Marker>? markers,
    List<dynamic>? placeData,
    LatLng? selectedLocation,
    String? cityText,
    String? areaText,
    String? stateText,
    String? countryText,
    bool? isLoadingLocation,
  }) {
    return MapState(
      currentLatLng: currentLatLng ?? this.currentLatLng,
      addressSuggestions: addressSuggestions ?? this.addressSuggestions,
      currentLocationText: currentLocationText ?? this.currentLocationText,
      addressText: addressText ?? this.addressText,
      pinCodeText: pinCodeText ?? this.pinCodeText,
      markers: markers ?? this.markers,
      placeData: placeData ?? this.placeData,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      cityText: cityText ?? this.cityText,
      areaText: areaText ?? this.areaText,
      stateText: stateText ?? this.stateText,
      countryText: countryText ?? this.countryText,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
    );
  }
}

/// ------------------ NOTIFIER CLASS ------------------
class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  // ✅ Changed to nullable to handle initialization properly
  GoogleMapController? mapController;

  final String apiKey = "AIzaSyANhzkw-SjvdzDvyPsUBDFmvEHfI9b8QqA";
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeSetState(MapState newState) {
    if (!_disposed) state = newState;
  }

  void setMapController(GoogleMapController controller) {
    if (_disposed) return;
    mapController = controller;
    debugPrint('✅ Map controller set');

    // ✅ If location already fetched, move camera
    if (state.currentLatLng != null) {
      debugPrint('🗺️ Location already available, moving camera...');
      moveToLocation(state.currentLatLng!);
    }
  }

  void clearSuggestions() {
    if (_disposed) return;
    _safeSetState(state.copyWith(addressSuggestions: []));
  }

  /// ✅ Check location permission with custom handling
  Future<bool> checkLocationPermission(BuildContext context) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      bool? shouldOpen = await _showLocationServiceDialog(context);
      if (shouldOpen == true) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Show rationale dialog
      bool? shouldRequest = await _showPermissionRationaleDialog(context);

      if (shouldRequest == true) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          await _showPermissionDeniedDialog(context);
          return false;
        }
      } else {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      bool? shouldOpenSettings = await _showPermissionPermanentlyDeniedDialog(
        context,
      );

      if (shouldOpenSettings == true) {
        await Geolocator.openAppSettings();
      }
      return false;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// ✅ FIXED: setInitialLocation with moveToLocation
  Future<void> setInitialLocation(BuildContext context) async {
    if (_disposed) return;

    state = state.copyWith(isLoadingLocation: true);

    try {
      debugPrint("🔄 Step 1: Checking location permissions...");

      // Check and request permission
      bool hasPermission = await checkLocationPermission(context);

      if (!hasPermission) {
        debugPrint("❌ Permission not granted");
        state = state.copyWith(
          isLoadingLocation: false,
          currentLocationText: "Permission denied",
          addressText: "Permission denied",
        );
        return;
      }

      debugPrint("🔄 Step 2: Getting current position...");

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          debugPrint("⏱️ Timeout, trying last known position...");
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) return lastPos;
          throw Exception('Could not get location');
        },
      );

      if (_disposed) return;

      debugPrint(
        "✅ Step 3: Position received: ${position.latitude}, ${position.longitude}",
      );

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      // ✅ Update state with location
      state = state.copyWith(currentLatLng: currentLocation);

      // ✅ Add marker
      addMarker(currentLocation);

      // ✅ Move map camera (this was missing!)
      moveToLocation(currentLocation);

      debugPrint("🔄 Step 4: Fetching address details...");

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (_disposed) return;

      if (placemarks.isEmpty) {
        debugPrint("⚠️ No placemarks found");
        state = state.copyWith(
          isLoadingLocation: false,
          currentLocationText: "Address not available",
          addressText: "Address not available",
        );
        return;
      }

      Placemark place = placemarks.first;

      final combined = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
        place.postalCode,
      ].where((c) => c != null && c.isNotEmpty).join(', ');

      debugPrint("✅ Step 5: Complete! Address: $combined");

      state = state.copyWith(
        isLoadingLocation: false,
        currentLocationText: combined.isNotEmpty
            ? combined
            : "Address not available",
        addressText: combined.isNotEmpty ? combined : "Address not available",
        cityText: place.locality ?? "City not available",
        areaText: place.subLocality ?? "Area not available",
        stateText: place.administrativeArea ?? "State not available",
        countryText: place.country ?? "Country not available",
        pinCodeText: place.postalCode ?? "Pin Code not available",
      );
    } catch (e, stackTrace) {
      debugPrint("❌ Error: $e");
      debugPrint("Stack trace: $stackTrace");
      state = state.copyWith(
        isLoadingLocation: false,
        currentLocationText: "Error: $e",
        addressText: "Error fetching location",
      );
    }
  }

  /// ✅ FIXED: setLocation with proper updates
  Future<void> setLocation(BuildContext context) async {
    if (_disposed) return;

    state = state.copyWith(isLoadingLocation: true);

    debugPrint("🔄 FAB: Refreshing location...");

    bool hasPermission = await checkLocationPermission(context);

    if (!hasPermission) {
      state = state.copyWith(
        isLoadingLocation: false,
        addressText: "Permission denied",
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          debugPrint("⏱️ Timeout, trying last known position...");
          final lastPos = await Geolocator.getLastKnownPosition();
          if (lastPos != null) return lastPos;
          throw Exception('Could not get location');
        },
      );

      if (_disposed) return;

      debugPrint("✅ FAB: Position: ${position.latitude}, ${position.longitude}");

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      // ✅ Update state
      state = state.copyWith(currentLatLng: currentLocation);

      // ✅ Add marker
      addMarker(currentLocation);

      // ✅ Move camera
      moveToLocation(currentLocation);

      // ✅ Get address
      await getAddressFromLatLngDirect(currentLocation);

      state = state.copyWith(isLoadingLocation: false);

      debugPrint("✅ FAB: Location updated successfully");
    } catch (e) {
      debugPrint("❌ FAB Error: $e");
      state = state.copyWith(
        isLoadingLocation: false,
        addressText: "Error fetching location",
      );
    }
  }

  // Permission Dialogs
  Future<bool?> _showLocationServiceDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text(
              'Location Off',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text('Please enable location services to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPermissionRationaleDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.location_on, color: Colors.green, size: 30),
            SizedBox(width: 10),
            AppText(
              text: 'Location Permission',
              fontSize: 18,
              fontType: FontType.bold,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: 'We need location access to:',
              fontType: FontType.medium,
            ),
            SizedBox(height: 10),
            _buildReason(Icons.pin_drop, 'Show your location on map'),
            _buildReason(Icons.search, 'Find nearby places'),
            _buildReason(Icons.navigation, 'Provide accurate addresses'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(text: 'Not Now', color: Colors.grey),
          ),
          PrimaryButton(
            width: context.sw * 0.2,
            onTap: () => Navigator.pop(context, true),
            label: "Allow",
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            AppText(
              text: 'Permission Denied',
              fontSize: 18,
              fontType: FontType.bold,
            ),
          ],
        ),
        content: AppText(
          text: 'Location permission is required. Please grant it when asked.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPermissionPermanentlyDeniedDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red, size: 30),
            SizedBox(width: 10),
            AppText(
              text: 'Permission Blocked',
              fontSize: 18,
              fontType: FontType.bold,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(text: 'Location permission is permanently denied.'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: AppText(
                text:
                'To enable:\n1. Go to Settings\n2. Tap Permissions\n3. Enable Location',
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(text: 'Cancel', color: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildReason(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          SizedBox(width: 10),
          Expanded(child: AppText(text: text, fontSize: 13)),
        ],
      ),
    );
  }

  // ✅ FIXED: moveToLocation with null check
  void moveToLocation(LatLng position) {
    if (_disposed) return;

    if (mapController == null) {
      debugPrint('⚠️ Map controller not ready yet, will move when ready');
      return;
    }

    try {
      debugPrint('🗺️ Moving camera to: ${position.latitude}, ${position.longitude}');
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 16.0),
        ),
      );
      debugPrint('✅ Camera moved successfully');
    } catch (e) {
      debugPrint('❌ Error moving camera: $e');
    }
  }

  // ✅ addMarker remains same
  void addMarker(LatLng position) {
    if (_disposed) return;
    debugPrint('📍 Adding marker at: ${position.latitude}, ${position.longitude}');

    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: const InfoWindow(title: 'Selected Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    state = state.copyWith(markers: {marker}, currentLatLng: position);

    debugPrint('✅ Marker added, total markers: ${state.markers.length}');
  }

  Future<void> getAddressFromLatLngDirect(LatLng position) async {
    if (_disposed) return;
    try {
      debugPrint('🔄 Getting address for: ${position.latitude}, ${position.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (_disposed) return;
      if (placemarks.isEmpty) {
        debugPrint('⚠️ No placemarks found');
        return;
      }

      Placemark place = placemarks.first;

      final combined = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
        place.postalCode,
      ].where((c) => c != null && c.isNotEmpty).join(', ');

      debugPrint('✅ Address: $combined');

      state = state.copyWith(
        cityText: place.locality ?? "City not available",
        areaText: place.subLocality ?? "Area not available",
        stateText: place.administrativeArea ?? "State not available",
        countryText: place.country ?? "Country not available",
        addressText: combined.isNotEmpty ? combined : "Address not available",
        pinCodeText: place.postalCode ?? "Pin Code not found",
      );
    } catch (e) {
      debugPrint("❌ Error getting address: $e");
    }
  }

  // Rest of methods remain same
  Future<void> getAddressSuggestions(String query) async {
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey',
      ),
    );
    if (_disposed) return;
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final suggestions = List<String>.from(
          data['predictions'].map((e) => e['description']),
        );
        state = state.copyWith(addressSuggestions: suggestions);
      } else {
        state = state.copyWith(addressSuggestions: []);
      }
    } else {
      state = state.copyWith(addressSuggestions: []);
    }
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    if (_disposed) return null;
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          double latitude = data['results'][0]['geometry']['location']['lat'];
          double longitude = data['results'][0]['geometry']['location']['lng'];
          return LatLng(latitude, longitude);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void updateAddressText(String address) {
    state = state.copyWith(addressText: address);
  }
}

/// ------------------ PROVIDER ------------------
final mapProvider = StateNotifierProvider<MapNotifier, MapState>(
      (ref) => MapNotifier(),
);