import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/features/property/view_model/add_property_view_model.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/model/amenities_model.dart';
import '../../auth/model/get_enum_model.dart';
import '../view_model/amenities_room_view_model.dart';
import '../view_model/get_property_type_view_model.dart';
import '../view_model/room_type_view_model.dart';

class AddRoomBottomSheet extends ConsumerStatefulWidget {
  final dynamic propertyType;
  final Map<int, List<String>> subTypeList;
  final RoomData? initialRoom;

  const AddRoomBottomSheet({
    super.key,
    this.propertyType,
    required this.subTypeList,
    this.initialRoom,
  });

  @override
  ConsumerState<AddRoomBottomSheet> createState() => _AddRoomBottomSheetState();
}

class _AddRoomBottomSheetState extends ConsumerState<AddRoomBottomSheet> {
  final ImagePicker picker = ImagePicker();

  String? selectedSubType;
  String selectedFurnished = "";
  final _occupancyCont = TextEditingController();
  final _availableUnitsCont = TextEditingController();
  final _roomPriceController = TextEditingController();
  final _roomPriceDayController = TextEditingController();
  bool isRoomAvailable = true;
  List<File> roomImages = [];
  Map<String, String> selectedRoomAmenities = {};

  @override
  void initState() {
    super.initState();

    if (widget.initialRoom != null) {
      final r = widget.initialRoom!;
      selectedSubType = r.roomType;
      selectedFurnished = r.furnished;
      _occupancyCont.text = r.occupancy;
      _availableUnitsCont.text = r.availableUnits;
      _roomPriceController.text = r.price;
      _roomPriceDayController.text = r.roomPricePerDay;
      isRoomAvailable = r.isAvailable;
      roomImages = List<File>.from(r.roomImages);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getAmenitiesRoomProvider.notifier).getAmenitiesRoomViewApi();
      ref.read(getPropertyTypeProvider.notifier).propertyTypeApi();
    });
  }
  String? selectedSubTypeId;
  Future<void> pickRoomImages() async {
    try {
      final picked = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked.isNotEmpty) {
        setState(() => roomImages.addAll(picked.map((e) => File(e.path))));
      }
    } catch (e) {
      print("Pick images error: $e");
    }
  }

  void _removeImage(File f) => setState(() => roomImages.remove(f));

  IconData _getFurnishedIcon(String label) {
    if (label.toLowerCase().contains('fully')) return Icons.weekend;
    if (label.toLowerCase().contains('semi')) return Icons.chair_outlined;
    if (label.toLowerCase().contains('non')) return Icons.home_outlined;
    return Icons.weekend;
  }

  @override
  Widget build(BuildContext context) {
    final int propertyTypeId = widget.propertyType is int
        ? widget.propertyType
        : int.tryParse(widget.propertyType.toString()) ?? 0;

    final availableSubtypes = widget.subTypeList[propertyTypeId] ?? [];
    final roomAmenitiesState = ref.watch(getAmenitiesRoomProvider);
    final propertyTypeState = ref.watch(getPropertyTypeProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(ref),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle & Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.sw * 0.04,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary(ref).withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary(ref).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.initialRoom == null
                            ? Icons.add_home
                            : Icons.edit,
                        color: AppColors.secondary(ref),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            text: widget.initialRoom == null
                                ? "Add New Room"
                                : "Edit Room",
                            fontType: FontType.bold,
                            fontSize: 20,
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            text: "Fill in the details below",
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.sw * 0.04,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Section
                  if (availableSubtypes.isNotEmpty) ...[
                    _buildSectionLabel("Room Category", true),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.category_outlined,
                            color: AppColors.secondary(ref),
                          ),
                          hintText: "Select category",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        initialValue: selectedSubType,
                        items: availableSubtypes
                            .map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: AppText(text: e, fontSize: 15),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSubType = value;
                            final roomTypeState = ref.read(getRoomTypeProvider);
                            if (roomTypeState is GetRoomTypeSuccess) {
                              final matchingOption = roomTypeState.roomType.options?.firstWhere(
                                    (opt) => opt.label == value,
                                orElse: () => RoomTypeOption(),
                              );
                              selectedSubTypeId = matchingOption?.id?.toString();
                              print("Selected Label: $value");
                              print("Selected ID: $selectedSubTypeId");
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildSectionLabel("Furnished Type", true),
                  const SizedBox(height: 12),
                  _buildFurnishedOptions(propertyTypeState),

                  const SizedBox(height: 20),

                  // Occupancy & Units Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("Available Units", true),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _availableUnitsCont,
                              hint: "e.g., 5",
                              icon: Icons.home_work_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel("Occupancy", true),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _occupancyCont,
                              hint: "e.g., 2",
                              icon: Icons.people_outline,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Pricing Section
                  _buildSectionLabel("Pricing", true),
                  const SizedBox(height: 8),
                  if (propertyTypeId == 1)
                    _buildTextField(
                      controller: _roomPriceController,
                      hint: "per night",
                      icon: Icons.currency_rupee,
                    )
                  else ...[
                    _buildTextField(
                      controller: _roomPriceController,
                      hint: "Monthly rent",
                      icon: Icons.currency_rupee,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _roomPriceDayController,
                      hint: "Daily rate (optional)",
                      icon: Icons.calendar_today_outlined,
                    )
                  ],

                  const SizedBox(height: 24),

                  // Room Amenities
                  _buildSectionLabel("Room Facilities", false),
                  const SizedBox(height: 12),
                  roomAmenitiesState.when(
                    initial: () => _buildLoadingState(),
                    loading: () => _buildLoadingState(),
                    success: (amenitiesModel, message) {
                      if (amenitiesModel.data == null ||
                          amenitiesModel.data!.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: amenitiesModel.data!.map((amenity) {
                            final isSelected = selectedRoomAmenities
                                .containsKey(amenity.sId ?? '');

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedRoomAmenities.remove(amenity.sId);
                                  } else {
                                    selectedRoomAmenities[amenity.sId ?? ''] =
                                        amenity.name ?? '';
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.secondary(ref)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.secondary(ref)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 6),
                                        child: Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    AppText(
                                      text: amenity.name ?? 'Unknown',
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade800,
                                      fontSize: 13,
                                      fontType: isSelected
                                          ? FontType.medium
                                          : FontType.regular,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                    error: (error) => _buildErrorState(ref),
                  ),

                  const SizedBox(height: 24),

                  // Room Images
                  _buildSectionLabel("Room Images", false),
                  const SizedBox(height: 4),
                  AppText(
                    text: "Add photos to showcase your room",
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ...roomImages.map((file) => _buildImageCard(file)),
                        _buildAddImageCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.sw * 0.04,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.background(ref),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary(ref),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.initialRoom == null
                          ? Icons.add_circle_outline
                          : Icons.check_circle_outline,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    AppText(
                      text: widget.initialRoom == null
                          ? "Save Room"
                          : "Update Room",
                      color: Colors.white,
                      fontType: FontType.semiBold,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build Furnished Options based on state
  Widget _buildFurnishedOptions(GetPropertyTypeState state) {
    if (state is GetPropertyTypeLoading || state is GetPropertyTypeInitial) {
      return _buildFurnishedLoading();
    }

    if (state is GetPropertyTypeError) {
      return _buildFurnishedError();
    }

    if (state is GetPropertyTypeSuccess) {
      final furnishedOptions =
          state.propertyType.data?.furnishedType?.options ?? [];

      if (furnishedOptions.isEmpty) {
        return _buildFurnishedEmpty();
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: furnishedOptions
            .where((option) => option.isActive == true)
            .map((option) {
          final label = option.label ?? '';
          final value = option.value ?? '';
          final icon = _getFurnishedIcon(label);
          final sel = selectedFurnished == value;

          return InkWell(
            onTap: () => setState(() => selectedFurnished = value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: sel ? AppColors.secondary(ref) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sel
                      ? AppColors.secondary(ref)
                      : Colors.grey.shade300,
                  width: sel ? 2 : 1,
                ),
                boxShadow: sel
                    ? [
                  BoxShadow(
                    color: AppColors.secondary(ref)
                        .withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: sel ? Colors.white : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  AppText(
                    text: label,
                    color: sel ? Colors.white : Colors.grey.shade800,
                    fontType:
                    sel ? FontType.semiBold : FontType.medium,
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }

    return _buildFurnishedEmpty();
  }

  Widget _buildSectionLabel(String text, bool required) {
    return Row(
      children: [
        AppText(text: text, fontType: FontType.semiBold, fontSize: 15),
        if (required) ...[
          const SizedBox(width: 4),
          const AppText(
            text: "*",
            color: Colors.red,
            fontType: FontType.bold,
            fontSize: 16,
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.secondary(ref), size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // Furnished Type Loading State
  Widget _buildFurnishedLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.secondary(ref),
              ),
            ),
            const SizedBox(width: 12),
            AppText(
              text: "Loading options...",
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }

  // Furnished Type Empty State
  Widget _buildFurnishedEmpty() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: AppText(
          text: "No furnished options available",
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }

  // Furnished Type Error State
  Widget _buildFurnishedError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              text: "Failed to load furnished options",
              color: Colors.red.shade700,
              fontSize: 13,
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(getPropertyTypeProvider.notifier).propertyTypeApi();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(File file) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: GestureDetector(
            onTap: () => _removeImage(file),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.secondary(ref),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageCard() {
    return InkWell(
      onTap: pickRoomImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.secondary(ref),
              size: 32,
            ),
            const SizedBox(height: 4),
            AppText(
              text: "Add",
              fontSize: 12,
              color: Colors.grey.shade600,
              fontType: FontType.medium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.secondary(ref),
              ),
            ),
            const SizedBox(height: 12),
            AppText(
              text: "Loading amenities...",
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            AppText(
              text: "No amenities available",
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: "Failed to load amenities",
                  color: Colors.red.shade700,
                  fontType: FontType.semiBold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(getAmenitiesRoomProvider.notifier)
                    .getAmenitiesRoomViewApi();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    print(selectedSubTypeId);
    print("selectedSubTypeId");
    if (selectedSubTypeId == null ||
        selectedFurnished.isEmpty ||
        _occupancyCont.text.trim().isEmpty ||
        _availableUnitsCont.text.trim().isEmpty ||
        _roomPriceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: AppText(
                  text: "Please fill all required fields",
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    List<String> selectedAmenitiesIds = selectedRoomAmenities.keys.toList();

    final roomData = RoomData(
      roomType: selectedSubTypeId!,
      roomTypeName:selectedSubType!,
      furnished: selectedFurnished,
      occupancy: _occupancyCont.text.trim(),
      price: _roomPriceController.text.trim(),
      roomPricePerDay: _roomPriceDayController.text.trim(),
      isAvailable: isRoomAvailable,
      availableUnits: _availableUnitsCont.text.trim(),
      amenitiesIds: selectedAmenitiesIds,
      roomImages: roomImages,
    );

    Navigator.of(context).pop(roomData);
  }

  @override
  void dispose() {
    _occupancyCont.dispose();
    _availableUnitsCont.dispose();
    _roomPriceController.dispose();
    _roomPriceDayController.dispose();
    super.dispose();
  }
}

///

// ✅ Extension for state handling
extension GetAmenitiesRoomStateExtension on GetAmenitiesRoomState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(AmenitiesModel amenitiesModel, String message) success,
    required T Function(String error) error,
  }) {
    if (this is GetAmenitiesRoomInitial) {
      return initial();
    } else if (this is GetAmenitiesRoomLoading) {
      return loading();
    } else if (this is GetAmenitiesRoomSuccess) {
      final state = this as GetAmenitiesRoomSuccess;
      return success(state.amenitiesRoomLists, state.message);
    } else if (this is GetAmenitiesRoomError) {
      final state = this as GetAmenitiesRoomError;
      return error(state.error);
    }
    return initial();
  }
}