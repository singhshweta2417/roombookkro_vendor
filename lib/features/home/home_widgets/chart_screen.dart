import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_book_kro_vendor/core/widgets/custom_container.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../core/constants/app_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../auth/model/statics_model.dart';
import '../../property/view_model/statics_view_model.dart';

class GraphScreen extends ConsumerStatefulWidget {
  const GraphScreen({super.key});

  @override
  ConsumerState<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends ConsumerState<GraphScreen> {
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();

    _tooltip = TooltipBehavior(enable: true);

    Future.microtask(() {
      ref.read(staticsVMProvider.notifier).staticsApi(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final staticsState = ref.watch(staticsVMProvider);

    if (staticsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (staticsState is StaticsSuccess) {
      return buildGraph(context, staticsState.statics);
    }

    return Center(
      child: AppText(
        text: staticsState is StaticsError
            ? staticsState.error
            : "No Data Found",
      ),
    );
  }

  Widget buildGraph(BuildContext context, StaticsModel? statics) {
    if (statics == null || statics.months?.isEmpty == true) {
      return const Center(child: Text("No Data Available"));
    }

    final List<MonthData> chartData = statics.months!
        .where((month) => month.details != null)
        .toList();

    if (chartData.isEmpty) {
      return const Center(child: Text("No Valid Data Available"));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: 'Revenue Statistics',
            fontSize: AppConstants.twenty,
            fontType: FontType.semiBold,
          ),
          const SizedBox(height: 20),

          /// ********* GRAPH CARD **********
          TCustomContainer(
            lightColor: AppColors.background(ref),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            child: SizedBox(
              height: 300,
              child: SfCartesianChart(
                tooltipBehavior: _tooltip,

                primaryXAxis: CategoryAxis(
                  labelRotation: -45,
                  maximumLabels: chartData.length,
                  labelStyle: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                ),

                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(fontSize: 8),
                  axisLine: const AxisLine(color: Colors.grey),
                ),

                series: <CartesianSeries>[
                  ColumnSeries<MonthData, String>(
                    dataSource: chartData,
                    width: 0.6,
                    xValueMapper: (MonthData data, _) => data.key ?? '',
                    yValueMapper: (MonthData data, _) =>
                    data.details?.vendorRevenue?.toDouble() ?? 0,
                    color: AppColors.secondary(ref),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// ********* SUMMARY CARD **********
          TCustomContainer(
            lightColor: AppColors.background(ref),
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'Yearly Summary - ${statics.year ?? DateTime.now().year}',
                  fontSize: AppConstants.sixteen,
                  fontType: FontType.semiBold,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildStatCard(
                      'Total Revenue',
                      '₹${statics.totalVendorRevenue ?? 0}',
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Total Months',
                      '${chartData.length}',
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: TCustomContainer(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        lightColor: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
              text: title,
              color: Colors.grey[700],
              fontSize: AppConstants.twelve,
            ),
            const SizedBox(height: 4),
            AppText(
              text: value,
              color: color,
              fontSize: AppConstants.fourteen,
              fontType: FontType.semiBold,
            ),
          ],
        ),
      ),
    );
  }
}
