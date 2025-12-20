import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/routes/app_routes.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/features/auth/model/deposit_history_model.dart';
import 'package:room_book_kro_vendor/features/home/deposit_history_view_model.dart';
import 'package:room_book_kro_vendor/features/home/top_up_session_view_model.dart';
import 'package:room_book_kro_vendor/features/profile/view_model/profile_view_model.dart';
import '../../../core/routes/navigator_key_provider.dart' show navigatorKeyProvider;
import '../../../core/utils/context_extensions.dart';
import '../../auth/data/user_view.dart';
import 'package:intl/intl.dart';

// ===== Wallet Screen =====
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(getDepositHistoryProvider.notifier).depositHistoryApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(updateProvider);
    final wallet = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.walletBalance
        : "0";
    final adminDue = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.adminDue
        : "0";
    final username = (authState is ProfileSuccess && authState.profile != null)
        ? authState.profile!.username
        : "Guest";

    final depositHistoryState = ref.watch(getDepositHistoryProvider);
    final userPref = ref.read(userViewModelProvider);

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "My Wallet",
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
            final navigatorKey = ref.read(navigatorKeyProvider);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: "Please Login First",
                  fontType: FontType.bold,
                  fontSize: AppConstants.eighteen,
                ),
                const SizedBox(height: 5),
                PrimaryButton(
                  onTap: () async {
                    final userView = ref.read(userViewModelProvider);
                    await userView.clearAll();
                    navigatorKey.currentState?.pushReplacementNamed(
                      AppRoutes.login,
                    );
                  },
                  label: "Login",
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== Wallet Card =====
              TCustomContainer(
                padding: const EdgeInsets.all(20),
                lightColor: Colors.green,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: username.toString(),
                          color: Colors.white,
                          fontSize: context.sh * 0.025,
                          fontType: FontType.bold,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(text: "Available Balance", color: Colors.white70),
                            AppText(
                              text: "₹${wallet.toString()}",
                              color: Colors.white,
                              fontSize: 28,
                              fontType: FontType.bold,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      text: ".... .... .... ....  .... .... .... ....  .... .... .... ....",
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    SizedBox(height: context.sh * 0.01),
                    if (adminDue != null && adminDue != "0" && adminDue != 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                text: "Admin Due",
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              AppText(
                                text: "₹${adminDue.toString()}",
                                color: Colors.red.shade100,
                                fontSize: 24,
                                fontType: FontType.bold,
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(topUpSessionCreatePro.notifier)
                                  .topUpSessionApi(adminDue.toString(), context);
                            },
                            icon: const Icon(Icons.payment, size: 20),
                            label: AppText(text: "Pay Now"),
                          ),
                        ],
                      ),
                    InkWell(
                      onTap: (){
                      Navigator.pushNamed(context, AppRoutes.withdrawScreen);
                      },
                      child: Container(
                        height: context.sh*0.05,
                        width: context.sw*0.25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add,color: Colors.white,),
                            AppText(text: "Withdraw",color: Colors.white,fontType: FontType.bold,fontSize: context.sh*0.015,)
                          ],
                        ),
                      ),
                    )
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
              if (depositHistoryState is DepositHistoryLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (depositHistoryState is DepositHistoryError)
                _buildErrorState(depositHistoryState.error)
              else if (depositHistoryState is DepositHistorySuccess)
                  (depositHistoryState.depositHistoryList.data?.transactions?.isEmpty ?? true)
                      ? _buildNoDataState()
                      : Column(
                    children: depositHistoryState.depositHistoryList.data!.transactions!
                        .map((tx) => _transactionTile(tx))
                        .toList(),
                  )
                else
                  _buildNoDataState(),
            ],
          );
        },
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
              ref.read(getDepositHistoryProvider.notifier).depositHistoryApi();
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

  Widget _transactionTile(Transactions tx) {
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