import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
    );
  }
}

/// ------------------ NOTIFIER CLASS ------------------
class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(MapState());

  late GoogleMapController mapController;

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
  }

  void clearSuggestions() {
    if (_disposed) return;
    _safeSetState(state.copyWith(addressSuggestions: []));
  }

  Future<void> getAddressSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey'));
    if (_disposed) return;
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final suggestions = List<String>.from(
            data['predictions'].map((e) => e['description']));
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
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey'));

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

  Future<void> setInitialLocation() async {
    if (_disposed) return;
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            currentLocationText: "Permission denied",
            addressText: "Permission denied",
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          currentLocationText: "Permission permanently denied",
          addressText: "Permission permanently denied",
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (_disposed) return;
      // Get placemark/address
      final placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      final combined = [
        placemarks.first.street,
        placemarks.first.subLocality,
        placemarks.first.locality,
        placemarks.first.administrativeArea,
        placemarks.first.country,
        placemarks.first.postalCode,
      ].where((c) => c != null && c.isNotEmpty).join(', ');

      // Update both fields
      state = state.copyWith(
        currentLatLng: LatLng(position.latitude, position.longitude),
        currentLocationText: combined.isNotEmpty ? combined : "Address not available",
        addressText: combined.isNotEmpty ? combined : "Address not available",
      );
    } catch (e) {
      print("Error fetching location/address: $e");
      state = state.copyWith(
        currentLocationText: "Address not available",
        addressText: "Address not available",
      );
    }
  }


  Future<void> setLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        addressText: "Location Permission Denied",
        cityText: "City not found",
        areaText: "Area not found",
        stateText: "State not found",
        countryText: "Country not found",
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Move to the current location
      moveToLocation(LatLng(position.latitude, position.longitude));

      // This will update all address components including city
      await getAddressFromLatLng(position);
    } catch (e) {
      state = state.copyWith(
        addressText: "Error fetching location: $e",
        cityText: "City not found",
        areaText: "Area not found",
        stateText: "State not found",
        countryText: "Country not found",
      );
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void moveToLocation(LatLng position) {
    if (_disposed) return;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15.0),
      ),
    );
    addMarker(position);
  }

  void addMarker(LatLng position) {
    if (_disposed) return;
    final marker = Marker(
      markerId: MarkerId(position.toString()),
      position: position,
      infoWindow: const InfoWindow(title: 'Current Location'),
    );

    // पुराना marker हटाकर सिर्फ नया डालना
    state = state.copyWith(markers: {marker});
  }


  void updateLocationText(Position position) {
    state = state.copyWith(
        currentLocationText:
        "Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  }

  Future<void> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      final combined = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
        place.postalCode,
      ].where((c) => c != null && c.isNotEmpty).join(', ');

      state = state.copyWith(
        cityText: place.locality ?? "City not available",
        areaText: place.subLocality ?? "Area not available",
        stateText: place.administrativeArea ?? "State not available",
        countryText: place.country ?? "Country not available",
        addressText:
        combined.isNotEmpty ? combined : "Address not available",
        pinCodeText:
        place.postalCode != null ? place.postalCode! : "Pin Code not found",
      );
    } catch (e) {
      state = state.copyWith(
        addressText: "Address not found",
        pinCodeText: "Pin Code not found",
        cityText: "City not found",
        areaText: "Area not found",
        stateText: "State not found",
        countryText: "Country not found",
      );
    }
  }

  Future<void> getAddressFromLatLngDirect(LatLng position) async {
    if (_disposed) return;
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (_disposed) return;
      Placemark place = placemarks.first;

      final combined = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
        place.postalCode,
      ].where((c) => c != null && c.isNotEmpty).join(', ');

      state = state.copyWith(
        cityText: place.locality ?? "City not available",
        areaText: place.subLocality ?? "Area not available",
        stateText: place.administrativeArea ?? "State not available",
        countryText: place.country ?? "Country not available",
        addressText:
        combined.isNotEmpty ? combined : "Address not available",
        pinCodeText:
        place.postalCode != null ? place.postalCode! : "Pin Code not found",
      );
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        addressText: "Address not found",
        pinCodeText: "Pin Code not found",
        cityText: "City not found",
        areaText: "Area not found",
        stateText: "State not found",
        countryText: "Country not found",
      );
    }
  }

  Future<void> placeSearchApi(String searchCon) async {
    if (searchCon.isEmpty) return;

    Uri uri = Uri.https(
      "maps.googleapis.com",
      'maps/api/place/autocomplete/json',
      {
        "input": searchCon,
        "key": apiKey,
        "components": "country:in",
      },
    );

    var response = await http.get(uri);
    if (response.statusCode == 200) {
      final resData = jsonDecode(response.body)['predictions'];
      if (resData != null) {
        state = state.copyWith(placeData: resData);
      }
    } else {
      if (kDebugMode) {
        print('Error fetching suggestions: ${response.body}');
      }
    }
  }

  Future<void> getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['result'] != null) {
        final details = result['result'];
        if (details['geometry'] != null) {
          final lat = details['geometry']['location']['lat'];
          final lng = details['geometry']['location']['lng'];

          state = state.copyWith(
              selectedLocation: LatLng(lat, lng),
              addressText: details['formatted_address']);
        } else {
          throw Exception('Geometry not found in response');
        }
      } else {
        throw Exception('Result not found in response');
      }
    } else {
      throw Exception('Failed to load place details');
    }
  }

  void updateAddressText(String address) {
    state = state.copyWith(addressText: address);
  }
}

/// ------------------ PROVIDER ------------------
final mapProvider =
StateNotifierProvider<MapNotifier, MapState>((ref) => MapNotifier());