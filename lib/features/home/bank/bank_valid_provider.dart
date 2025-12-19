import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';

// Model
class BankAccount {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;
  final bool isDefault;

  BankAccount({
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifscCode,
    required this.bankName,
    required this.branchName,
    required this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'bankName': bankName,
      'branchName': branchName,
      'isDefault': isDefault,
    };
  }
}

// Form State Notifier
class BankAccountFormState {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String bankName;
  final String branchName;
  final bool isDefault;
  final bool isLoading;
  final String? errorMessage;

  // Touch tracking for each field
  final bool accountHolderNameTouched;
  final bool accountNumberTouched;
  final bool ifscCodeTouched;
  final bool bankNameTouched;
  final bool branchNameTouched;

  const BankAccountFormState({
    this.accountHolderName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.bankName = '',
    this.branchName = '',
    this.isDefault = true,
    this.isLoading = false,
    this.errorMessage,
    this.accountHolderNameTouched = false,
    this.accountNumberTouched = false,
    this.ifscCodeTouched = false,
    this.bankNameTouched = false,
    this.branchNameTouched = false,
  });

  BankAccountFormState copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? bankName,
    String? branchName,
    bool? isDefault,
    bool? isLoading,
    String? errorMessage,
    bool? accountHolderNameTouched,
    bool? accountNumberTouched,
    bool? ifscCodeTouched,
    bool? bankNameTouched,
    bool? branchNameTouched,
  }) {
    return BankAccountFormState(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      isDefault: isDefault ?? this.isDefault,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      accountHolderNameTouched: accountHolderNameTouched ?? this.accountHolderNameTouched,
      accountNumberTouched: accountNumberTouched ?? this.accountNumberTouched,
      ifscCodeTouched: ifscCodeTouched ?? this.ifscCodeTouched,
      bankNameTouched: bankNameTouched ?? this.bankNameTouched,
      branchNameTouched: branchNameTouched ?? this.branchNameTouched,
    );
  }
}

// Provider for form state
final bankAccountFormProvider = StateNotifierProvider.autoDispose<
    BankAccountFormNotifier, BankAccountFormState>(
      (ref) => BankAccountFormNotifier(),
);

// Notifier class
class BankAccountFormNotifier extends StateNotifier<BankAccountFormState> {
  // Validation patterns
  static final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s]{3,}$');
  static final RegExp _accountNumberRegex = RegExp(r'^[0-9]{9,18}$');
  static final RegExp _ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  static final RegExp _bankBranchRegex = RegExp(r'^[a-zA-Z0-9\s\-\&\.]{3,}$');

  BankAccountFormNotifier() : super(const BankAccountFormState());

  // Mark field as touched
  void markAccountHolderNameTouched() {
    state = state.copyWith(accountHolderNameTouched: true);
  }

  void markAccountNumberTouched() {
    state = state.copyWith(accountNumberTouched: true);
  }

  void markIfscCodeTouched() {
    state = state.copyWith(ifscCodeTouched: true);
  }

  void markBankNameTouched() {
    state = state.copyWith(bankNameTouched: true);
  }

  void markBranchNameTouched() {
    state = state.copyWith(branchNameTouched: true);
  }

  // Update methods
  void updateAccountHolderName(String value) {
    state = state.copyWith(
      accountHolderName: value,
      accountHolderNameTouched: true,
    );
  }

  void updateAccountNumber(String value) {
    state = state.copyWith(
      accountNumber: value,
      accountNumberTouched: true,
    );
  }

  void updateIfscCode(String value) {
    state = state.copyWith(
      ifscCode: value,
      ifscCodeTouched: true,
    );
  }

  void updateBankName(String value) {
    state = state.copyWith(
      bankName: value,
      bankNameTouched: true,
    );
  }

  void updateBranchName(String value) {
    state = state.copyWith(
      branchName: value,
      branchNameTouched: true,
    );
  }

  void toggleDefault() {
    state = state.copyWith(isDefault: !state.isDefault);
  }

  // Validation methods
  String? validateAccountHolderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter account holder name';
    }
    if (!_nameRegex.hasMatch(value.trim())) {
      return 'Enter valid name (min 3 letters, no special chars)';
    }
    return null;
  }

  String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter account number';
    }
    final cleanValue = value.replaceAll(RegExp(r'\s+'), '');
    if (!_accountNumberRegex.hasMatch(cleanValue)) {
      return 'Account number must be 9-18 digits';
    }
    return null;
  }

  String? validateIfscCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter IFSC code';
    }
    if (!_ifscRegex.hasMatch(value.trim())) {
      return 'Invalid IFSC format (e.g., SBIN0000123)';
    }
    return null;
  }

  String? validateBankName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter bank name';
    }
    if (!_bankBranchRegex.hasMatch(value.trim())) {
      return 'Enter valid bank name';
    }
    return null;
  }

  String? validateBranchName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter branch name';
    }
    if (!_bankBranchRegex.hasMatch(value.trim())) {
      return 'Enter valid branch name';
    }
    return null;
  }

  // Get error message only if field is touched
  String? getAccountHolderNameError() {
    if (!state.accountHolderNameTouched) return null;
    return validateAccountHolderName(state.accountHolderName);
  }

  String? getAccountNumberError() {
    if (!state.accountNumberTouched) return null;
    return validateAccountNumber(state.accountNumber);
  }

  String? getIfscCodeError() {
    if (!state.ifscCodeTouched) return null;
    return validateIfscCode(state.ifscCode);
  }

  String? getBankNameError() {
    if (!state.bankNameTouched) return null;
    return validateBankName(state.bankName);
  }

  String? getBranchNameError() {
    if (!state.branchNameTouched) return null;
    return validateBranchName(state.branchName);
  }

  // Check if form is valid
  bool isFormValid() {
    return validateAccountHolderName(state.accountHolderName) == null &&
        validateAccountNumber(state.accountNumber) == null &&
        validateIfscCode(state.ifscCode) == null &&
        validateBankName(state.bankName) == null &&
        validateBranchName(state.branchName) == null;
  }

  // Submit form
  Future<BankAccount?> submitForm() async {
    // Mark all fields as touched to show all errors
    state = state.copyWith(
      accountHolderNameTouched: true,
      accountNumberTouched: true,
      ifscCodeTouched: true,
      bankNameTouched: true,
      branchNameTouched: true,
    );

    if (!isFormValid()) {
      return null;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final bankAccount = BankAccount(
        accountHolderName: state.accountHolderName.trim(),
        accountNumber: state.accountNumber.trim().replaceAll(RegExp(r'\s+'), ''),
        ifscCode: state.ifscCode.trim(),
        bankName: state.bankName.trim(),
        branchName: state.branchName.trim(),
        isDefault: state.isDefault,
      );

      print('Bank Data to Submit: ${bankAccount.toMap()}');

      state = state.copyWith(isLoading: false);
      return bankAccount;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add bank account: $e',
      );
      return null;
    }
  }

  // Reset form
  void resetForm() {
    state = const BankAccountFormState();
  }
}

// Provider for account number formatter
final accountNumberFormatterProvider = Provider<TextInputFormatter>(
      (_) => _AccountNumberFormatter(),
);

// Custom Text Input Formatters
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class _AccountNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove all non-digits
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 18 digits
    if (cleanedText.length > 18) {
      cleanedText = cleanedText.substring(0, 18);
    }

    // Format with spaces every 4 digits
    StringBuffer formattedText = StringBuffer();
    for (int i = 0; i < cleanedText.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedText.write(' ');
      }
      formattedText.write(cleanedText[i]);
    }

    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}