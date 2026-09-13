import 'package:flutter/material.dart';

void showAboutAppDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Tentang Aplikasi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Image.asset(
                    'assets/logo1.1.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Baraya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'v1.0.0',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Aplikasi koordinasi komunitas: kelola event, pengumuman, '
              'dan tugas panitia dalam satu tempat.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const Divider(height: 28),
            const Text(
              'Pengembang',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('Handi Nurfauzan'),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.mail_outline, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text('handinurfauzan@gmail.com'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: const Text('Tutup'),
        ),
      ],
    ),
  );
}