import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:room_book_kro_vendor/features/profile/view_model/policy_view_model.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/custom_scaffold.dart';

class PolicyScreen extends ConsumerStatefulWidget {
  const PolicyScreen({super.key});

  @override
  ConsumerState<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends ConsumerState<PolicyScreen> {
  String? policyId;
  String? title;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    policyId = args?['id'];
    title = args?['title'];

    if (policyId != null) {
      // Call API when screen loads
      Future.microtask(() {
        ref.read(policiesProvider.notifier).policyApi(policyId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(policiesProvider);
    return CustomScaffold(
      appBar: CustomAppBar(
        middle: AppText(
          text: title ?? '',
          fontType: FontType.bold,
          fontSize: AppConstants.twentyFive,
        ),
      ),
      child: Builder(
        builder: (context) {
          if (state is PolicyLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.secondary(ref)),
            );
          } else if (state is PolicyError) {
            return Center(child: AppText(text: 'Error: ${state.error}'));
          } else if (state is PolicySuccess) {
            final data = state.profile;
            return SingleChildScrollView(
              child: HtmlWidget(
                data?.html.toString() ?? '',
                textStyle: TextStyle(fontFamily: "Urbanist"),
              ),
            );
          } else {
            return const Center(child: AppText(text: 'No Data'));
          }
        },
      ),
    );
  }
}
