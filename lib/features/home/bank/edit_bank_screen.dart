import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/features/auth/model/bank_detail_list_model.dart';
import 'package:room_book_kro_vendor/features/home/bank/bank_valid_provider.dart';
import 'package:room_book_kro_vendor/features/home/bank_update_view_model.dart';
import 'package:room_book_kro_vendor/features/home/bank_list_view_model.dart';

class EditBankAccountScreen extends ConsumerStatefulWidget {
  const EditBankAccountScreen({super.key});

  @override
  ConsumerState<EditBankAccountScreen> createState() =>
      _EditBankAccountScreenState();
}

class _EditBankAccountScreenState extends ConsumerState<EditBankAccountScreen> {
  late BankDetails bank;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      bank = ModalRoute.of(context)!.settings.arguments as BankDetails;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final notifier = ref.read(bankAccountFormProvider.notifier);
        notifier
          ..updateAccountHolderName(bank.accountHolderName ?? '')
          ..updateAccountNumber(bank.accountNumber ?? '')
          ..updateIfscCode(bank.ifscCode ?? '')
          ..updateBankName(bank.bankName ?? '')
          ..updateBranchName(bank.branchName ?? '');
      });
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(bankAccountFormProvider);
    final formNotifier = ref.read(bankAccountFormProvider.notifier);
    final updateState = ref.watch(updateBankViewModelProvider);
    final accountNumberFormatter = ref.read(accountNumberFormatterProvider);

    ref.listen(updateBankViewModelProvider, (previous, next) {
      if (next is UpdateBankSuccess) {
        ref.read(getBankHistoryProvider.notifier).bankHistoryApi();
        Navigator.pop(context);
      }
    });

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Edit Bank Account",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            _buildInfoCard(context, ref),
            const SizedBox(height: 24),

            // Form Fields
            _buildAccountHolderField(formState, formNotifier, ref),
            const SizedBox(height: 16),

            _buildAccountNumberField(
              formState,
              formNotifier,
              accountNumberFormatter,
              ref,
            ),
            const SizedBox(height: 16),

            _buildIFSCField(formState, formNotifier, ref),
            const SizedBox(height: 16),

            _buildBankNameField(formState, formNotifier, ref),
            const SizedBox(height: 16),

            _buildBranchNameField(formState, formNotifier, ref),
            const SizedBox(height: 24),

            // Default Account Toggle
            // _buildDefaultToggle(formState, formNotifier, ref),
            // const SizedBox(height: 32),

            // Update Button
            _buildUpdateButton(formState, formNotifier, updateState, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary(ref).withOpacity(0.9),
              AppColors.secondary(ref).withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_document, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Edit Bank Details',
                    fontSize: 16,
                    fontType: FontType.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: 'Update your bank account information',
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountHolderField(
    BankAccountFormState formState,
    BankAccountFormNotifier formNotifier,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Account Holder Name*',
          fontType: FontType.medium,
          color: Colors.grey[700],
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.accountHolderName,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppColors.secondary(ref),
            ),
            hintText: 'Enter full name as per bank records',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.secondary(ref), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
            errorText: formNotifier.validateAccountHolderName(
              formState.accountHolderName,
            ),
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (value) {
            // Auto capitalize first letter of each word
            if (value.isNotEmpty) {
              final words = value.split(' ');
              final capitalizedWords = words.map((word) {
                if (word.isNotEmpty) {
                  return word[0].toUpperCase() +
                      word.substring(1).toLowerCase();
                }
                return word;
              }).toList();
              final capitalizedValue = capitalizedWords.join(' ');
              if (capitalizedValue != value) {
                formNotifier.updateAccountHolderName(capitalizedValue);
                return;
              }
            }
            formNotifier.updateAccountHolderName(value);
          },
        ),
      ],
    );
  }

  Widget _buildAccountNumberField(
    BankAccountFormState formState,
    BankAccountFormNotifier formNotifier,
    TextInputFormatter formatter,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Account Number*',
          fontType: FontType.medium,
          color: Colors.grey[700],
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.accountNumber,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.credit_card,
              color: AppColors.secondary(ref),
            ),
            hintText: 'Enter 9-18 digit account number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.secondary(ref), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
            errorText: formNotifier.validateAccountNumber(
              formState.accountNumber,
            ),
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            fontSize: 15,
            letterSpacing: 1.2,
            color: Colors.grey[800],
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(23),
            formatter,
          ],
          onChanged: (value) {
            formNotifier.updateAccountNumber(value);
          },
        ),
      ],
    );
  }

  Widget _buildIFSCField(
    BankAccountFormState formState,
    BankAccountFormNotifier formNotifier,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'IFSC Code*',
          fontType: FontType.medium,
          color: Colors.grey[700],
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.ifscCode,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.code, color: AppColors.secondary(ref)),
            hintText: 'Enter 11 character IFSC code',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.secondary(ref), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
            errorText: formNotifier.validateIfscCode(formState.ifscCode),
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(
            fontSize: 15,
            letterSpacing: 1.2,
            color: Colors.grey[800],
          ),
          inputFormatters: [
            UpperCaseTextFormatter(),
            LengthLimitingTextInputFormatter(11),
          ],
          onChanged: (value) {
            if (value.length == 4 && !value.endsWith('0')) {
              final newValue = '${value.substring(0, 4)}0';
              formNotifier.updateIfscCode(newValue);
              return;
            }
            formNotifier.updateIfscCode(value);
          },
        ),
      ],
    );
  }

  Widget _buildBankNameField(
    BankAccountFormState formState,
    BankAccountFormNotifier formNotifier,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Bank Name*',
          fontType: FontType.medium,
          color: Colors.grey[700],
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.bankName,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.account_balance,
              color: AppColors.secondary(ref),
            ),
            hintText: 'Enter bank name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.secondary(ref), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
            errorText: formNotifier.validateBankName(formState.bankName),
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          onChanged: formNotifier.updateBankName,
        ),
      ],
    );
  }

  Widget _buildBranchNameField(
    BankAccountFormState formState,
    BankAccountFormNotifier formNotifier,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Branch Name*',
          fontType: FontType.medium,
          color: Colors.grey[700],
          fontSize: 14,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.branchName,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_on,
              color: AppColors.secondary(ref),
            ),
            hintText: 'Enter branch location',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.secondary(ref), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: Colors.white,
            errorText: formNotifier.validateBranchName(formState.branchName),
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          inputFormatters: [LengthLimitingTextInputFormatter(100)],
          onChanged: (value) {
            formNotifier.updateBranchName(value);
          },
        ),
      ],
    );
  }

  Widget _buildDefaultToggle(
    BankAccountFormState formState,
    BankAccountFormNotifier formNotifier,
    WidgetRef ref,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondary(ref).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.star,
                color: AppColors.secondary(ref),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: 'Set as default account',
                    fontType: FontType.medium,
                    fontSize: 15,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: 'Use this account for all transactions',
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ],
              ),
            ),
            Switch(
              value: formState.isDefault,
              onChanged: (_) => formNotifier.toggleDefault(),
              inactiveTrackColor: Colors.grey[300],
              activeColor: Colors.white,
              activeTrackColor: AppColors.secondary(ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton(
    BankAccountFormState formState,
    BankAccountFormNotifier formNotifier,
    UpdateBankState updateState,
    WidgetRef ref,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: updateState is UpdateBankLoading
            ? null
            : () async {
                if (!formNotifier.isFormValid()) {
                  formNotifier.validateAccountHolderName(
                    formState.accountHolderName,
                  );
                  formNotifier.validateAccountNumber(formState.accountNumber);
                  formNotifier.validateIfscCode(formState.ifscCode);
                  formNotifier.validateBankName(formState.bankName);
                  formNotifier.validateBranchName(formState.branchName);
                  return;
                }

                await ref
                    .read(updateBankViewModelProvider.notifier)
                    .updateBankApi(
                      bankId: bank.bankId.toString(),
                      accountHolderName: formState.accountHolderName,
                      accountNumber: formState.accountNumber,
                      ifscCode: formState.ifscCode,
                      bankName: formState.bankName,
                      branchName: formState.branchName,
                      context: context,
                    );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary(ref),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppColors.secondary(ref).withOpacity(0.3),
        ),
        child: updateState is UpdateBankLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.update, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  AppText(
                    text: 'Update Bank Account',
                    fontSize: 16,
                    fontType: FontType.medium,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}
