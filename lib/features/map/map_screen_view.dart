import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import '../../core/widgets/animated_text_field.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/primary_button.dart';
import 'map_provider.dart';

class ChooseLocation extends ConsumerStatefulWidget {
  const ChooseLocation({super.key});

  @override
  ConsumerState<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends ConsumerState<ChooseLocation> {
  final TextEditingController searchAddress = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(milliseconds: 500);

    // ✅ Pass context to setInitialLocation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).setInitialLocation(context);
    });

    searchAddress.addListener(() {
      _debouncer.run(() async {
        String query = searchAddress.text;
        if (query.isNotEmpty) {
          await ref.read(mapProvider.notifier).getAddressSuggestions(query);
        } else {
          ref.read(mapProvider.notifier).clearSuggestions();
        }
      });
    });
  }

  @override
  void dispose() {
    searchAddress.dispose();
    _searchFocusNode.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    ref.read(mapProvider.notifier).setMapController(controller);
    final mapState = ref.read(mapProvider);
    if (mapState.currentLatLng != null) {
      ref.read(mapProvider.notifier).moveToLocation(mapState.currentLatLng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapProvider);

    return CustomScaffold(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.background(ref),

      // ✅ Updated FloatingActionButton with loading indicator
      floatingActionButton: FloatingActionButton(
        onPressed: mapState.isLoadingLocation
            ? null
            : () async {
          await ref.read(mapProvider.notifier).setLocation(context);
        },
        backgroundColor: mapState.isLoadingLocation
            ? Colors.grey
            : AppColors.secondary(ref),
        child: mapState.isLoadingLocation
            ? SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Icon(Icons.my_location),
      ),

      bottomNavigationBar: SizedBox(
        height: context.sh * 0.16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: context.sh * 0.01),

            // ✅ Show loading or city
            AppText(
              text: mapState.isLoadingLocation
                  ? 'Fetching location...'
                  : 'City: ${mapState.cityText.isNotEmpty ? mapState.cityText : "Select location"}',
              fontSize: 16,
              fontType: FontType.bold,
            ),

            SizedBox(height: context.sh * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  Icons.location_on,
                  color: mapState.isLoadingLocation ? Colors.grey : Colors.green,
                ),
                const SizedBox(width: 8),
                TCustomContainer(
                  width: context.sw * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: context.sw * 0.01),
                  child: mapState.isLoadingLocation
                      ? Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.secondary(ref),
                      ),
                    ),
                  )
                      : AppText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    text: mapState.addressText.isNotEmpty
                        ? mapState.addressText
                        : "Tap on map or search location",
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            SizedBox(height: context.sh * 0.01),

            PrimaryButton(
              isLoading: mapState.isLoadingLocation,
              onTap: () {
                // Validate data
                if (mapState.addressText.isEmpty ||
                    mapState.cityText.isEmpty ||
                    mapState.currentLatLng == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a location first'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Return data
                Navigator.pop(context, {
                  'address': mapState.addressText,
                  'city': mapState.cityText,
                  'state': mapState.stateText,
                  'country': mapState.countryText,
                  'pincode': mapState.pinCodeText,
                  'latitude': mapState.currentLatLng?.latitude,
                  'longitude': mapState.currentLatLng?.longitude,
                });
              },
              label: "Update Location",
              width: context.sw * 0.4,
              height: context.sh * 0.05,
              fontSize: 15,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      ),

      appBar: CustomAppBar(
        backgroundColor: AppColors.secondary(ref),
        leadingIconColor: Colors.white,
        showActions: true,
        middle: AnimatedHintTextField(
          controller: searchAddress,
          focusNode: _searchFocusNode,
          fillColor: AppColors.background(ref),
          hints: const [
            "Search Your Location",
            "Enter city or locality",
            "e.g., New Delhi",
            "e.g., MG Road, Bangalore",
          ],
        ),
      ),

      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: mapState.markers,
            onTap: (LatLng position) async {
              ref.read(mapProvider.notifier).addMarker(position);
              ref.read(mapProvider.notifier).moveToLocation(position);
              await ref
                  .read(mapProvider.notifier)
                  .getAddressFromLatLngDirect(position);
            },
          ),

          // Suggestions list
          if (mapState.addressSuggestions.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: mapState.addressSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(mapState.addressSuggestions[index]),
                      onTap: () async {
                        String selectedAddress =
                        mapState.addressSuggestions[index];

                        searchAddress.text = selectedAddress;

                        var coordinates = await ref
                            .read(mapProvider.notifier)
                            .getCoordinatesFromAddress(selectedAddress);

                        if (coordinates != null) {
                          ref
                              .read(mapProvider.notifier)
                              .moveToLocation(coordinates);

                          ref.read(mapProvider.notifier).addMarker(coordinates);

                          await ref
                              .read(mapProvider.notifier)
                              .getAddressFromLatLngDirect(coordinates);
                        }

                        ref.read(mapProvider.notifier).clearSuggestions();
                        _searchFocusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),

          // ✅ Loading overlay when fetching location
          if (mapState.isLoadingLocation)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.secondary(ref),
                        ),
                        SizedBox(height: 15),
                        AppText(
                          text: "Fetching your location...",
                          fontSize: 14,
                          fontType: FontType.medium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  VoidCallback? _callback;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback callback) {
    _callback = callback;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), _fire);
  }

  void _fire() {
    _callback?.call();
  }

  void dispose() {
    _timer?.cancel();
  }
}