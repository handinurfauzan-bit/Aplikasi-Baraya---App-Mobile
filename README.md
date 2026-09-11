# Baraya 
> **"Satu tempat buat semua urusan komunitasmu"**

Aplikasi koordinasi komunitas hobi yang dirancang untuk mengatasi masalah informasi penting yang sering tertimbun obrolan chat grup (WhatsApp/Telegram).

---

##  Masalah yang Diselesaikan
Komunitas hobi biasanya berkoordinasi melalui grup chat (WA/Telegram). Namun begitu anggota bertambah banyak, obrolan basa-basi membuat informasi krusial sering terlewat:
- Jadwal event & konfirmasi siapa yang ikut/tidak ikut tenggelam.
- Pengumuman penting dari pengurus tidak terbaca.
- Pembagian tugas kepanitiaan dadakan menjadi kacau dan tidak terlacak.

**Baraya** menyelesaikan masalah ini dengan 3 fitur inti yang saling terhubung secara koheren:

---

## 3 Fitur Inti

### 1. Event & Jadwal
- **Jadwal & Detail Event**: Informasi tanggal, jam, rute, dan titik kumpul yang jelas.
- **Sistem RSVP Real-time**: Anggota dapat memilih status kehadiran (*Ikut*, *Ragu*, *Gak Ikut*) dengan penghitungan kuorum otomatis.
- **Pengingat H-1 (Reminder)**: Notifikasi terjadwal 24 jam sebelum acara dimulai agar anggota tidak lupa.
- **Buat Event Baru**: Form pembuatan event komunitas dengan DatePicker dan TimePicker.

### 2. 📢 Pengumuman Terpisah dari Obrolan
- **Feed Khusus Info Penting**: Terpisah total dari obrolan kasual sehingga tidak ada info yang tertimbun.
- **Fitur Pin / Sematkan**: Pengumuman penting (seperti rute darurat atau info iuran kas) dapat di-pin di bagian atas.
- **Kategori Pengumuman**: Filter cepat berdasarkan tag (*Penting*, *Keuangan*, *Aturan*, *Umum*).
- **Detail Pengumuman**: Modal sheet lengkap dengan identitas pengurus yang menerbitkan.

### 3. Pembagian Tugas Simpel (Checklist Panitia Dadakan)
- **Checklist Terintegrasi ke Event**: Setiap tugas secara langsung tertaut dengan event tertentu (misal: "Gowes Minggu Pagi" butuh konsumsi & pompa).
- **Penugasan Anggota (Assignment)**: Tugas dapat ditugaskan ke satu atau beberapa anggota komunitas.
- **Progress Bar Real-time**: Melacak persentase penyelesaian tugas panitia (*Contoh: 3 dari 6 selesai - 50%*).
- **Checklist Interaktif**: Klik untuk menyelesaikan tugas dengan animasi visual coret (strike-through).

---

## Tech Stack & Arsitektur
- **Framework**: [Flutter](https://flutter.dev) (v3.44+, Material 3)
- **State Management**: [`Provider`](https://pub.dev/packages/provider) (`ChangeNotifier` reactive architecture)
- **Notifikasi Lokal**: [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) & [`timezone`](https://pub.dev/packages/timezone)
- **Formatting**: [`intl`](https://pub.dev/packages/intl)
- **Persistensi**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)

---

## Struktur Proyek
```text
lib/
├── main.dart                      # Entry point, Theme configuration, & Provider setup
├── models/
│   └── models.dart                # User, Community, Event, Announcement, Task models
├── services/
│   ├── data_service.dart          # Central reactive state & mock community data
│   └── notification_service.dart  # Cross-platform local notification handler
├── widgets/
│   ├── event_card.dart            # Date badge, RSVP actions, task counter & reminder toggle
│   ├── announcement_feed.dart     # Category filter chips, pinned cards & toggle pin
│   └── task_card.dart             # Checkbox toggle, assignee tags, strike-through
└── screens/
    └── home_screen.dart           # Tabbed dashboard (Event, Pengumuman, Tugas) & dialogs
```

---

## Cara Menjalankan

1. **Pastikan dependensi terpasang**:
   ```bash
   flutter pub get
   ```

2. **Jalankan analisis kode**:
   ```bash
   flutter analyze
   ```

3. **Jalankan pengujian (Unit/Widget Test)**:
   ```bash
   flutter test
   ```

4. **Jalankan aplikasi**:
   ```bash
   # Di macOS Desktop
   flutter run -d macos

   # Atau di Chrome
   flutter run -d chrome
   ```
