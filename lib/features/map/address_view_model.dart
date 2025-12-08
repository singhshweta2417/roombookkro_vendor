import 'package:flutter/material.dart';

class AddressState {
  final String selectedOption;
  final bool isSwitched;
  final TextEditingController nameController;
  final TextEditingController mobileController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController areaController;
  final TextEditingController pinCodeController;
  final TextEditingController stateController;
  final TextEditingController countryController;

  AddressState({
    this.selectedOption = 'Home',
    this.isSwitched = false,
    required this.nameController,
    required this.mobileController,
    required this.addressController,
    required this.cityController,
    required this.areaController,
    required this.pinCodeController,
    required this.stateController,
    required this.countryController,
  });

  AddressState copyWith({
    String? selectedOption,
    bool? isSwitched,
  }) {
    return AddressState(
      selectedOption: selectedOption ?? this.selectedOption,
      isSwitched: isSwitched ?? this.isSwitched,
      nameController: nameController,
      mobileController: mobileController,
      addressController: addressController,
      cityController: cityController,
      areaController: areaController,
      pinCodeController: pinCodeController,
      stateController: stateController,
      countryController: countryController,
    );
  }
}
