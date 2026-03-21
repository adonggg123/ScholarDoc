import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/ml_service.dart';

class DashboardOverview extends StatelessWidget {
  const DashboardOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 900;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isMobile),
              SizedBox(height: 32),
              _buildStatsGrid(context, isMobile),
              SizedBox(height: 24),
              if (isMobile) ...[
                _buildSubmissionTrend(context),
                SizedBox(height: 24),
                _buildStatusDistribution(context),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildSubmissionTrend(context)),
                    SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildStatusDistribution(context)),
                  ],
                ),
              SizedBox(height: 32),
              if (isMobile) ...[
                _buildHighRiskStudents(context),
                SizedBox(height: 24),
                _buildRecentActivity(context),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildHighRiskStudents(context)),
                    SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildRecentActivity(context)),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard Overview', 
                    style: isMobile 
                      ? Theme.of(context).textTheme.titleLarge 
                      : Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 4),
                  Text('Real-time analytics and system monitoring.', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            if (!isMobile)
              ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(LucideIcons.download),
                label: Text('Export Report'),
              ),
          ],
        ),
        if (isMobile) ...[
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(LucideIcons.download),
              label: Text('Export Report'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              _buildStatCard(context, 'Total', '1,248', LucideIcons.fileText, AppTheme.primaryColor),
              SizedBox(width: 16),
              _buildStatCard(context, 'Pending', '156', LucideIcons.clock, AppTheme.warning),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(context, 'Approved', '982', LucideIcons.checkCircle2, AppTheme.success),
              SizedBox(width: 16),
              _buildStatCard(context, 'Rejected', '110', LucideIcons.alertCircle, AppTheme.error),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        _buildStatCard(context, 'Total Submissions', '1,248', LucideIcons.fileText, AppTheme.primaryColor),
        SizedBox(width: 24),
        _buildStatCard(context, 'Pending Review', '156', LucideIcons.clock, AppTheme.warning),
        SizedBox(width: 24),
        _buildStatCard(context, 'Approved', '982', LucideIcons.checkCircle2, AppTheme.success),
        SizedBox(width: 24),
        _buildStatCard(context, 'Rejected', '110', LucideIcons.alertCircle, AppTheme.error),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        decoration: context.crispDecoration,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.textSec, fontSize: 11, fontWeight: FontWeight.w500)),
                    SizedBox(height: 2),
                    Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionTrend(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: context.crispDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Submission Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Last 6 Months', style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('Weekly document submission counts', style: TextStyle(color: context.textSec, fontSize: 13)),
          SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: TextStyle(color: context.textSec, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value >= 0 && value < months.length) {
                          return Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(months[value.toInt()], style: TextStyle(color: context.textSec, fontSize: 10)),
                          );
                        }
                        return Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 3), FlSpot(1, 1), FlSpot(2, 4), FlSpot(3, 2), FlSpot(4, 5), FlSpot(5, 3)],
                    isCurved: true,
                    gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryColor.withValues(alpha: 0.2), AppTheme.primaryColor.withValues(alpha: 0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context) {
    return Container(
      decoration: context.glassDecoration.copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: AppTheme.success, value: 70, title: '70%', radius: 45, titleStyle: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold, fontSize: 12)),
                    PieChartSectionData(color: AppTheme.warning, value: 20, title: '20%', radius: 45, titleStyle: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold, fontSize: 12)),
                    PieChartSectionData(color: AppTheme.error, value: 10, title: '10%', radius: 45, titleStyle: TextStyle(color: context.surfaceC, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildLegendItem(context, 'Approved', AppTheme.success),
            _buildLegendItem(context, 'Pending', AppTheme.warning),
            _buildLegendItem(context, 'Rejected', AppTheme.error),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      decoration: context.glassDecoration.copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent System Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(LucideIcons.user, size: 20, color: context.textSec),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: TextStyle(color: context.textPri, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Admin approved ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'Juan De La Cruz\'s billing record.'),
                      ],
                    ),
                  ),
                  subtitle: Text('2 minutes ago', style: TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Approved', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildHighRiskStudents(BuildContext context) {
    final MLService ml = MLService();
    
    // Mock students for dashboard analytics
    final students = [
      {'name': 'Maria Clara', 'id': '2022-0192', 'pastLateSubmissions': 3, 'familyDetails': null},
      {'name': 'Jose Rizal', 'id': '2021-0042', 'pastLateSubmissions': 1, 'familyDetails': {'income': 'Low'}},
      {'name': 'Andres Bonifacio', 'id': '2023-1122', 'pastLateSubmissions': 0, 'familyDetails': null},
      {'name': 'Gabriela Silang', 'id': '2022-0811', 'pastLateSubmissions': 4, 'familyDetails': {}},
    ];

    // Auto-sort by highest risk first
    students.sort((a, b) => ml.predictSubmissionRisk(b).compareTo(ml.predictSubmissionRisk(a)));

    return Container(
      decoration: context.glassDecoration.copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.brainCircuit, color: AppTheme.error, size: 18),
                SizedBox(width: 8),
                Text('AI Risk Prediction', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 4),
            Text('Students likely to submit late or incorrectly', style: TextStyle(fontSize: 12, color: context.textSec)),
            SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final student = students[index];
                final risk = ml.predictSubmissionRisk(student);
                final color = risk > 80 ? AppTheme.error : (risk > 50 ? AppTheme.warning : AppTheme.success);
                
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(LucideIcons.alertTriangle, size: 18, color: color),
                  ),
                  title: Text(student['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('ID: ${student['id']}', style: TextStyle(fontSize: 11)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${risk.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Risk Score', style: TextStyle(fontSize: 9, color: context.textSec)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
