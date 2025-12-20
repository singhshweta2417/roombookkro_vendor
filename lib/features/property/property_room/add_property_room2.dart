import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_text_field.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/model/amenities_model.dart';
import '../view_model/amenities_property_view_model.dart';

class AddPropertyRoom2 extends ConsumerStatefulWidget {
  const AddPropertyRoom2({super.key});

  @override
  ConsumerState<AddPropertyRoom2> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyRoom2> {
  final picker = ImagePicker();

  int _currentStep = 0;

  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountCont = TextEditingController();
  final _oldMrpController = TextEditingController();
  final _depositCont = TextEditingController();
  final _propertyMonthController = TextEditingController();
  final _propertyNightController = TextEditingController();
  final _propertyDayController = TextEditingController();

  final _ruleController = TextEditingController();
  List<String> propertyRules = [];
  String? selectedPricingType;
  List<File> mainImage = [];
  List<File> propertyImages = [];

  Map<String, String> selectedAmenities = {};

  bool isAvailable = false;
  late final int selectedPropertyType;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      selectedPropertyType = args?["selectedPropertyTypeId"] ?? 2;
      ref
          .read(getAmenitiesPropertyProvider.notifier)
          .getAmenitiesPropertyViewApi();
    });
    _oldMrpController.addListener(_calculatePrice);
    _discountCont.addListener(_calculatePrice);
  }

  bool _validateStep(int step) {
      if (step == 0) {
        if (mainImage.isEmpty) {
          _showSnackBar("Please select a main image");
          return false;
        }
        if (propertyImages.isEmpty) {
          _showSnackBar("Please add at least one property image");
          return false;
        }
        if (_descriptionController.text.isEmpty) {
          _showSnackBar("Please add a description");
          return false;
        }
      } else if (step == 1) {
      if (selectedAmenities.isEmpty) {
        _showSnackBar("Please select at least one facility");
        return false;
      }
    }
    return true;
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
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
        content: AppText(text:message,fontType: FontType.medium),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final amenityIds = selectedAmenities.keys.join(",");
    Navigator.pushNamed(
      context,
      AppRoutes.addRoomProperty,
      arguments: {
        "propertyTitle": args["name"],
        "coordinates": args["coordinates"],
        "pincode": args["pincode"],
        "state": args["state"],
        "city": args["city"],
        "address": args["address"],
        "additionalAddress": args["additionalAddress"],
        "selectedPropertyTypeId": args["selectedPropertyTypeId"],
        "flatNo": args["flatNo"],
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
        if (selectedPropertyType == 1) {
          _propertyNightController.text = finalPrice.toStringAsFixed(0);
        } else if (selectedPropertyType == 3 || selectedPropertyType == 4) {
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
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final selectedPropertyType = args["selectedPropertyTypeId"];
    final amenitiesState = ref.watch(getAmenitiesPropertyProvider);
    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Add Property More",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
      ),
      child: ListView(
        children: [
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
              final isLast = _currentStep == 2;
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
                  text: "Property Images*",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 0,
                state: _currentStep > 0? StepState.complete : StepState.indexed,
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
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
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
                        if (amenitiesModel.data == null ||
                            amenitiesModel.data!.isEmpty) {
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
                            final isSelected = selectedAmenities.containsKey(
                              amenity.sId ?? '',
                            );
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                    ),
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
                                    selectedAmenities[amenity.sId ?? ''] =
                                        amenity.name ?? '';
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
                                ref
                                    .read(getAmenitiesPropertyProvider.notifier)
                                    .getAmenitiesPropertyViewApi();
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
                isActive: _currentStep >= 2,
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

                    // Rule Input Field
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
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade400,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.4,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.secondary(ref),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: AppColors.background(ref),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
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

                    // Display Added Rules
                    if (propertyRules.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.rule_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
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
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.secondary(ref),
                                  size: 20,
                                ),
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

  Widget _imageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(text: "Main Image", fontType: FontType.bold),
        const SizedBox(height: 8),
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
                AppText(text: "Select Image", color: Colors.grey),
              ],
            )
                : Image.file(mainImage.first, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 10),
        const AppText(text: "Property Images", fontType: FontType.bold),
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
                      child: CircleAvatar(
                        backgroundColor: AppColors.secondary(ref),
                        radius: 10,
                        child: const Icon(Icons.close, size: 12, color: Colors.white),
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

  @override
  void dispose() {
    _websiteController.dispose();
    _descriptionController.dispose();
    _discountCont.dispose();
    _oldMrpController.dispose();
    _depositCont.dispose();
    _propertyMonthController.dispose();
    _propertyNightController.dispose();
    _propertyDayController.dispose();
    _ruleController.dispose();
    super.dispose();
  }
}

extension GetAmenitiesPropertyStateExtension on GetAmenitiesPropertyState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(AmenitiesModel amenitiesModel, String message) success,
    required T Function(String error) error,
  }) {
    if (this is GetAmenitiesPropertyInitial) {
      return initial();
    } else if (this is GetAmenitiesPropertyLoading) {
      return loading();
    } else if (this is GetAmenitiesPropertySuccess) {
      final state = this as GetAmenitiesPropertySuccess;
      return success(state.amenitiesPropertyLists, state.message);
    } else if (this is GetAmenitiesPropertyError) {
      final state = this as GetAmenitiesPropertyError;
      return error(state.error);
    }
    return initial();
  }
}