import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/constants/app_fonts.dart';
import 'package:room_book_kro_vendor/core/theme/app_colors.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import 'package:room_book_kro_vendor/core/utils/utils.dart';
import 'package:room_book_kro_vendor/core/widgets/app_text.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_app_bar.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_scaffold.dart';
import 'package:room_book_kro_vendor/core/widgets/primary_button.dart';
import 'package:room_book_kro_vendor/core/widgets/shimmer_const.dart';
import 'package:room_book_kro_vendor/features/home/top_up_session_view_model.dart';
import '../top_up_view_model.dart';

class TopUpWalletPage extends ConsumerStatefulWidget {
  const TopUpWalletPage({super.key});

  @override
  ConsumerState<TopUpWalletPage> createState() => _TopUpWalletPageState();
}

class _TopUpWalletPageState extends ConsumerState<TopUpWalletPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(selectedAmountProvider.notifier).state = null;
      ref.read(getTopUpProvider.notifier).topUpApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedAmount = ref.watch(selectedAmountProvider);

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Top Up E-Wallet",
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
        ),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(getTopUpProvider);
          if (state is TopUpLoading) {
            return Column(
              children: [
                SizedBox(height: context.sh * 0.02),
                CustomShimmer(
                  width: double.infinity,
                  height: 180,
                  padding: EdgeInsets.symmetric(vertical: context.sh * 0.04),
                  borderRadius: BorderRadius.circular(20),
                ),
                SizedBox(height: context.sh * 0.02),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: List.generate(
                      6,
                          (index) => CustomShimmer(
                        width: 50,
                        height: 30,
                        padding: EdgeInsets.symmetric(
                          vertical: context.sh * 0.04,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is TopUpError) {
            return Center(child: AppText(text: 'Error: ${state.error}'));
          } else if (state is TopUpSuccess) {
            if (state.topUpList.isEmpty) {
              return Center(child: AppText(text: 'No data available'));
            }

            return Column(
              children: [
                SizedBox(height: context.sh * 0.02),
                AppText(
                  text: "Enter the amount of top up",
                  fontSize: AppConstants.eighteen,
                ),
                SizedBox(height: context.sh * 0.02),
                TCustomContainer(
                  alignment: Alignment.center,
                  width: double.infinity,
                  lightColor: AppColors.background(ref),
                  padding: EdgeInsets.symmetric(vertical: context.sh * 0.04),
                  border: Border.all(color: AppColors.secondary(ref), width: 2),
                  borderRadius: BorderRadius.circular(20),
                  child: AppText(
                    text: selectedAmount != null
                        ? "₹${selectedAmount.amount}"
                        : "₹0",
                    fontSize: AppConstants.thirtyFive,
                    fontType: FontType.bold,
                    color: AppColors.secondary(ref),
                  ),
                ),
                SizedBox(height: context.sh * 0.02),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.5,
                    children: state.topUpList.map((amount) {
                      final isSelected = selectedAmount == amount;
                      return GestureDetector(
                        onTap: () {
                          ref.read(selectedAmountProvider.notifier).state =
                              amount;
                        },
                        child: TCustomContainer(
                          alignment: Alignment.center,
                          border: Border.all(
                            color: AppColors.secondary(ref),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          lightColor: isSelected ? Colors.green :AppColors.background(ref),
                          child: AppText(
                            text: "₹${amount.amount}",
                            fontSize: AppConstants.eighteen,
                            fontType: FontType.bold,
                            color: isSelected ? Colors.white : Colors.green,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                PrimaryButton(
                  onTap: () {
                    if (selectedAmount != null) {
                      ref
                          .read(topUpSessionCreatePro.notifier)
                          .topUpSessionApi(selectedAmount.amount, context);
                    } else {
                      Utils.show("PLease Select Amount", context);
                    }
                  },
                  width: context.sw,
                  label: "Continue",
                ),
                SizedBox(height: context.sh * 0.02),
              ],
            );
          } else {
            return Center(child: AppText(text: 'No data available'));
          }
        },
      ),
    );
  }
}
