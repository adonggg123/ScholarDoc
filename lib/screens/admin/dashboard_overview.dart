import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/ml_service.dart';
import '../../services/auth_service.dart';
import '../../services/audit_service.dart';
import '../../services/report_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({super.key});

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  final AuthService _authService = AuthService();
  final AuditService _auditService = AuditService();
  final ReportService _reportService = ReportService();

  late Stream<QuerySnapshot> _studentsStream;
  late Stream<QuerySnapshot> _auditLogsStream;
  late Stream<List<double>> _submissionTrendStream;

  @override
  void initState() {
    super.initState();
    _studentsStream = _authService.getStudentsStream();
    _auditLogsStream = _auditService.getAuditLogsStream(limit: 5);
    _submissionTrendStream = _reportService.getMonthlySubmissionTrend();
  }

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
                  Text(
                    'Dashboard Overview',
                    style:
                        (isMobile
                                ? Theme.of(context).textTheme.titleLarge
                                : Theme.of(context).textTheme.headlineSmall)
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: context.textPri,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time system analytics and monitor.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSec,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, bool isMobile) {
    return StreamBuilder<QuerySnapshot>(
      stream: _studentsStream,
      builder: (context, snapshot) {
        int total = 0;
        int pending = 0;
        int approved = 0;
        int rejected = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          total = docs.length;
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            if (status == 'Pending')
              pending++;
            else if (status == 'Approved')
              approved++;
            else if (status == 'Rejected')
              rejected++;
          }
        }

        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  _buildStatCard(
                    context,
                    'Total',
                    total.toString(),
                    LucideIcons.fileText,
                    AppTheme.primaryColor,
                  ),
                  SizedBox(width: 16),
                  _buildStatCard(
                    context,
                    'Pending',
                    pending.toString(),
                    LucideIcons.clock,
                    AppTheme.warning,
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard(
                    context,
                    'Approved',
                    approved.toString(),
                    LucideIcons.checkCircle2,
                    AppTheme.success,
                  ),
                  SizedBox(width: 16),
                  _buildStatCard(
                    context,
                    'Rejected',
                    rejected.toString(),
                    LucideIcons.alertCircle,
                    AppTheme.error,
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            _buildStatCard(
              context,
              'Total Students',
              total.toString(),
              LucideIcons.fileText,
              AppTheme.primaryColor,
            ),
            SizedBox(width: 16),
            _buildStatCard(
              context,
              'Pending Review',
              pending.toString(),
              LucideIcons.clock,
              AppTheme.warning,
            ),
            SizedBox(width: 16),
            _buildStatCard(
              context,
              'Approved',
              approved.toString(),
              LucideIcons.checkCircle2,
              AppTheme.success,
            ),
            SizedBox(width: 16),
            _buildStatCard(
              context,
              'Rejected',
              rejected.toString(),
              LucideIcons.alertCircle,
              AppTheme.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        decoration: context.crispDecoration.copyWith(
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(icon, color: color, size: 14),
                  ),
                  Icon(
                    LucideIcons.moreHorizontal,
                    size: 12,
                    color: context.textSec.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  height: 1.1,
                  color: context.textPri,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
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
      padding: const EdgeInsets.all(12),
      decoration: context.crispDecoration.copyWith(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submission Trends',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: context.textPri,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Last 6 Months',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Weekly document submission counts',
            style: TextStyle(
              color: context.textSec,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: StreamBuilder<List<double>>(
              stream: _submissionTrendStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                  );
                }

                final dataPoints = snapshot.data!;
                final List<FlSpot> spots = [];
                for (int i = 0; i < dataPoints.length; i++) {
                  spots.add(FlSpot(i.toDouble(), dataPoints[i]));
                }

                return LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: context.textSec,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final now = DateTime.now();
                            final months = [];
                            for (int i = 5; i >= 0; i--) {
                              months.add(
                                DateFormat(
                                  'MMM',
                                ).format(DateTime(now.year, now.month - i, 1)),
                              );
                            }
                            if (value == value.toInt() &&
                                value >= 0 &&
                                value < months.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Text(
                                  months[value.toInt()],
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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
                        spots: spots.isEmpty ? [FlSpot(0, 0)] : spots,
                        isCurved: true,
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                              AppTheme.primaryColor.withValues(alpha: 0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDistribution(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _studentsStream,
      builder: (context, snapshot) {
        double pending = 0;
        double approved = 0;
        double rejected = 0;
        double total = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;
          total = docs.length.toDouble();
          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            if (status == 'Pending')
              pending++;
            else if (status == 'Approved')
              approved++;
            else if (status == 'Rejected')
              rejected++;
          }
        }

        bool hasData = total > 0;
        double pPer = hasData ? (pending / total) * 100 : 0;
        double aPer = hasData ? (approved / total) * 100 : 0;
        double rPer = hasData ? (rejected / total) * 100 : 0;

        return Container(
          decoration: context.glassDecoration.copyWith(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Distribution',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: context.textPri,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 130,
                  child: hasData
                      ? PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 35,
                            sections: [
                              if (approved > 0)
                                PieChartSectionData(
                                  color: AppTheme.success,
                                  value: approved,
                                  title: '${aPer.toStringAsFixed(0)}%',
                                  radius: 40,
                                  titleStyle: TextStyle(
                                    color: context.surfaceC,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              if (pending > 0)
                                PieChartSectionData(
                                  color: AppTheme.warning,
                                  value: pending,
                                  title: '${pPer.toStringAsFixed(0)}%',
                                  radius: 40,
                                  titleStyle: TextStyle(
                                    color: context.surfaceC,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              if (rejected > 0)
                                PieChartSectionData(
                                  color: AppTheme.error,
                                  value: rejected,
                                  title: '${rPer.toStringAsFixed(0)}%',
                                  radius: 40,
                                  titleStyle: TextStyle(
                                    color: context.surfaceC,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Center(child: Text('No data')),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem(context, 'Approved', AppTheme.success),
                    _buildLegendItem(context, 'Pending', AppTheme.warning),
                    _buildLegendItem(context, 'Rejected', AppTheme.error),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.textPri,
          ),
        ),
      ],
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
            Text(
              'Recent System Activity',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: _auditLogsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No system logs available.',
                        style: TextStyle(color: context.textSec, fontSize: 13),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String adminName = data['adminName'] ?? 'System';
                    final String action =
                        data['action'] ?? 'Performed an action';
                    final String role = data['role'] ?? 'System';
                    final Timestamp? ts = data['timestamp'];
                    final String timeStr = ts != null
                        ? DateFormat('hh:mm a').format(ts.toDate())
                        : 'Just now';

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor:
                            (role == 'Admin'
                                    ? AppTheme.primaryColor
                                    : AppTheme.secondaryColor)
                                .withValues(alpha: 0.1),
                        child: Icon(
                          role == 'Admin'
                              ? LucideIcons.shieldCheck
                              : LucideIcons.user,
                          size: 18,
                          color: role == 'Admin'
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryColor,
                        ),
                      ),
                      title: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: adminName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' $action'),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        timeStr,
                        style: TextStyle(fontSize: 11, color: context.textSec),
                      ),
                      trailing: role == 'Admin'
                          ? Icon(
                              LucideIcons.check,
                              size: 14,
                              color: AppTheme.success,
                            )
                          : null,
                    );
                  },
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
                Text(
                  'AI Risk Prediction',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Students likely to submit late or incorrectly',
              style: TextStyle(fontSize: 12, color: context.textSec),
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: _studentsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'No student data available.',
                        style: TextStyle(color: context.textSec, fontSize: 13),
                      ),
                    ),
                  );
                }

                // Process real students
                final List<Map<String, dynamic>> students = snapshot.data!.docs
                    .map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return {
                        'name': data['fullName'] ?? 'N/A',
                        'id': data['studentId'] ?? 'N/A',
                        'profilePictureUrl': data['profilePictureUrl'] ?? '',
                        'pastLateSubmissions':
                            0, // In a real app, this would be a field
                        'familyDetails': data['familyDetails'],
                      };
                    })
                    .toList();

                // Auto-sort by highest risk first
                students.sort(
                  (a, b) => ml
                      .predictSubmissionRisk(b)
                      .compareTo(ml.predictSubmissionRisk(a)),
                );

                // Take top 4
                final topRiskStudents = students.take(4).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topRiskStudents.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    final student = topRiskStudents[index];
                    final risk = ml.predictSubmissionRisk(student);
                    final color = risk > 80
                        ? AppTheme.error
                        : (risk > 50 ? AppTheme.warning : AppTheme.success);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: () {
                        final String photoUrl =
                            student['profilePictureUrl'] as String? ?? '';
                        if (photoUrl.isNotEmpty) {
                          return CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.1),
                            backgroundImage: NetworkImage(photoUrl),
                          );
                        }
                        return CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.1),
                          child: Icon(
                            LucideIcons.alertTriangle,
                            size: 18,
                            color: color,
                          ),
                        );
                      }(),
                      title: Text(
                        student['name'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${student['id']}',
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${risk.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Risk Score',
                            style: TextStyle(
                              fontSize: 9,
                              color: context.textSec,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
