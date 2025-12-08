import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_text_field.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/property/property_model.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class EditPropertyScreen2 extends ConsumerStatefulWidget {
  const EditPropertyScreen2({super.key});

  @override
  ConsumerState<EditPropertyScreen2> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<EditPropertyScreen2> {
  final picker = ImagePicker();

  // ✅ Store arguments and existing property data
  Map<String, dynamic>? arguments;
  Data? existingPropertyData;

  int _currentStep = 0;

  final _websiteController = TextEditingController();
  final _roomsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountCont = TextEditingController();
  final _oldMrpController = TextEditingController();
  final _depositCont = TextEditingController();
  final _propertyMonthController = TextEditingController();
  final _propertyNightController = TextEditingController();
  final _propertyDayController = TextEditingController();

  String? selectedPricingType;

  List<File> mainImage = [];
  List<File> propertyImages = [];

  Map<String, bool> amenitiesMap = {
    "Parking": false,
    "Swimming": false,
    "Kids Area": false,
    "Restaurant": false,
    "Hospital": false,
    "School": false,
  };

  bool isAvailable = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (arguments == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        setState(() {
          arguments = args;
          existingPropertyData = args['existingPropertyData'] as Data?;
          _initializeFormWithData();
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: AppText(text: 'Data not found', color: Colors.white),
            ),
          );
        });
      }
    }
  }

  // ✅ Pre-fill form with existing property data
  void _initializeFormWithData() {
    if (existingPropertyData == null) return;

    // Pre-fill controllers
    _websiteController.text = existingPropertyData?.website?.toString() ?? '';
    _roomsController.text =
        existingPropertyData?.availableRooms?.toString() ?? '';
    _descriptionController.text =
        existingPropertyData?.description?.toString() ?? '';
    _discountCont.text = existingPropertyData?.discount?.toString() ?? '';
    _oldMrpController.text = existingPropertyData?.oldMrp?.toString() ?? '';
    _depositCont.text = existingPropertyData?.depositAmount?.toString() ?? '';
    _propertyMonthController.text =
        existingPropertyData?.pricePerMonth?.toString() ?? '';
    _propertyNightController.text =
        existingPropertyData?.pricePerNight?.toString() ?? '';
    _propertyDayController.text =
        existingPropertyData?.pricePerDay?.toString() ?? '';

    // Pre-fill amenities
    final existingAmenities = existingPropertyData?.amenities ?? [];
    for (var amenity in existingAmenities) {
      final amenityName = amenity.name?.toString();
      if (amenityName != null && amenitiesMap.containsKey(amenityName)) {
        amenitiesMap[amenityName] = true;
      }
    }

    // Pre-fill availability
    isAvailable = existingPropertyData?.isAvailable ?? false;
  }

  @override
  void dispose() {
    _websiteController.dispose();
    _roomsController.dispose();
    _descriptionController.dispose();
    _discountCont.dispose();
    _oldMrpController.dispose();
    _depositCont.dispose();
    _propertyMonthController.dispose();
    _propertyNightController.dispose();
    _propertyDayController.dispose();
    super.dispose();
  }

  // VALIDATION FOR STEP
  bool _validateStep(int step, BuildContext context) {
    if (step == 0) {
      if (_roomsController.text.isEmpty ||
          _descriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please fill all required fields"),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }
    }
    return true;
  }

  void _onStepContinue() {
    if (_currentStep < 1) {
      if (_validateStep(_currentStep, context)) {
        setState(() => _currentStep++);
      }
    } else {
      _submitForm();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitForm() {
    if (arguments == null) return;

    final selectedAmenities = amenitiesMap.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(",");

    Navigator.pushNamed(
      context,
      AppRoutes.finalEditScreenProperty,
      arguments: {
        // ✅ Pass property ID for update
        "propertyId": arguments!["propertyId"],
        // From Screen 1
        "propertyTitle": arguments!["name"],
        "coordinates": arguments!["coordinates"],
        "pincode": arguments!["pincode"],
        "state": arguments!["state"],
        "city": arguments!["city"],
        "address": arguments!["address"],
        "selectedPropertyType": arguments!["selectedPropertyType"],
        "flatNo": arguments!["flatNo"],
        "additionalAddress": arguments!["additionalAddress"],
        // From Screen 2 (current)
        "website": _websiteController.text,
        "roomCount": _roomsController.text,
        "description": _descriptionController.text,
        "discount": _discountCont.text,
        "oldMrp": _oldMrpController.text,
        "depositAmount": _depositCont.text,
        "amenities": selectedAmenities,
        "propertyDayPrice": _propertyDayController.text,
        "propertyNightPrice": _propertyNightController.text,
        "propertyMonthPrice": _propertyMonthController.text,
        "availability": isAvailable,
        "mainImage": mainImage,
        "propertyImages": propertyImages,
        // ✅ Pass existing property data to next screen
        "existingPropertyData": existingPropertyData,
      },
    );
  }

  Future<void> selectMainImage() async {
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => mainImage = [File(img.path)]);
    }
  }

  Future<void> pickPropertyImages() async {
    try {
      final picked = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked.isNotEmpty) {
        setState(() {
          propertyImages.addAll(picked.map((e) => File(e.path)));
        });
      }
    } catch (e) {
      print("Failed to pick images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (arguments == null || existingPropertyData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final selectedPropertyType = arguments!["selectedPropertyType"];
    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Edit Property - Step 2",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
      ),
      child: ListView(
        children: [
          _buildExistingDataCard(),
          Stepper(
            currentStep: _currentStep,
            onStepContinue: _onStepContinue,
            onStepCancel: _onStepCancel,
            physics: const NeverScrollableScrollPhysics(),
            connectorColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.secondary(ref);
              }
              return Colors.grey;
            }),
            controlsBuilder: (context, details) {
              final isLast = _currentStep == 1;

              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: isLast ? "Next" : "Next", // Changed from Submit
                        onTap: details.onStepContinue,
                      ),
                    ),
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const AppText(text: "Back"),
                        ),
                      ),
                  ],
                ),
              );
            },

            steps: [
              Step(
                title: const AppText(
                  text: "Property Details*",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  children: [
                    const SizedBox(height: 10),

                    if (selectedPropertyType == "Hotel")
                      _field(
                        "Price / Night",
                        _propertyNightController,
                        num: true,
                      ),

                    if (selectedPropertyType == "Flat" ||
                        selectedPropertyType == "PG") ...[
                      _field(
                        "Price / Month",
                        _propertyMonthController,
                        num: true,
                      ),
                      _field("Deposit Amount", _depositCont, num: true),
                    ],

                    if (selectedPropertyType == "Resort") ...[
                      _field("Price / Day", _propertyDayController, num: true),
                      _field(
                        "Price / Month",
                        _propertyMonthController,
                        num: true,
                      ),
                      _field("Deposit Amount", _depositCont, num: true),
                    ],

                    _imageSection(),
                    _field("Available Rooms", _roomsController, num: true),
                    _field("Description", _descriptionController, multi: true),
                    _field("Old MRP", _oldMrpController, num: true),
                    _field("Discount %", _discountCont, num: true),
                  ],
                ),
              ),

              Step(
                title: const AppText(
                  text: "Property Website and Amenities*",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 1,
                state: StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.sh * 0.01),
                    _field("Website", _websiteController),

                    const AppText(text: "Amenities", fontType: FontType.bold),

                    Wrap(
                      spacing: 10,
                      children: amenitiesMap.keys.map((label) {
                        return FilterChip(
                          selectedColor: AppColors.secondary(ref),
                          label: AppText(text: label),
                          selected: amenitiesMap[label]!,
                          onSelected: (v) =>
                              setState(() => amenitiesMap[label] = v),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExistingDataCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.secondary(ref)),
                const SizedBox(width: 8),
                const AppText(
                  text: 'Editing Property',
                  fontType: FontType.bold,
                  fontSize: 16,
                ),
              ],
            ),
            const Divider(),
            _infoRow('Property Name', arguments?['name'] ?? 'N/A'),
            _infoRow('Type', arguments?['selectedPropertyType'] ?? 'N/A'),
            _infoRow('City', arguments?['city'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: AppText(
              text: '$label:',
              fontType: FontType.medium,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: AppText(text: value, fontType: FontType.regular),
          ),
        ],
      ),
    );
  }

  Widget _imageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(text: "Main Image", fontType: FontType.bold),
        const SizedBox(height: 8),

        // ✅ Show existing main image if available
        if (mainImage.isEmpty && existingPropertyData?.mainImage != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                text: 'Current Main Image:',
                fontSize: 12,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  existingPropertyData!.mainImage!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

        GestureDetector(
          onTap: selectMainImage,
          child: TCustomContainer(
            padding: const EdgeInsets.all(8),
            height: 180,
            width: double.infinity,
            border: Border.all(),
            borderRadius: BorderRadius.circular(8),
            child: mainImage.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo),
                      AppText(text: "Select New Image", color: Colors.grey),
                    ],
                  )
                : Image.file(mainImage.first, fit: BoxFit.cover),
          ),
        ),

        const SizedBox(height: 10),
        const AppText(text: "Property Images", fontType: FontType.bold),

        // ✅ Show existing property images
        if (propertyImages.isEmpty &&
            existingPropertyData?.images?.isNotEmpty == true)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const AppText(
                text: 'Current Images:',
                fontSize: 12,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: existingPropertyData!.images!.map((imageUrl) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      height: 90,
                      width: 90,
                      fit: BoxFit.cover,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),

        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children: [
            ...propertyImages.map(
              (file) => Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file,
                      height: 90,
                      width: 90,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => propertyImages.remove(file)),
                      child: const CircleAvatar(
                        radius: 10,
                        child: Icon(Icons.close, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: pickPropertyImages,
              child: TCustomContainer(
                margin: const EdgeInsets.symmetric(vertical: 10),
                height: 90,
                width: 90,
                border: Border.all(),
                borderRadius: BorderRadius.circular(8),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    Widget? suffixIcon,
    bool num = false,
    bool multi = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextField(
        controller: c,
        minLines: multi ? 3 : 1,
        maxLines: multi ? 5 : 1,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        labelText: label,
        suffixIcon: suffixIcon,
        customBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.4),
        ),
        fillColor: AppColors.background(ref),
      ),
    );
  }
}
