import '../../../core/widgets/custom_text_field/text_field_notifier.dart';

// ✅ Global reusable function
void resetAllFormFields(ref) {
  ref.read(nameFieldProvider.notifier).reset();
  ref.read(emailFieldProvider.notifier).reset();
  ref.read(passwordFieldProvider.notifier).reset();
  ref.read(mobileFieldProvider.notifier).reset();
  ref.read(dobFieldProvider.notifier).reset();
  ref.read(genderDropdownProvider.notifier).reset();
  // ref.read(countryDropdownProvider.notifier).reset();
  ref.read(occupationFieldProvider.notifier).reset();
}
