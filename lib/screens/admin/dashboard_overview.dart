import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
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
              const SizedBox(height: 32),
              _buildStatsGrid(isMobile),
              const SizedBox(height: 24),
              if (isMobile) ...[
                _buildSubmissionTrend(context),
                const SizedBox(height: 24),
                _buildStatusDistribution(context),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildSubmissionTrend(context)),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildStatusDistribution(context)),
                  ],
                ),
              const SizedBox(height: 32),
              if (isMobile) ...[
                _buildHighRiskStudents(context),
                const SizedBox(height: 24),
                _buildRecentActivity(context),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _buildHighRiskStudents(context)),
                    const SizedBox(width: 32),
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
                  const SizedBox(height: 4),
                  const Text('Real-time analytics and system monitoring.', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            if (!isMobile)
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download),
                label: const Text('Export Report'),
              ),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.download),
              label: const Text('Export Report'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatsGrid(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              _buildStatCard('Total', '1,248', LucideIcons.fileText, AppTheme.primaryColor),
              const SizedBox(width: 16),
              _buildStatCard('Pending', '156', LucideIcons.clock, AppTheme.warning),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('Approved', '982', LucideIcons.checkCircle2, AppTheme.success),
              const SizedBox(width: 16),
              _buildStatCard('Rejected', '110', LucideIcons.alertCircle, AppTheme.error),
            ],
          ),
        ],
      );
    }
    return Row(
      children: [
        _buildStatCard('Total Submissions', '1,248', LucideIcons.fileText, AppTheme.primaryColor),
        const SizedBox(width: 24),
        _buildStatCard('Pending Review', '156', LucideIcons.clock, AppTheme.warning),
        const SizedBox(width: 24),
        _buildStatCard('Approved', '982', LucideIcons.checkCircle2, AppTheme.success),
        const SizedBox(width: 24),
        _buildStatCard('Rejected', '110', LucideIcons.alertCircle, AppTheme.error),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        decoration: AppTheme.glassDecoration(opacity: 0.6, boxShadow: AppTheme.softShadow),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionTrend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration(opacity: 0.6, boxShadow: AppTheme.softShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Submission Trends', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Last 6 Months', style: TextStyle(fontSize: 11, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Weekly document submission counts', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
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
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
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
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(months[value.toInt()], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                          );
                        }
                        return const Text('');
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
      decoration: AppTheme.glassDecoration(opacity: 0.6).copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(color: AppTheme.success, value: 70, title: '70%', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    PieChartSectionData(color: AppTheme.warning, value: 20, title: '20%', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    PieChartSectionData(color: AppTheme.error, value: 10, title: '10%', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLegendItem('Approved', AppTheme.success),
            _buildLegendItem('Pending', AppTheme.warning),
            _buildLegendItem('Rejected', AppTheme.error),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      decoration: AppTheme.glassDecoration(opacity: 0.6).copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent System Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: const Icon(LucideIcons.user, size: 20, color: AppTheme.textSecondary),
                  ),
                  title: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Admin approved ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: 'Juan De La Cruz\'s billing record.'),
                      ],
                    ),
                  ),
                  subtitle: const Text('2 minutes ago', style: TextStyle(fontSize: 12)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Approved', style: TextStyle(color: AppTheme.success, fontSize: 11, fontWeight: FontWeight.bold)),
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
      decoration: AppTheme.glassDecoration(opacity: 0.6).copyWith(
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(LucideIcons.brainCircuit, color: AppTheme.error, size: 18),
                SizedBox(width: 8),
                Text('AI Risk Prediction', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Students likely to submit late or incorrectly', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(),
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
                  title: Text(student['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('ID: ${student['id']}', style: const TextStyle(fontSize: 11)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${risk.toStringAsFixed(1)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('Risk Score', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
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
