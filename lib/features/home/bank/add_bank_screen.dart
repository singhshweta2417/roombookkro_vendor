import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/features/home/bank/bank_valid_provider.dart';
import 'package:room_book_kro_vendor/features/profile/view_model/add_bank_view_model.dart';
import 'package:room_book_kro_vendor/features/home/ifsc_view_model.dart';

class AddBankAccountScreen extends ConsumerStatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  ConsumerState<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends ConsumerState<AddBankAccountScreen> {
  bool _hasAutoFilled = false;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(bankAccountFormProvider);
    final formNotifier = ref.read(bankAccountFormProvider.notifier);
    final accountNumberFormatter = ref.read(accountNumberFormatterProvider);
    final ifscState = ref.watch(getIfscProvider);

    // Listen to IFSC API response and auto-fill
    ref.listen<IfscState>(getIfscProvider, (previous, next) {
      if (next is IfscSuccess && !_hasAutoFilled) {
        final ifscData = next.ifscList.data;
        if (ifscData != null) {
          // Auto-fill bank name
          if (ifscData.bANK != null && ifscData.bANK!.isNotEmpty) {
            formNotifier.updateBankName(ifscData.bANK!);
          }

          // Auto-fill branch name
          if (ifscData.bRANCH != null && ifscData.bRANCH!.isNotEmpty) {
            formNotifier.updateBranchName(ifscData.bRANCH!);
          }

          _hasAutoFilled = true;

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bank details fetched: ${ifscData.bANK ?? ""}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (next is IfscError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Invalid IFSC code or service unavailable',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return CustomScaffold(
      appBar: CustomAppBar(
        showActions: true,
        middle: AppText(
          text: "Add Bank Account",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
        trailing: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.bankListScreen);
          },
          icon: const Icon(Icons.history),
        ),
      ),
      child: formState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(context, ref),
            const SizedBox(height: 24),

            // Form Fields
            _buildAccountHolderField(formState, formNotifier, ref),
            const SizedBox(height: 20),

            _buildAccountNumberField(
              formState,
              formNotifier,
              accountNumberFormatter,
              ref,
            ),
            const SizedBox(height: 20),

            _buildIFSCField(formState, formNotifier, ref, ifscState),
            const SizedBox(height: 20),

            _buildBankNameField(formState, formNotifier, ref),
            const SizedBox(height: 20),

            _buildBranchNameField(formState, formNotifier, ref),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(formState, formNotifier, context, ref),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary(ref),
              AppColors.secondary(ref).withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: 'Secure Banking',
                    fontSize: 18,
                    fontType: FontType.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: 'Your information is encrypted and secure',
                    color: Colors.white.withValues(alpha: 0.9),
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
    final error = formNotifier.getAccountHolderNameError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              text: 'Account Holder Name',
              fontType: FontType.medium,
              color: Colors.grey[800],
              fontSize: 15,
            ),
            const AppText(
              text: ' *',
              color: Colors.red,
              fontSize: 15,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.accountHolderName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person_outline,
              color: error != null ? Colors.red : AppColors.secondary(ref),
              size: 22,
            ),
            hintText: 'Enter full name as per bank records',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : AppColors.secondary(ref),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 12, height: 0.8),
          ),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            LengthLimitingTextInputFormatter(50),
          ],
          onTap: () => formNotifier.markAccountHolderNameTouched(),
          onChanged: (value) {
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
    final error = formNotifier.getAccountNumberError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              text: 'Account Number',
              fontType: FontType.medium,
              color: Colors.grey[800],
              fontSize: 15,
            ),
            const AppText(
              text: ' *',
              color: Colors.red,
              fontSize: 15,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.accountNumber,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.credit_card,
              color: error != null ? Colors.red : AppColors.secondary(ref),
              size: 22,
            ),
            hintText: 'Enter 9-18 digit account number',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : AppColors.secondary(ref),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 12, height: 0.8),
          ),
          style: const TextStyle(
            fontSize: 15,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(23),
            formatter,
          ],
          onTap: () => formNotifier.markAccountNumberTouched(),
          onChanged: formNotifier.updateAccountNumber,
        ),
      ],
    );
  }

  Widget _buildIFSCField(
      BankAccountFormState formState,
      BankAccountFormNotifier formNotifier,
      WidgetRef ref,
      IfscState ifscState,
      ) {
    final error = formNotifier.getIfscCodeError();
    final isLoadingIfsc = ifscState is IfscLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              text: 'IFSC Code',
              fontType: FontType.medium,
              color: Colors.grey[800],
              fontSize: 15,
            ),
            const AppText(
              text: ' *',
              color: Colors.red,
              fontSize: 15,
            ),
            if (isLoadingIfsc) ...[
              const SizedBox(width: 8),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.ifscCode,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.code,
              color: error != null ? Colors.red : AppColors.secondary(ref),
              size: 22,
            ),
            suffixIcon: formState.ifscCode.length == 11
                ? Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 22,
            )
                : null,
            hintText: 'e.g., SBIN0000123',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            helperText: 'Bank details will auto-fill after entering valid IFSC',
            helperStyle: TextStyle(
              color: Colors.blue[700],
              fontSize: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : AppColors.secondary(ref),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 12, height: 0.8),
          ),
          style: const TextStyle(
            fontSize: 15,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
          inputFormatters: [
            UpperCaseTextFormatter(),
            LengthLimitingTextInputFormatter(11),
          ],
          onTap: () => formNotifier.markIfscCodeTouched(),
          onChanged: (value) {
            formNotifier.updateIfscCode(value);

            // Reset auto-fill flag when IFSC changes
            _hasAutoFilled = false;

            // Auto-fetch bank details when IFSC is 11 characters
            if (value.length == 11) {
              ref.read(getIfscProvider.notifier).ifscApi(value);
            }
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
    final error = formNotifier.getBankNameError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              text: 'Bank Name',
              fontType: FontType.medium,
              color: Colors.grey[800],
              fontSize: 15,
            ),
            const AppText(
              text: ' *',
              color: Colors.red,
              fontSize: 15,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey(formState.bankName), // Force rebuild on value change
          initialValue: formState.bankName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.account_balance,
              color: error != null ? Colors.red : AppColors.secondary(ref),
              size: 22,
            ),
            hintText: 'Enter bank name',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : AppColors.secondary(ref),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 12, height: 0.8),
          ),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          onTap: () => formNotifier.markBankNameTouched(),
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
    final error = formNotifier.getBranchNameError();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppText(
              text: 'Branch Name',
              fontType: FontType.medium,
              color: Colors.grey[800],
              fontSize: 15,
            ),
            const AppText(
              text: ' *',
              color: Colors.red,
              fontSize: 15,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey(formState.branchName), // Force rebuild on value change
          initialValue: formState.branchName,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_on,
              color: error != null ? Colors.red : AppColors.secondary(ref),
              size: 22,
            ),
            hintText: 'Enter branch location',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : AppColors.secondary(ref),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorText: error,
            errorStyle: const TextStyle(fontSize: 12, height: 0.8),
          ),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          inputFormatters: [
            LengthLimitingTextInputFormatter(100),
          ],
          onTap: () => formNotifier.markBranchNameTouched(),
          onChanged: formNotifier.updateBranchName,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      BankAccountFormState formState,
      BankAccountFormNotifier formNotifier,
      BuildContext context,
      WidgetRef ref,
      ) {
    final addBankState = ref.watch(addBankProvider);
    final isLoading = addBankState is AddBankLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
          formNotifier.markAccountHolderNameTouched();
          formNotifier.markAccountNumberTouched();
          formNotifier.markIfscCodeTouched();
          formNotifier.markBankNameTouched();
          formNotifier.markBranchNameTouched();
          if (!formNotifier.isFormValid()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all required fields correctly'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          await ref.read(addBankProvider.notifier).addBankApi(
            formState.accountHolderName,
            formState.accountNumber.replaceAll(' ', ''),
            formState.ifscCode,
            formState.bankName,
            formState.branchName,
            formState.isDefault,
            context,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary(ref),
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
            SizedBox(width: 10),
            AppText(
              text: 'Add Bank Account',
              fontSize: 16,
              fontType: FontType.semiBold,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}