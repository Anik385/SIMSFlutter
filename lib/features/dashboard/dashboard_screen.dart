import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../home_shell.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => p.load(),
        child: p.loading && p.stats.totalProducts == 0
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _stat('Total Products', '${p.stats.totalProducts}',
                          Icons.inventory_2, AppColors.primary, AppColors.primaryDark),
                      _stat('Revenue',
                          '\$${Formatters.compact(p.stats.totalRevenue)}',
                          Icons.attach_money, const Color(0xFF10b981),
                          const Color(0xFF059669)),
                      _stat('This Month',
                          '\$${Formatters.compact(p.stats.monthlyRevenue)}',
                          Icons.trending_up, const Color(0xFF3b82f6),
                          const Color(0xFF1d4ed8)),
                      _stat('Low Stock', '${p.stats.lowStockCount}',
                          Icons.warning_amber, const Color(0xFFf59e0b),
                          const Color(0xFFd97706)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _card(
                    title: 'Sales Trend (Last 7 days)',
                    child: SizedBox(height: 200, child: _lineChart(p.trend)),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    title: 'Top Selling Products',
                    child: SizedBox(height: 200, child: _barChart(p.topProducts)),
                  ),
                  const SizedBox(height: 16),
                  _card(
                    title: 'Low Stock Alerts',
                    child: p.lowStock.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('No low stock items',
                                style: TextStyle(color: Colors.grey.shade600)),
                          )
                        : Column(
                            children: p.lowStock.take(5).map((prod) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.warning.withOpacity(0.15),
                                  child: const Icon(Icons.warning_amber,
                                      color: AppColors.warning),
                                ),
                                title: Text(prod.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text('SKU: ${prod.sku}'),
                                trailing: Text('${prod.quantity}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.danger)),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color a, Color b) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [a, b],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: a.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white70),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _lineChart(List trend) {
    if (trend.isEmpty) return const Center(child: Text('No data'));
    final spots = List.generate(trend.length,
        (i) => FlSpot(i.toDouble(), (trend[i].total as num).toDouble()));
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= trend.length) return const SizedBox();
                return Text(Formatters.shortDate(trend[i].date),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _barChart(List top) {
    if (top.isEmpty) return const Center(child: Text('No data'));
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= top.length) return const SizedBox();
                final name = top[i].name as String;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(name.length > 6 ? name.substring(0, 6) : name,
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(top.length, (i) {
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: (top[i].quantity as num).toDouble(),
              color: AppColors.primary,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ]);
        }),
      ),
    );
  }
}