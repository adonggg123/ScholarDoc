import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isMobile),
              SizedBox(height: 32),
              if (isMobile) ...[
                _buildSystemPerformance(context),
                SizedBox(height: 24),
                _buildDemographicBreakdown(context),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildSystemPerformance(context)),
                    SizedBox(width: 32),
                    Expanded(flex: 2, child: _buildDemographicBreakdown(context)),
                  ],
                ),
              SizedBox(height: 32),
              Text('Generated Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              _buildReportList(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analytics & Reports', 
                style: isMobile 
                  ? Theme.of(context).textTheme.titleLarge 
                  : Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 4),
              Text('Deep-dive institutional metrics and printable exports.', style: TextStyle(color: context.textSec)),
            ],
          ),
        ),
        if (!isMobile)
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(LucideIcons.printer),
            label: Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
      ],
    );
  }

  Widget _buildSystemPerformance(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: context.glassDecoration.copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Application Throughput', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: 'This Year',
                underline: SizedBox(),
                items: ['This Week', 'This Month', 'This Year'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) {},
              ),
            ],
          ),
          SizedBox(height: 4),
          Text('Total documents scanned vs. approved over time.', style: TextStyle(fontSize: 12, color: context.textSec)),
          SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 200,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        TextStyle style = TextStyle(color: context.textSec, fontWeight: FontWeight.bold, fontSize: 11);
                        String text;
                        switch (value.toInt()) {
                          case 0: text = 'Q1'; break;
                          case 1: text = 'Q2'; break;
                          case 2: text = 'Q3'; break;
                          case 3: text = 'Q4'; break;
                          default: text = '';
                        }
                        return Padding(padding: EdgeInsets.only(top: 8), child: Text(text, style: style));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                barGroups: [
                  _makeGroupData(0, 150, 120),
                  _makeGroupData(1, 180, 150),
                  _makeGroupData(2, 130, 90),
                  _makeGroupData(3, 190, 175),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendIndicator(context, 'Total Submissions', AppTheme.primaryColor.withValues(alpha: 0.3)),
              SizedBox(width: 16),
              _legendIndicator(context, 'Approved', AppTheme.primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: y2,
          color: AppTheme.primaryColor,
          width: 16,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        ),
      ],
      barsSpace: 4,
    );
  }

  Widget _legendIndicator(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 12, color: context.textSec)),
      ],
    );
  }

  Widget _buildDemographicBreakdown(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: context.glassDecoration.copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Approval by College', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Success rates across university departments.', style: TextStyle(fontSize: 12, color: context.textSec)),
          SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(color: AppTheme.primaryColor, value: 40, title: 'CAS', radius: 40, titleStyle: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold, fontSize: 11)),
                  PieChartSectionData(color: AppTheme.secondaryColor, value: 30, title: 'CCS', radius: 45, titleStyle: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold, fontSize: 11)),
                  PieChartSectionData(color: AppTheme.success, value: 20, title: 'COE', radius: 35, titleStyle: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold, fontSize: 11)),
                  PieChartSectionData(color: AppTheme.warning, value: 10, title: 'CBA', radius: 30, titleStyle: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ),
          SizedBox(height: 32),
          _collegeLegend('College of Arts and Sciences', '40%', AppTheme.primaryColor),
          _collegeLegend('College of Computer Studies', '30%', AppTheme.secondaryColor),
          _collegeLegend('College of Engineering', '20%', AppTheme.success),
          _collegeLegend('College of Business Admin', '10%', AppTheme.warning),
        ],
      ),
    );
  }

  Widget _collegeLegend(String name, String percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              SizedBox(width: 8),
              Text(name, style: TextStyle(fontSize: 12)),
            ],
          ),
          Text(percentage, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReportList(BuildContext context) {
    final reports = [
      {'title': 'Q3 2025 Submission Integrity Report', 'date': 'Pending Generation', 'icon': LucideIcons.bot, 'color': AppTheme.secondaryColor},
      {'title': 'Annual Institutional Demographic Summary', 'date': 'Generated: Oct 12, 2025', 'icon': LucideIcons.users, 'color': AppTheme.primaryColor},
      {'title': 'Late Submissions Trend Report', 'date': 'Generated: Sep 05, 2025', 'icon': LucideIcons.clock, 'color': AppTheme.warning},
      {'title': 'Identified Fraud & Duplicate Log', 'date': 'Generated: Aug 28, 2025', 'icon': LucideIcons.fileWarning, 'color': AppTheme.error},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = reports[index];
        return Container(
          decoration: context.glassDecoration,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: (r['color'] as Color).withValues(alpha: 0.1),
              child: Icon(r['icon'] as IconData, color: r['color'] as Color, size: 20),
            ),
            title: Text(r['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(r['date'] as String, style: TextStyle(fontSize: 12, color: context.textSec)),
            trailing: IconButton(
              icon: Icon(LucideIcons.download, size: 20, color: context.textSec),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
