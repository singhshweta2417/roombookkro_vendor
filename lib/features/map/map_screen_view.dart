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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).setInitialLocation();
      print("dsjbcjsb");
    });
    searchAddress.addListener(() {
      print("yaha tk aa raha h");
      _debouncer.run(() async {
        String query = searchAddress.text;
        if (query.isNotEmpty) {
          print("635 aa raha h");
          await ref.read(mapProvider.notifier).getAddressSuggestions(query);
        } else {
          print("08029 aa raha h");
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
    print(mapState.addressText);
    print(searchAddress.text);
    print("searchAddress.text");
    return CustomScaffold(
      padding: EdgeInsets.zero,
      backgroundColor: AppColors.background(ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(mapProvider.notifier).setLocation();
        },
        backgroundColor: AppColors.secondary(ref),
        child: Icon(Icons.my_location),
      ),
      bottomNavigationBar: SizedBox(
        height: context.sh * 0.16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: context.sh * 0.01),
            AppText(
              text: 'City: ${mapState.cityText}',
              fontSize: 16,
              fontType: FontType.bold,
            ),
            SizedBox(height: context.sh * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 8),
                TCustomContainer(
                  width: context.sw * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: context.sw * 0.01),
                  child: AppText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    text: mapState.addressText.isNotEmpty
                        ? mapState.addressText
                        : (searchAddress.text.isNotEmpty
                              ? searchAddress.text
                              : "Enter Location"),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.sh * 0.01),
            PrimaryButton(
              onTap: () {
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
          hints: [
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
            onTap: (LatLng position) {
              ref.read(mapProvider.notifier).addMarker(position);
              ref.read(mapProvider.notifier).moveToLocation(position);
              ref
                  .read(mapProvider.notifier)
                  .getAddressFromLatLngDirect(position);
            },
          ),
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
                        ref
                            .read(mapProvider.notifier)
                            .updateAddressText(selectedAddress);
                        var coordinates = await ref
                            .read(mapProvider.notifier)
                            .getCoordinatesFromAddress(selectedAddress);
                        if (coordinates != null) {
                          ref
                              .read(mapProvider.notifier)
                              .moveToLocation(coordinates);
                        }
                        ref.read(mapProvider.notifier).clearSuggestions();
                        _searchFocusNode.unfocus();
                      },
                    );
                  },
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
