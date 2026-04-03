import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/announcement_service.dart';

class AnnouncementManagementScreen extends StatefulWidget {
  const AnnouncementManagementScreen({super.key});

  @override
  State<AnnouncementManagementScreen> createState() => _AnnouncementManagementScreenState();
}

class _AnnouncementManagementScreenState extends State<AnnouncementManagementScreen> {
  final AnnouncementService _service = AnnouncementService();
  late Stream<List<Announcement>> _announcementsStream;

  @override
  void initState() {
    super.initState();
    _announcementsStream = _service.getAllAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Announcement Management', 
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Post deadlines, updates and notifications for students.', 
                      style: TextStyle(color: context.textSec, fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDialog(),
                  icon: const Icon(LucideIcons.megaphone, size: 18),
                  label: const Text('Post New Update'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<List<Announcement>>(
                stream: _announcementsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No announcements posted yet.', style: TextStyle(color: context.textSec)));
                  }

                  final list = snapshot.data!;
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final a = list[index];
                      return _buildAnnouncementTile(a);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementTile(Announcement a) {
    Color typeColor = Colors.blue;
    IconData typeIcon = LucideIcons.info;
    if (a.type == 'Deadline') { typeColor = AppTheme.error; typeIcon = LucideIcons.calendarClock; }
    else if (a.type == 'Update') { typeColor = AppTheme.success; typeIcon = LucideIcons.refreshCw; }

    return Container(
      decoration: context.crispDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(typeIcon, size: 12, color: typeColor),
                    const SizedBox(width: 8),
                    Text(a.type, style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Row(
                children: [
                   IconButton(icon: Icon(LucideIcons.archive, size: 16, color: a.isActive ? context.textSec : AppTheme.error), onPressed: () {
                     _service.updateAnnouncement(a.id, {'isActive': !a.isActive});
                   }),
                   IconButton(icon: const Icon(LucideIcons.trash2, size: 16, color: AppTheme.error), onPressed: () {
                     _service.deleteAnnouncement(a.id);
                   }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(a.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(a.content, style: TextStyle(fontSize: 13, color: context.textSec)),
          const SizedBox(height: 16),
          Text('Posted on: ${a.createdAt.day}/${a.createdAt.month}/${a.createdAt.year}', 
            style: TextStyle(fontSize: 11, color: context.textSec, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  void _showDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedType = 'General';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Post Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['General', 'Update', 'Deadline'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setDialogState(() => selectedType = val!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              TextField(controller: contentController, decoration: const InputDecoration(labelText: 'Message Body'), maxLines: 4),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await _service.postAnnouncement(Announcement(
                  id: '',
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  type: selectedType,
                  createdAt: DateTime.now(),
                  isActive: true,
                ));
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
