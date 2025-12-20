import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_text_field.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/auth/model/withdraw_history_model.dart';
import 'package:room_book_kro_vendor/features/home/bank_list_view_model.dart';
import 'package:room_book_kro_vendor/features/home/withdraw_history_view_model.dart';
import 'package:room_book_kro_vendor/features/home/withdraw_view_model.dart';
import 'package:room_book_kro_vendor/features/auth/model/bank_detail_list_model.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _amountError;
  String? _bankIdError;
  int? _selectedBankId; 

  @override
  void initState() {
    super.initState();
    // Fetch bank list on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getBankHistoryProvider.notifier).bankHistoryApi();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Amount validation
  String? _validateAmount(String value) {
    if (value.isEmpty) {
      return 'Amount is required';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Only digits allowed';
    }

    final amount = int.tryParse(value);
    if (amount == null) {
      return 'Invalid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount < 100) {
      return 'Minimum withdrawal amount is ₹100';
    }

    if (amount > 100000) {
      return 'Maximum withdrawal amount is ₹1,00,000';
    }

    return null;
  }

  // Bank ID validation
  String? _validateBankId() {
    if (_selectedBankId == null) {
      return 'Please select a bank account';
    }
    return null;
  }

  void _submitWithdraw() {
    // Validate both fields
    final amountError = _validateAmount(_amountController.text);
    final bankIdError = _validateBankId();

    setState(() {
      _amountError = amountError;
      _bankIdError = bankIdError;
    });

    // If no errors, proceed with API call
    if (amountError == null && bankIdError == null) {
      ref
          .read(withdrawViewModelProvider.notifier)
          .withdrawApi(
        bankId: _selectedBankId.toString(),
        amount: _amountController.text,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final withdrawState = ref.watch(withdrawViewModelProvider);
    final bankHistoryState = ref.watch(getBankHistoryProvider);

    // Listen to withdraw state changes
    ref.listen<WithdrawState>(withdrawViewModelProvider, (previous, next) {
      if (next is WithdrawSuccess) {
        // Clear form on success
        _amountController.clear();
        setState(() {
          _selectedBankId = null;
          _amountError = null;
          _bankIdError = null;
        });
      }
    });

    // Get bank list
    List<BankDetails> bankList = [];
    if (bankHistoryState is BankHistorySuccess) {
      bankList = bankHistoryState.bankHistoryList.data?.bankDetails ?? [];
    }
    final withdrawHistoryState = ref.watch(getWithdrawHistoryProvider);
    return CustomScaffold(
      appBar: CustomAppBar(
        showActions: true,
        middle: AppText(
          text: "Withdraw Funds",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyTwo,
          color: Colors.black,
        ),
        trailing: IconButton(onPressed: (){}, icon: Icon(Icons.history)),
      ),
      child: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: context.sh * 0.05),
                // Header Section
                Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 48,
                      color: AppColors.secondary(ref),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: 'Withdraw to Bank Account',
                      fontSize: 18,
                      fontType: FontType.bold,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      text: 'Enter amount and bank details',
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ],
                ),

                SizedBox(height: context.sh * 0.05),

                // Amount Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      hintText: "Enter amount (₹100 - ₹1,00,000)",
                      prefixIcon: Icon(
                        Icons.currency_rupee,
                        color: AppColors.iconColor(ref),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _amountError = _validateAmount(val);
                        });
                      },
                      labelFontType: FontType.regular,
                      maxLength: 6,
                    ),
                    if (_amountError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          _amountError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: context.sh * 0.01),

                // Bank Account Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (bankHistoryState is BankHistoryLoading)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            AppText(
                              text: 'Loading bank accounts...',
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      )
                    else if (bankList.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade300),
                          color: Colors.orange.shade50,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AppText(
                                text: 'No bank accounts found. Please add one.',
                                color: Colors.orange[900],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _bankIdError != null
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            hint: Row(
                              children: [
                                Icon(
                                  Icons.account_balance,
                                  color: AppColors.iconColor(ref),
                                ),
                                const SizedBox(width: 12),
                                AppText(
                                  text: 'Select Bank Account',
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                            value: _selectedBankId,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.iconColor(ref),
                            ),
                            items: bankList.map((bank) {
                              // Format account number - show last 4 digits
                              String maskedAccount = '';
                              if (bank.accountNumber != null &&
                                  bank.accountNumber!.length >= 4) {
                                maskedAccount =
                                'XXXX${bank.accountNumber!.substring(bank.accountNumber!.length - 4)}';
                              }

                              return DropdownMenuItem<int>(
                                value: bank.bankId,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance,
                                      size: 20,
                                      color: bank.isDefault == true
                                          ? Colors.green
                                          : AppColors.iconColor(ref),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppText(
                                            text: bank.bankName ?? 'Unknown Bank',
                                            fontSize: 14,
                                            fontType: FontType.medium,
                                          ),
                                          AppText(
                                            text: '$maskedAccount - ${bank.accountHolderName ?? ""}',
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (bank.isDefault == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: AppText(
                                          text: 'Default',
                                          fontSize: 10,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBankId = value;
                                _bankIdError = _validateBankId();
                              });
                            },
                          ),
                        ),
                      ),
                    if (_bankIdError != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: AppText(
                          text: _bankIdError!,
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: context.sh * 0.02),

                // Submit Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addBankAccountScreen,
                        );
                      },
                      child: AppText(text: "+ Add Bank", fontType: FontType.bold),
                    ),
                    PrimaryButton(
                      onTap: withdrawState is WithdrawLoading || bankList.isEmpty
                          ? null
                          : _submitWithdraw,
                      label: withdrawState is WithdrawLoading
                          ? "Processing..."
                          : "Submit Withdrawal",
                    ),
                  ],
                ),

                SizedBox(height: context.sh * 0.03),

                // State Messages
                if (withdrawState is WithdrawError)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppText(
                            text: withdrawState.error,
                            color: Colors.red[900],
                            fontType: FontType.medium,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (withdrawState is WithdrawSuccess)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppText(
                            text: 'Withdrawal request submitted successfully!',
                            color: Colors.green[900],
                            fontType: FontType.medium,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (bankHistoryState is BankHistoryError)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppText(
                            text: 'Error loading banks: ${bankHistoryState.error}',
                            color: Colors.red[900],
                            fontType: FontType.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "Transaction History",
                fontSize: 18,
                fontType: FontType.bold,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Handle different states
          if (withdrawHistoryState is WithdrawHistoryLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (withdrawHistoryState is WithdrawHistoryError)
            _buildErrorState(withdrawHistoryState.error)
          else if (withdrawHistoryState is WithdrawHistorySuccess)
              (withdrawHistoryState.withdrawHistoryList.data?.withdrawals?.isEmpty ?? true)
                  ? _buildNoDataState()
                  : Column(
                children:withdrawHistoryState.withdrawHistoryList.data!.withdrawals!
                    .map((tx) => _transactionTile(tx))
                    .toList(),
              )
            else
              _buildNoDataState(),
        ],
      ),
    );
  }
  // No Data State Widget
  Widget _buildNoDataState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          AppText(
            text: "No Data Available",
            fontType: FontType.bold,
            fontSize: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 8),
          AppText(
            text: "You haven't made any deposit yet",
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }

  // Error State Widget
  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          AppText(
            text: "Oops! Something went wrong",
            fontType: FontType.bold,
            fontSize: 18,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 8),
          AppText(
            text: error,
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              ref.read(getWithdrawHistoryProvider.notifier).withdrawHistoryApi();
            },
            icon: const Icon(Icons.refresh),
            label: AppText(
              text: "Try Again",
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(Withdrawals tx) {
    String formattedDate = "";
    if (tx.createdAt != null) {
      try {
        final date = DateTime.parse(tx.createdAt!);
        formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
      } catch (e) {
        formattedDate = tx.createdAt ?? "";
      }
    }

    bool isIncome = tx.transactionType?.toLowerCase() == 'deposit' ||
        tx.transactionType?.toLowerCase() == 'credit';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
            size: 24,
          ),
        ),
        title: AppText(
          text: tx.transactionType ?? "Transaction",
          fontType: FontType.bold,
          fontSize: 16,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            AppText(
              text: formattedDate,
              fontSize: 12,
              color: Colors.grey,
            ),
            if (tx.description != null && tx.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  text: tx.description!,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            if (tx.paymentStatus != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tx.paymentStatus?.toLowerCase() == 'success'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: AppText(
                    text: tx.paymentStatus!,
                    fontSize: 10,
                    color: tx.paymentStatus?.toLowerCase() == 'success'
                        ? Colors.green.shade900
                        : Colors.orange.shade900,
                  ),
                ),
              ),
          ],
        ),
        trailing: AppText(
          text: "₹${tx.amount ?? 0}",
          fontType: FontType.bold,
          fontSize: 18,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}