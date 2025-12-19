import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/auth/model/bank_detail_list_model.dart';
import 'package:room_book_kro_vendor/features/home/bank_list_view_model.dart';
import 'package:room_book_kro_vendor/features/home/delete_bank_view_model.dart';
import 'package:room_book_kro_vendor/features/home/deposit_history_view_model.dart';
import '../../../core/routes/navigator_key_provider.dart'
    show navigatorKeyProvider;
import '../../auth/data/user_view.dart';

class BankListScreen extends ConsumerStatefulWidget {
  const BankListScreen({super.key});

  @override
  ConsumerState<BankListScreen> createState() => _BankListScreenState();
}

class _BankListScreenState extends ConsumerState<BankListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getBankHistoryProvider.notifier).bankHistoryApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bankHistoryState = ref.watch(getBankHistoryProvider);
    final userPref = ref.read(userViewModelProvider);

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "My Bank",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
          color: Colors.black,
        ),
      ),
      child: FutureBuilder<String?>(
        future: userPref.getUserType(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final userType = snapshot.data ?? "";
          if (userType == "3") {
            return _loginRequired(context);
          }
          if (bankHistoryState is BankHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (bankHistoryState is BankHistoryError) {
            return _buildErrorState(bankHistoryState.error);
          }
          if (bankHistoryState is BankHistorySuccess) {
            final bankList =
                bankHistoryState.bankHistoryList.data?.bankDetails ?? [];

            if (bankList.isEmpty) {
              return _buildNoDataState();
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: context.sh * 0.015),
              itemCount: bankList.length,
              itemBuilder: (context, index) {
                return _bankTile(bankList[index]);
              },
            );
          }
          return _buildNoDataState();
        },
      ),
    );
  }

  Widget _bankTile(BankDetails bank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.account_balance, color: Colors.green),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _onEditBank(bank);
            } else if (value == 'delete') {
              _onDeleteBank(bank);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),

        title: AppText(
          text: bank.bankName ?? "Bank",
          fontType: FontType.bold,
          fontSize: 16,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(text: bank.accountHolderName ?? "", fontSize: 13),
            AppText(
              text: "A/C: ${bank.accountNumber ?? ''}",
              fontSize: 12,
              color: Colors.grey,
            ),
            AppText(
              text: "IFSC: ${bank.ifscCode ?? ''}",
              fontSize: 12,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _onEditBank(BankDetails bank) {
    Navigator.pushNamed(
      context,
      AppRoutes.editBankAccountScreen,
      arguments: bank,
    );
  }

  void _onDeleteBank(BankDetails bank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Bank"),
        content: const Text(
          "Are you sure you want to delete this bank account?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(text: "Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref
                  .read(getBankDeleteProvider.notifier)
                  .bankDeleteApi(bank.bankId.toString(), context);
            },
            child: AppText(text: "Delete"),
          ),
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
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade300),
          const SizedBox(height: 16),
          AppText(
            text: "Oops! Something went wrong",
            fontType: FontType.bold,
            fontSize: 18,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 8),
          AppText(text: error, fontSize: 14, color: Colors.grey.shade600),
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
              ref.read(getDepositHistoryProvider.notifier).depositHistoryApi();
            },
            icon: const Icon(Icons.refresh),
            label: AppText(text: "Try Again", color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _loginRequired(BuildContext context) {
    final navigatorKey = ref.read(navigatorKeyProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          text: "Please Login First",
          fontType: FontType.bold,
          fontSize: AppConstants.eighteen,
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          onTap: () async {
            final userView = ref.read(userViewModelProvider);
            await userView.clearAll();
            navigatorKey.currentState?.pushReplacementNamed(AppRoutes.login);
          },
          label: "Login",
        ),
      ],
    );
  }
}
