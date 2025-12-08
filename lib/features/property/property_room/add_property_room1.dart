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

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final picker = ImagePicker();

  // Controllers
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _flatNoController = TextEditingController();
  final _additionalController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressCont = TextEditingController();
  int _currentStep = 0;
  String? selectedPropertyType;

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
      case 0: // Basic info
        if (selectedPropertyType == null) {
          _error("Please select property type");
          return false;
        }
        if (_titleController.text.trim().isEmpty) {
          _error("Please enter Property Title");
          return false;
        }
        break;

      case 1: // Documents validation
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
      // This is the last step, handle form submission
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
          "selectedPropertyType": selectedPropertyType,
          "pincode": _pincodeController.text.trim(),
          "state": _stateController.text.trim(),
          "city": _cityController.text.trim(),
          "address": _addressCont.text.trim(),
          "flatNo":_flatNoController.text.trim(),
          "additionalAddress":_additionalController.text.trim(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Step(
                title: AppText(text: 'Property Details*', fontType: FontType.semiBold),
                isActive: _currentStep >= 0,
                stepStyle: StepStyle(color: AppColors.secondary(ref)),
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    SizedBox(height: 10),
                    _dropdown(
                      title: "Select Property Type",
                      value: selectedPropertyType,
                      items: ["Hotel", "Resort", "Apartment", "PG","Dormitory"],
                      onChange: (v) => setState(() {
                        selectedPropertyType = v;
                      }),
                    ),

                    /// PROPERTY TITLE
                    field(
                      "Property Title",
                      _titleController,
                      keyboard: TextInputType.name,
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.home_work_outlined),
                      ),
                      suffix: true,
                    ),
                  ],
                ),
              ),
              // -------------------------------
              // STEP 2 – DOCUMENTS
              // -------------------------------
              Step(
                title: AppText(text: "Address*", fontType: FontType.semiBold),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.sh*0.01),
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
                    if (selectedPropertyType != null) ...[
                      if (selectedPropertyType == "Hotel" ||
                          selectedPropertyType == "Resort" ||
                          selectedPropertyType == "PG") ...[
                        field(
                          "Additional Address",
                          _additionalController,
                          suffixIcon: IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.flag_circle_outlined),
                          ),
                          suffix: true,
                        ),
                      ] else if (selectedPropertyType == "Flat") ...[
                        field(
                          "Flat No.",
                          _flatNoController,
                          suffixIcon:Icon(Icons.flag_circle_outlined),
                          suffix: true,
                          keyboard: TextInputType.number
                        ),
                      ]
                    ],
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
        bool readOnly = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CustomTextField(
        controller: c,
        maxLength: multi ? 10 : 40,
        keyboardType: keyboard,
        labelText: label,
        readOnly: readOnly,
        suffixIcon: suffix && suffixIcon != null ? suffixIcon : null,
        customBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1.4,
          ),
        ),
        fillColor: AppColors.background(ref),
      ),
    );
  }

  Widget _dropdown({
    required String title,
    required String? value,
    required List<String> items,
    required Function(String?) onChange,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.grey, // Default border color
              width: 1.4,
            ),
          ),
          fillColor: AppColors.background(ref),
        ),
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChange,
      ),
    );
  }
}
