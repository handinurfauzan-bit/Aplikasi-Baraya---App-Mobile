import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../services/data_service.dart';

class AddCommunityScreen extends StatefulWidget {
  const AddCommunityScreen({super.key});

  @override
  State<AddCommunityScreen> createState() => _AddCommunityScreenState();
}

class _AddCommunityScreenState extends State<AddCommunityScreen> {
  static const _categories = [
    'Hobi & Komunitas',
    'Gowes & Olahraga',
    'Fotografi & Kreatif',
    'Mendaki & Outdoor',
    'Kuliner',
    'Musik & Seni',
    'Amal & Sosial',
  ];

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Hobi & Komunitas';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit(DataService dataService) {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    if (name.isEmpty || desc.isEmpty) return;

    final currentUser = dataService.currentUser;
    final community = Community(
      id: 'comm_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: desc,
      category: _category,
      adminId: currentUser.id,
      logo: 'assets/logo1.1.png',
      members: [currentUser],
    );
    dataService.addCommunity(community);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Komunitas "${community.name}" berhasil dibuat! Anda adalah admin.',
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataService = context.watch<DataService>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tambah Komunitas'),
            Text(
              'Daftarkan komunitas barumu',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamu akan menjadi Admin',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Kamu bisa menambah tugas untuk anggota dan mengelola komunitasmu setelah terbentuk.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Komunitas',
              hintText: 'misal: Komunitas Lari Pagi',
              prefixIcon: Icon(Icons.groups),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Hobi / Kategori',
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _category = val);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              hintText: 'Ceritakan kegiatan dan tujuan komunitasmu...',
              prefixIcon: Icon(Icons.description_outlined),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              onPressed: () => _submit(dataService),
              icon: const Icon(Icons.add),
              label: const Text('Buat Komunitas'),
            ),
          ),
        ],
      ),
    );
  }
}