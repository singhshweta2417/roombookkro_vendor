import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/utils/context_extensions.dart';
import '../../../core/widgets/custom_scaffold.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../home/offer_view_model.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  String couponType = "private";
  String type = "percentage";

  final maxUsesController = TextEditingController();
  final valueController = TextEditingController();
  final minOrderAmountController = TextEditingController();
  final assignedToController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    maxUsesController.dispose();
    valueController.dispose();
    minOrderAmountController.dispose();
    assignedToController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _createOffer() {
    final val = valueController.text.trim();
    final minOrderAmount = minOrderAmountController.text.trim();
    final assignedTo = assignedToController.text.trim();
    final description = descriptionController.text.trim();
    final maxUses = maxUsesController.text.trim();

    // Validation for limited coupon type
    if (couponType == 'limited') {
      if (maxUses.isEmpty ||
          int.tryParse(maxUses) == null ||
          int.parse(maxUses) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter a valid max uses for limited coupons"),
          ),
        );
        return;
      }
    }

    // Basic validation
    if (val.isEmpty || minOrderAmount.isEmpty || assignedTo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    // Call API
    ref
        .read(createProvider.notifier)
        .createCouponApi(
          couponType: couponType,
          type: type,
          value: val,
          minOrderAmount: minOrderAmount,
          description: description.isEmpty ? null : description,
          maxUses: maxUses.isEmpty ? null : maxUses,
          residentId: assignedTo,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createProvider);
    final isLoading = createState.isLoading;

    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: "Create Offer",
          fontSize: AppConstants.twenty,
          fontType: FontType.bold,
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(height: context.sh * 0.015),

                // Coupon Type Dropdown
                DropdownButtonFormField<String>(
                  value: couponType,
                  decoration: const InputDecoration(
                    labelText: "Select Coupon Type",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "private",
                      child: Text("Private - For specific user"),
                    ),
                    DropdownMenuItem(
                      value: "evergreen",
                      child: Text("Evergreen - Unlimited usage"),
                    ),
                    DropdownMenuItem(
                      value: "limited",
                      child: Text("Limited - Fixed number of uses"),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      couponType = val!;
                      if (couponType != 'limited') {
                        maxUsesController.clear();
                      }
                    });
                  },
                ),

                SizedBox(height: context.sh * 0.02),

                // Discount Type Dropdown
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(
                    labelText: "Select Discount Type",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: "percentage",
                      child: Text("Percentage (%)"),
                    ),
                    DropdownMenuItem(
                      value: "flat",
                      child: Text("Flat Amount (₹)"),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      type = val!;
                    });
                  },
                ),

                SizedBox(height: context.sh * 0.02),

                // Max Uses Field (always visible, but required only for limited)
                CustomTextField(
                  hintText: couponType == 'limited'
                      ? "Maximum number of uses (Required for Limited)"
                      : "Maximum number of uses (Optional)",
                  controller: maxUsesController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.people_outline),
                ),

                SizedBox(height: context.sh * 0.02),

                // Discount Value Field
                CustomTextField(
                  hintText: type == "percentage"
                      ? "Enter percentage (e.g., 10 for 10%)"
                      : "Enter flat amount (e.g., 100 for ₹100)",
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    type == "percentage" ? Icons.percent : Icons.currency_rupee,
                  ),
                ),

                SizedBox(height: context.sh * 0.02),

                // Minimum Order Amount Field
                CustomTextField(
                  hintText: "Minimum order value (e.g., 500)",
                  controller: minOrderAmountController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.shopping_cart_outlined),
                ),

                SizedBox(height: context.sh * 0.02),

                // Assigned To Field
                CustomTextField(
                  hintText: "User/Resident ID",
                  controller: assignedToController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.person_outline),
                ),

                SizedBox(height: context.sh * 0.02),

                // Description Field (Optional)
                CustomTextField(
                  hintText: "Add offer description (Optional)",
                  controller: descriptionController,
                  maxLines: 3,
                  prefixIcon: Icon(Icons.description_outlined),
                ),

                SizedBox(height: context.sh * 0.04),

                // Submit Button
                PrimaryButton(
                  label: "Create Offer",
                  onTap: isLoading ? null : _createOffer,
                ),

                SizedBox(height: context.sh * 0.02),
              ],
            ),
          ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
