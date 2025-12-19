import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_text_field.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/property/property_model.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/model/get_enum_model.dart';
import '../view_model/get_property_type_view_model.dart';

class EditPropertyScreen1 extends ConsumerStatefulWidget {
  const EditPropertyScreen1({super.key});

  @override
  ConsumerState<EditPropertyScreen1> createState() => _EditPropertyScreen1State();
}

class _EditPropertyScreen1State extends ConsumerState<EditPropertyScreen1> {
  final picker = ImagePicker();
  AddPropertyListData? propertyData;
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _additionalController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _addressCont = TextEditingController();

  int _currentStep = 0;
  String? selectedPropertyType;
  int? selectedPropertyTypeId;
  String? latitude;
  String? longitude;
  bool _isFormInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getPropertyTypeProvider.notifier).propertyTypeApi();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (propertyData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args != null && args is AddPropertyListData) {
        setState(() {
          propertyData = args;
          selectedPropertyType = args.type?.toString();
          selectedPropertyTypeId = args.propertyTypeId;
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property data not found')),
          );
        });
      }
    }
  }

  void _initializeFormWithData() {
    if (propertyData == null || _isFormInitialized) return;
    _titleController.text = propertyData?.name?.toString() ?? '';
    _addressCont.text = propertyData?.address?.toString() ?? '';
    _cityController.text = propertyData?.city?.toString() ?? '';
    _stateController.text = propertyData?.state?.toString() ?? '';
    _pinCodeController.text = propertyData?.pincode?.toString() ?? '';
    _additionalController.text = propertyData?.additionalAddress?.toString() ?? '';

    latitude = propertyData?.coordinates?.lat?.toString() ?? '';
    longitude = propertyData?.coordinates?.lng?.toString() ?? '';

    setState(() {
      _isFormInitialized = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _additionalController.dispose();
    _pinCodeController.dispose();
    _addressCont.dispose();
    super.dispose();
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(text: msg, color: Colors.white),
        backgroundColor: Colors.red,
      ),
    );
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        if (selectedPropertyType == null) {
          _error("Please select property type");
          return false;
        }
        if (_titleController.text.trim().isEmpty) {
          _error("Please enter Property Title");
          return false;
        }
        break;

      case 1:
        if (_addressCont.text.trim().isEmpty) {
          _error("Please enter Address");
          return false;
        }
        if (_cityController.text.trim().isEmpty) {
          _error("Please enter City");
          return false;
        }
        if (_stateController.text.trim().isEmpty) {
          _error("Please enter State");
          return false;
        }
        if (_pinCodeController.text.trim().isEmpty) {
          _error("Please enter Pincode");
          return false;
        } else if (_pinCodeController.text.length != 6) {
          _error("Pincode must be 6 digits");
          return false;
        }
        break;
    }
    return true;
  }

  void _onStepContinue() {
    if (_currentStep < 1) {
      if (_validateStep(_currentStep)) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      _submitForm();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitForm() {
    if (_validateStep(1)) {
      final coordinates = {
        "lat": double.tryParse(latitude ?? '') ??
            propertyData?.coordinates?.lat ?? 30.076,
        "lng": double.tryParse(longitude ?? '') ??
            propertyData?.coordinates?.lng ?? 75.8777,
      };

      Navigator.pushNamed(
        context,
        AppRoutes.editPropertyScreen2,
        arguments: {
          "propertyId": propertyData?.residencyId,
          "name": _titleController.text.trim(),
          "coordinates": coordinates,
          "selectedPropertyType": selectedPropertyType,
          "selectedPropertyTypeId": selectedPropertyTypeId,
          "pincode": _pinCodeController.text.trim(),
          "state": _stateController.text.trim(),
          "city": _cityController.text.trim(),
          "address": _addressCont.text.trim(),
          "additionalAddress": _additionalController.text.trim(),
          "existingPropertyData": propertyData,
        },
      );

      print("Property ID: ${propertyData?.sId}");
      print("Name: ${_titleController.text.trim()}");
      print("Type: $selectedPropertyType (ID: $selectedPropertyTypeId)");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (propertyData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final propertyTypeState = ref.watch(getPropertyTypeProvider);

    // ✅ Initialize form when API loads successfully
    if (propertyTypeState is GetPropertyTypeSuccess && !_isFormInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeFormWithData();

        // ✅ Match property type with API options
        final options = propertyTypeState.propertyType.data?.propertyType?.options ?? [];

        // Remove duplicates first
        final seenValues = <String>{};
        final uniqueOptions = options.where((opt) =>
        opt.isActive == true &&
            (opt.value?.isNotEmpty ?? false) &&
            seenValues.add(opt.value!)
        ).toList();

        PropertyTypeOption? matchingOption;

        // Try to find by propertyTypeId first
        if (propertyData?.propertyTypeId != null) {
          matchingOption = uniqueOptions.firstWhere(
                (opt) => opt.id == propertyData?.propertyTypeId,
            orElse: () => PropertyTypeOption(),
          );
        }

        // If not found by ID, try matching by type string (case-insensitive)
        if (matchingOption?.id == null && selectedPropertyType != null) {
          matchingOption = uniqueOptions.firstWhere(
                (opt) => opt.value?.toLowerCase() == selectedPropertyType?.toLowerCase(),
            orElse: () => PropertyTypeOption(),
          );
        }

        if (matchingOption?.id != null) {
          setState(() {
            selectedPropertyType = matchingOption?.value;
            selectedPropertyTypeId = matchingOption?.id;
          });
          print("✅ Property type matched: ${matchingOption?.value} (ID: ${matchingOption?.id})");
        } else {
          print("⚠️ No matching property type found for: $selectedPropertyType");
          print("Available types: ${uniqueOptions.map((e) => e.value).toList()}");
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
        padding: EdgeInsets.only(top: context.sh * 0.01),
        children: [
          SizedBox(height: context.sh * 0.01),
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
            stepIconBuilder: (index, state) {
              final bool isCompleted = state == StepState.complete;
              return Container(
                height: 25,
                width: 25,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.secondary(ref)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? AppColors.secondary(ref) : Colors.grey,
                    width: 1,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Center(
                  child: AppText(
                    text: "${index + 1}",
                    fontSize: AppConstants.twelve,
                  ),
                ),
              );
            },
            controlsBuilder: (context, details) {
              final isLastStep = _currentStep == 1;
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: isLastStep ? 'Next' : 'Next',
                        onTap: details.onStepContinue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: const AppText(text: 'Back'),
                        ),
                      ),
                  ],
                ),
              );
            },
            steps: [
              // ================================
              // STEP 1 - PROPERTY DETAILS
              // ================================
              Step(
                title: const AppText(
                  text: 'Property Details*',
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 0,
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    const SizedBox(height: 10),

                    // ⭐ Property Type Dropdown
                    if (propertyTypeState is GetPropertyTypeLoading)
                      Center(
                        child: CircularProgressIndicator(
                          color: AppColors.secondary(ref),
                        ),
                      )
                    else if (propertyTypeState is GetPropertyTypeError)
                      Column(
                        children: [
                          AppText(
                            text: propertyTypeState.error,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(getPropertyTypeProvider.notifier)
                                  .propertyTypeApi();
                            },
                            child: const AppText(text: "Retry"),
                          ),
                        ],
                      )
                    else if (propertyTypeState is GetPropertyTypeSuccess)
                        _dropdownWithId(
                          title: "Select Property Type",
                          value: selectedPropertyType,
                          options: propertyTypeState.propertyType.data?.propertyType?.options ?? [],
                          onChange: (value, id) => setState(() {
                            selectedPropertyType = value;
                            selectedPropertyTypeId = id;
                          }),
                        )
                      else
                        _dropdownWithId(
                          title: "Select Property Type",
                          value: selectedPropertyType,
                          options: [],
                          onChange: (value, id) => setState(() {
                            selectedPropertyType = value;
                            selectedPropertyTypeId = id;
                          }),
                        ),

                    // Property Title
                    field(
                      "Property Title",
                      _titleController,
                      keyboard: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.home_work_outlined),
                      ),
                      suffix: true,
                    ),
                  ],
                ),
              ),

              // ================================
              // STEP 2 - ADDRESS
              // ================================
              Step(
                title: const AppText(
                  text: "Address*",
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 1,
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.sh * 0.01),

                    // Address Field
                    GestureDetector(
                      onTap: _selectLocation,
                      child: AbsorbPointer(
                        child: field(
                          readOnly: true,
                          "Address",
                          _addressCont,
                          suffixIcon: const Icon(Icons.location_on_outlined),
                          suffix: true,
                          keyboard: TextInputType.streetAddress,
                        ),
                      ),
                    ),

                    field(
                      readOnly: true,
                      "City",
                      _cityController,
                      suffixIcon: const Icon(Icons.location_city_outlined),
                      suffix: true,
                    ),

                    field(
                      readOnly: true,
                      "State",
                      _stateController,
                      suffixIcon: const Icon(Icons.map_outlined),
                      suffix: true,
                    ),

                    field(
                      readOnly: true,
                      "Pincode",
                      _pinCodeController,
                      suffixIcon: const Icon(Icons.pin_outlined),
                      suffix: true,
                    ),

                    field(
                      "Additional Address (Optional)",
                      _additionalController,
                      suffixIcon: const Icon(Icons.flag_circle_outlined),
                      suffix: true,
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.sh * 0.02),
        ],
      ),
    );
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.pushNamed(context, AppRoutes.chooseLocation);

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _addressCont.text = result['address'] ?? '';
        _cityController.text = result['city'] ?? '';
        _stateController.text = result['state'] ?? '';
        _pinCodeController.text = result['pincode'] ?? '';
        latitude = result['latitude']?.toString() ?? '';
        longitude = result['longitude']?.toString() ?? '';
      });
    }
  }

  Widget field(
      String label,
      TextEditingController c, {
        Widget? suffixIcon,
        bool multi = false,
        bool suffix = false,
        TextInputType keyboard = TextInputType.text,
        TextCapitalization textCapitalization = TextCapitalization.none,
        bool readOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextField(
        controller: c,
        maxLength: multi ? 10 : 100,
        keyboardType: keyboard,
        labelText: label,
        readOnly: readOnly,
        suffixIcon: suffix && suffixIcon != null ? suffixIcon : null,
        textCapitalization: textCapitalization,
        customBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.4),
        ),
        fillColor: AppColors.background(ref),
      ),
    );
  }

  Widget _dropdownWithId({
    required String title,
    required String? value,
    required List<PropertyTypeOption> options,
    required Function(String?, int?) onChange,
  }) {
    // ✅ Filter active options and remove duplicates
    final seenValues = <String>{};
    final activeOptions = options
        .where((opt) =>
    opt.isActive == true &&
        (opt.value?.isNotEmpty ?? false) &&
        seenValues.add(opt.value!)  // Remove duplicates
    )
        .toList();

    // ✅ Check if current value exists in active options
    final valueExists = activeOptions.any(
          (opt) => opt.value == value,
    );

    // ✅ Use null if value doesn't exist
    final effectiveValue = valueExists ? value : null;

    // ✅ Debug print
    if (!valueExists && value != null) {
      print("⚠️ Value '$value' not found in options");
      print("Available options: ${activeOptions.map((e) => e.value).toList()}");
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: title,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.4),
          ),
          fillColor: AppColors.background(ref),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.secondary(ref),
              width: 1.4,
            ),
          ),
        ),
        value: effectiveValue,
        items: activeOptions.isEmpty
            ? null
            : activeOptions
            .map(
              (option) => DropdownMenuItem<String>(
            value: option.value,
            child: Row(
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 18,
                  color: AppColors.secondary(ref),
                ),
                const SizedBox(width: 8),
                AppText(
                  text: option.label ?? option.value ?? '',
                  fontSize: AppConstants.fourteen,
                ),
              ],
            ),
          ),
        )
            .toList(),
        onChanged: activeOptions.isEmpty
            ? null
            : (selectedValue) {
          final selectedOption = activeOptions.firstWhere(
                (option) => option.value == selectedValue,
            orElse: () => PropertyTypeOption(),
          );
          onChange(selectedValue, selectedOption.id);
          print("✅ Selected: ${selectedOption.label} (ID: ${selectedOption.id})");
        },
        hint: activeOptions.isEmpty
            ? const AppText(text: "Loading...")
            : const AppText(text: "Choose property type"),
      ),
    );
  }
}