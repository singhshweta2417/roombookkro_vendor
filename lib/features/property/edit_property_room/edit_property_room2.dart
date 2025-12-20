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
import 'package:room_book_kro_vendor/features/property/property_room/add_property_room2.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../view_model/amenities_property_view_model.dart';

class EditPropertyScreen2 extends ConsumerStatefulWidget {
  const EditPropertyScreen2({super.key});

  @override
  ConsumerState<EditPropertyScreen2> createState() => _EditPropertyScreen2State();
}

class _EditPropertyScreen2State extends ConsumerState<EditPropertyScreen2> {
  final picker = ImagePicker();

  Map<String, dynamic>? arguments;
  AddPropertyListData? existingPropertyData;

  int _currentStep = 0;

  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountCont = TextEditingController();
  final _oldMrpController = TextEditingController();
  final _depositCont = TextEditingController();
  final _propertyMonthController = TextEditingController();
  final _propertyNightController = TextEditingController();
  final _propertyDayController = TextEditingController();

  // Rules Controllers
  final _ruleController = TextEditingController();
  List<String> propertyRules = [];

  List<File> mainImage = [];
  List<File> propertyImages = [];

  Map<String, String> selectedAmenities = {};

  bool isAvailable = false;
  bool _isFormInitialized = false;

  @override
  void initState() {
    super.initState();
    _oldMrpController.addListener(_calculatePrice);
    _discountCont.addListener(_calculatePrice);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getAmenitiesPropertyProvider.notifier).getAmenitiesPropertyViewApi();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (arguments == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        setState(() {
          arguments = args;
          existingPropertyData = args['existingPropertyData'] as AddPropertyListData?;
        });
      }
    }
  }

  void _initializeFormWithData() {
    if (existingPropertyData == null || _isFormInitialized) return;

    _websiteController.text = existingPropertyData?.website?.toString() ?? '';
    _descriptionController.text = existingPropertyData?.description?.toString() ?? '';
    _discountCont.text = existingPropertyData?.discount?.toString() ?? '';
    _oldMrpController.text = existingPropertyData?.oldMrp?.toString() ?? '';
    _depositCont.text = existingPropertyData?.depositAmount?.toString() ?? '';
    _propertyMonthController.text = existingPropertyData?.pricePerMonth?.toString() ?? '';
    _propertyNightController.text = existingPropertyData?.pricePerNight?.toString() ?? '';
    _propertyDayController.text = existingPropertyData?.pricePerDay?.toString() ?? '';

    // Initialize rules
    if (existingPropertyData?.rules != null && existingPropertyData!.rules!.isNotEmpty) {
      propertyRules = existingPropertyData!.rules!.map((rule) => rule.toString()).toList();
    }

    isAvailable = existingPropertyData?.isAvailable ?? false;

    setState(() {
      _isFormInitialized = true;
    });
  }

  // VALIDATION FOR STEP
  bool _validateStep(int step) {
    if (step == 0) {
      // Price validation
      if (_oldMrpController.text.isEmpty || _discountCont.text.isEmpty) {
        _showSnackBar("Please fill MRP and Discount fields");
        return false;
      }
      final selectedPropertyTypeId = arguments?["selectedPropertyTypeId"];

      if (selectedPropertyTypeId == 1 && _propertyNightController.text.isEmpty) {
        _showSnackBar("Please fill Price / Night");
        return false;
      } else if ((selectedPropertyTypeId == 3 || selectedPropertyTypeId == 4) &&
          _propertyMonthController.text.isEmpty) {
        _showSnackBar("Please fill Price / Month and Deposit Amount");
        return false;
      }
    } else if (step == 1) {
      // Image and description validation
      if (_descriptionController.text.isEmpty) {
        _showSnackBar("Please add a description");
        return false;
      }
    } else if (step == 2) {
      // Facilities validation (optional but recommended)
      if (selectedAmenities.isEmpty) {
        _showSnackBar("Please select at least one facility");
        return false;
      }
    }
    // Step 3 (Rules) can be optional
    return true;
  }

  void _onStepContinue() {
    if (_currentStep < 3) {
      if (_validateStep(_currentStep)) {
        setState(() => _currentStep++);
      }
    } else {
      _submitForm();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _addRule() {
    if (_ruleController.text.trim().isNotEmpty) {
      setState(() {
        propertyRules.add(_ruleController.text.trim());
        _ruleController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Rule added successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      _showSnackBar("Please enter a rule");
    }
  }

  void _removeRule(int index) {
    setState(() {
      propertyRules.removeAt(index);
    });
  }

  void _submitForm() {
    if (arguments == null) return;

    final amenityIds = selectedAmenities.keys.join(",");

    Navigator.pushNamed(
      context,
      AppRoutes.finalEditScreenProperty,
      arguments: {
        "propertyId": arguments!["propertyId"],
        "propertyTitle": arguments!["name"],
        "coordinates": arguments!["coordinates"],
        "pincode": arguments!["pincode"],
        "state": arguments!["state"],
        "city": arguments!["city"],
        "address": arguments!["address"],
        "additionalAddress": arguments!["additionalAddress"],
        "selectedPropertyType": arguments!["selectedPropertyType"],
        "selectedPropertyTypeId": arguments!["selectedPropertyTypeId"],
        "flatNo": arguments!["flatNo"],
        "website": _websiteController.text,
        "description": _descriptionController.text,
        "discount": _discountCont.text,
        "oldMrp": _oldMrpController.text,
        "depositAmount": _depositCont.text,
        "amenities": amenityIds,
        "propertyDayPrice": _propertyDayController.text,
        "propertyNightPrice": _propertyNightController.text,
        "propertyMonthPrice": _propertyMonthController.text,
        "availability": isAvailable,
        "mainImage": mainImage,
        "propertyImages": propertyImages,
        "propertyRules": propertyRules,
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

  double calculatedPrice = 0.0;
  void _calculatePrice() {
    final oldMrp = double.tryParse(_oldMrpController.text) ?? 0.0;
    final discount = double.tryParse(_discountCont.text) ?? 0.0;
    if (oldMrp > 0 && discount >= 0 && discount <= 100) {
      final discountAmount = (oldMrp * discount) / 100;
      final finalPrice = oldMrp - discountAmount;
      setState(() {
        calculatedPrice = finalPrice;
        final selectedPropertyTypeId = arguments?["selectedPropertyTypeId"];
        if (selectedPropertyTypeId == 1) {
          _propertyNightController.text = finalPrice.toStringAsFixed(0);
        } else if (selectedPropertyTypeId == 3 || selectedPropertyTypeId == 4) {
          _propertyMonthController.text = finalPrice.toStringAsFixed(0);
        } else {
          _propertyMonthController.text = finalPrice.toStringAsFixed(0);
        }
      });
    } else {
      setState(() {
        calculatedPrice = 0.0;
        _propertyNightController.clear();
        _propertyDayController.clear();
        _propertyMonthController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (arguments == null || existingPropertyData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedPropertyTypeId = arguments!["selectedPropertyTypeId"];
    final amenitiesState = ref.watch(getAmenitiesPropertyProvider);

    // Initialize form when amenities load
    if (amenitiesState is GetAmenitiesPropertySuccess && !_isFormInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFormWithData();

        // Pre-select amenities
        if (existingPropertyData?.amenities != null) {
          for (var amenity in existingPropertyData!.amenities!) {
            final amenityId = amenity.sId ?? '';
            final amenityName = amenity.name ?? '';
            if (amenityId.isNotEmpty && amenityName.isNotEmpty) {
              selectedAmenities[amenityId] = amenityName;
            }
          }
          setState(() {});
        }
      });
    }

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Edit Property",
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
              final isLast = _currentStep == 3;
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: isLast ? "Submit" : "Next",
                        onTap: details.onStepContinue,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.secondary(ref),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: AppText(
                            text: "Back",
                            color: AppColors.secondary(ref),
                            fontType: FontType.semiBold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: AppText(
                  text: "Show Price For User*",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    const SizedBox(height: 10),
                    _field("MRP", _oldMrpController, num: true),
                    _field("Discount %", _discountCont, num: true),
                    if (selectedPropertyTypeId == 1)
                      _field("Price / Night", _propertyNightController, num: true)
                    else if (selectedPropertyTypeId == 3 || selectedPropertyTypeId == 4) ...[
                      _field("Price / Month", _propertyMonthController, num: true),
                      _field("Deposit Amount", _depositCont, num: true),
                    ] else ...[
                      _field("Price / Day", _propertyDayController, num: true),
                      _field("Price / Month", _propertyMonthController, num: true),
                      _field("Deposit Amount", _depositCont, num: true),
                    ],
                  ],
                ),
              ),
              Step(
                title: AppText(
                  text: "Property Images*",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    const SizedBox(height: 10),
                    _imageSection(),
                    _field("Description", _descriptionController, multi: true),
                  ],
                ),
              ),
              Step(
                title: AppText(
                  text: "Website & Facilities*",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.sh * 0.01),
                    _field("Website", _websiteController),
                    const AppText(text: "Facilities", fontType: FontType.bold),
                    const SizedBox(height: 10),
                    amenitiesState.when(
                      initial: () => const Center(
                        child: AppText(
                          text: "Loading facilities...",
                          color: Colors.grey,
                        ),
                      ),
                      loading: () => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: AppColors.secondary(ref),
                          ),
                        ),
                      ),
                      success: (amenitiesModel, message) {
                        if (amenitiesModel.data == null || amenitiesModel.data!.isEmpty) {
                          return const Center(
                            child: AppText(
                              text: "No facilities available",
                              color: Colors.grey,
                            ),
                          );
                        }
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: amenitiesModel.data!.map((amenity) {
                            final isSelected = selectedAmenities.containsKey(amenity.sId ?? '');
                            return FilterChip(
                              selectedColor: AppColors.secondary(ref),
                              backgroundColor: Colors.grey.shade100,
                              checkmarkColor: Colors.white,
                              avatar: amenity.icon != null && amenity.icon!.isNotEmpty
                                  ? CircleAvatar(
                                backgroundColor: AppColors.secondary(ref),
                                child: CachedNetworkImage(
                                  imageUrl: amenity.icon.toString(),
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(strokeWidth: 1),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.image_not_supported,
                                    size: 24,
                                  ),
                                ),
                              )
                                  : null,
                              label: AppText(
                                text: amenity.name ?? 'Unknown',
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    selectedAmenities[amenity.sId ?? ''] = amenity.name ?? '';
                                  } else {
                                    selectedAmenities.remove(amenity.sId);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        );
                      },
                      error: (error) => Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppText(
                                    text: "Failed to load facilities",
                                    color: Colors.red.shade700,
                                    fontType: FontType.semiBold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            AppText(
                              text: error,
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                ref.read(getAmenitiesPropertyProvider.notifier).getAmenitiesPropertyViewApi();
                              },
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (selectedAmenities.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondary(ref).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.secondary(ref).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.secondary(ref),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              text: "${selectedAmenities.length} facilities selected",
                              fontSize: 14,
                              fontType: FontType.medium,
                              color: AppColors.secondary(ref),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Step(
                title: AppText(
                  text: "Property Rules",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 3,
                state: StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const AppText(
                      text: "Add rules for your property",
                      fontType: FontType.bold,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: "Example: No smoking, No pets, Quiet hours after 10 PM",
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ruleController,
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: "Enter a rule",
                              hintText: "e.g., No smoking allowed",
                              labelStyle: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400, width: 1.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.secondary(ref), width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: AppColors.background(ref),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            onSubmitted: (_) => _addRule(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondary(ref),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary(ref).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _addRule,
                            icon: const Icon(Icons.add, color: Colors.white),
                            tooltip: "Add Rule",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (propertyRules.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.rule_outlined, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              AppText(
                                text: "No rules added yet",
                                fontType: FontType.semiBold,
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 4),
                              AppText(
                                text: "Add rules to inform guests about property guidelines",
                                fontSize: 13,
                                color: Colors.grey.shade500,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondary(ref).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.secondary(ref).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: AppColors.secondary(ref), size: 20),
                                const SizedBox(width: 8),
                                AppText(
                                  text: "${propertyRules.length} rules added",
                                  fontSize: 14,
                                  fontType: FontType.medium,
                                  color: AppColors.secondary(ref),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...propertyRules.asMap().entries.map((entry) {
                            final index = entry.key;
                            final rule = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary(ref).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      color: AppColors.secondary(ref),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppText(
                                      text: rule,
                                      fontSize: 14,
                                      fontType: FontType.medium,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeRule(index),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade400,
                                      size: 22,
                                    ),
                                    tooltip: "Remove Rule",
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            _infoRow('Available Rooms', existingPropertyData?.availableRooms?.toString() ?? 'N/A'),
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
            width: 130,
            child: AppText(
              text: '$label:',
              fontType: FontType.medium,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          Expanded(
            child: AppText(
              text: value,
              fontType: FontType.regular,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Widget _imageSection() {
  //   return Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //       const AppText(text: "Main Image", fontType: FontType.bold),
  //   const SizedBox(height: 8),
  //   if (mainImage.isEmpty && existingPropertyData?.mainImage != null)
  //   Column(
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: [
  //   const AppText(
  //   text: 'Current Main Image:',
  //   fontSize: 12,
  //   color: Colors.grey,
  //   fontType: FontType.medium,
  //   ),
  //   const SizedBox(height: 8),
  //   ClipRRect(
  //   borderRadius: BorderRadius.circular(8),
  //   child: CachedNetworkImage(
  //   imageUrl: existingPropertyData!.mainImage!,
  //   height: 180,
  //   width: double.infinity,
  //   fit: BoxFit.cover,
  //   placeholder: (context, url) => Container(
  //   height: 180,
  //   color: Colors.grey.shade200,
  //   child: const Center(child: CircularProgressIndicator()),
  //   ),
  //   errorWidget: (context, url, error) => Container(
  //   height: 180,
  //   color: Colors.grey.shade200,
  //   child: const Icon(Icons.error),

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
