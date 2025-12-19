import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_text_field.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../view_model/get_property_type_view_model.dart';
import '../../auth/model/get_enum_model.dart';

class AddPropertyScreen1 extends ConsumerStatefulWidget {
  const AddPropertyScreen1({super.key});

  @override
  ConsumerState<AddPropertyScreen1> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen1> {
  final picker = ImagePicker();

  // Controllers
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _additionalController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressCont = TextEditingController();

  int _currentStep = 0;
  String? selectedPropertyType;
  int? selectedPropertyTypeId;

  @override
  void initState() {
    super.initState();
    // Call API when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getPropertyTypeProvider.notifier).propertyTypeApi();
    });
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

      case 1: // Address validation
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
        if (_pincodeController.text.trim().isEmpty) {
          _error("Please enter Pincode");
          return false;
        } else if (_pincodeController.text.length != 6) {
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
        "lat": double.tryParse(latitude ?? '') ?? 30.076,
        "lng": double.tryParse(longitude ?? '') ?? 75.8777,
      };

      Navigator.pushNamed(
        context,
        AppRoutes.addPropertyRoom2,
        arguments: {
          "name": _titleController.text.trim(),
          "coordinates": coordinates,
          "selectedPropertyTypeId": selectedPropertyTypeId,
          "pincode": _pincodeController.text.trim(),
          "state": _stateController.text.trim(),
          "city": _cityController.text.trim(),
          "address": _addressCont.text.trim(),
          "additionalAddress": _additionalController.text.trim(),
        },
      );
      print(selectedPropertyTypeId);
      print("selectedPropertyTypeId");
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyTypeState = ref.watch(getPropertyTypeProvider);

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Add Property",
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
            physics: NeverScrollableScrollPhysics(),
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
                    ? Icon(Icons.check, color: Colors.white, size: 16)
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
                        label: isLastStep ? 'Submit' : 'Next',
                        onTap: details.onStepContinue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    if (_currentStep > 0) SizedBox(width: 12),
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          child: AppText(text: 'Back'),
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
                title: AppText(
                  text: 'Property Details*',
                  fontType: FontType.semiBold,
                ),
                isActive: _currentStep >= 0,
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                state: _currentStep > 0
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  children: [
                    SizedBox(height: 10),

                    // ⭐ PROPERTY TYPE DROPDOWN
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
                          SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(getPropertyTypeProvider.notifier)
                                  .propertyTypeApi();
                            },
                            child: AppText(text: "Retry"),
                          ),
                        ],
                      )
                    else if (propertyTypeState is GetPropertyTypeSuccess)
                      _dropdownWithId(
                        title: "Select Property Type",
                        value: selectedPropertyType,
                        options:
                            propertyTypeState
                                .propertyType
                                .data!
                                .propertyType!
                                .options ??
                            [],
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

                    /// PROPERTY TITLE
                    field(
                      "Property Title",
                      _titleController,
                      keyboard: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.home_work_outlined),
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
                title: AppText(text: "Address*", fontType: FontType.semiBold),
                isActive: _currentStep >= 1,
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                state: _currentStep > 1
                    ? StepState.complete
                    : StepState.indexed,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.sh * 0.01),

                    // Address field with location picker
                    GestureDetector(
                      onTap: _selectLocation,
                      child: AbsorbPointer(
                        child: field(
                          readOnly: true,
                          "Address",
                          _addressCont,
                          suffixIcon: Icon(Icons.location_on_outlined),
                          suffix: true,
                          keyboard: TextInputType.streetAddress,
                        ),
                      ),
                    ),

                    field(
                      readOnly: true,
                      "City",
                      _cityController,
                      suffixIcon: Icon(Icons.location_city_outlined),
                      suffix: true,
                    ),

                    field(
                      readOnly: true,
                      "State",
                      _stateController,
                      suffixIcon: Icon(Icons.map_outlined),
                      suffix: true,
                    ),

                    field(
                      readOnly: true,
                      "Pincode",
                      _pincodeController,
                      suffixIcon: Icon(Icons.pin_outlined),
                      suffix: true,
                    ),
                    field(
                      "Additional Address (Optional)",
                      _additionalController,
                      suffixIcon: Icon(Icons.flag_circle_outlined),
                      suffix: true,
                    ),

                    SizedBox(height: 10),
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

  String? latitude;
  String? longitude;

  Future<void> _selectLocation() async {
    final result = await Navigator.pushNamed(context, AppRoutes.chooseLocation);
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _addressCont.text = result['address'] ?? '';
        _cityController.text = result['city'] ?? '';
        _stateController.text = result['state'] ?? '';
        _pincodeController.text = result['pincode'] ?? '';
        latitude = result['latitude']?.toString() ?? '';
        longitude = result['longitude']?.toString() ?? '';
      });
    }
  }

  /// TextField Builder
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
        customBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey, width: 1.4),
        ),
        fillColor: AppColors.background(ref),
      ),
    );
  }

  /// ⭐ DROPDOWN WITH ID - Fixed to use PropertyTypeOption
  Widget _dropdownWithId({
    required String title,
    required String? value,
    required List<PropertyTypeOption> options,
    required Function(String?, int?) onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: title,
          labelStyle: TextStyle(color: Colors.grey),
          filled: true,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.4),
          ),
          fillColor: AppColors.background(ref),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.secondary(ref), width: 1.4),
          ),
        ),
        initialValue: value,
        items: options.isEmpty
            ? null
            : options
                  .where(
                    (option) =>
                        option.isActive == true &&
                        (option.value?.isNotEmpty ?? false),
                  )
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
                          SizedBox(width: 8),
                          AppText(
                            text: option.label ?? option.value ?? '',
                            fontSize: AppConstants.fourteen,
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        onChanged: options.isEmpty
            ? null
            : (selectedValue) {
                final selectedOption = options.firstWhere(
                  (option) => option.value == selectedValue,
                  orElse: () => PropertyTypeOption(),
                );
                onChange(selectedValue, selectedOption.id);
              },
        hint: options.isEmpty
            ? AppText(text: "Loading...")
            : AppText(text: "Choose property type"),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _additionalController.dispose();
    _pincodeController.dispose();
    _addressCont.dispose();
    super.dispose();
  }
}
