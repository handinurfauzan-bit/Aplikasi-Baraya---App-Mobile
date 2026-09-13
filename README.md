# Baraya (kumpul_in)
> **"Satu tempat buat semua urusan komunitasmu"**

Aplikasi koordinasi komunitas hobi berbasis Flutter yang dirancang untuk mengatasi masalah informasi penting yang sering tertimbun obrolan chat grup (WhatsApp/Telegram).

---

## Masalah yang Diselesaikan
Komunitas hobi biasanya berkoordinasi melalui grup chat (WA/Telegram). Namun begitu anggota bertambah banyak, obrolan basa-basi membuat informasi krusial sering terlewat:
- Jadwal event & konfirmasi siapa yang ikut/tidak ikut tenggelam.
- Pengumuman penting dari pengurus tidak terbaca.
- Pembagian tugas kepanitiaan dadakan menjadi kacau dan tidak terlacak.

**Baraya** menyelesaikan masalah ini melalui satu aplikasi yang memisahkan informasi penting dari obrolan kasual.

---

## Fitur Utama

### Onboarding & Akses
- **Splash screen**: logo Baraya dengan aura hijau lembut sebelum masuk.
- **Onboarding 3 langkah**: penjelasan singkat alur aplikasi dengan dot indicator.
- **Login / Register**: form dengan sosial media (Google, Apple, Facebook) dan validasi.

### Beranda (Dashboard)
- **Sapaan dinamis** sesuai nama pengguna yang sedang login.
- **Hero cards event** unggulan dengan gambar dan CTA.
- **Grid fitur pintas**: Komunitas, Event, Diskusi, dan Kas.

### Komunitas
- **Daftar & buat komunitas**: kartu komunitas dengan logo, status keanggotaan, dan tombol gabung.
- **Detail komunitas**: menu Lihat Anggota, Tugas, Diskusi, Kas Komunitas, dan Lokasi Event.
- **Diskusi komunitas**: thread dan balasan yang bisa dibalas langsung dari kartu.

### Event & Jadwal
- **Jadwal & Detail Event**: tanggal, jam, lokasi, dan deskripsi yang jelas.
- **Sistem RSVP**: anggota memilih status (*Ikut*, *Ragu*, *Tidak / Gak Ikut*) dengan penghitungan otomatis.
- **Pengingat H-1**: notifikasi terjadwal 24 jam sebelum acara.
- **Buat Event Baru**: form dengan DatePicker & TimePicker, plus filter pencarian (cari, status RSVP, waktu).

### Tugas Panitia
- **Progress bar real-time**: persentase + jumlah "X dari Y tugas selesai".
- **Checklist terintegrasi ke event**: tugas ditautkan ke event tertentu dengan penugasan anggota.
- **Tambah / hapus tugas**: dialog dengan pilih penanggung jawab.

### Pengumuman
- **Feed khusus info penting**: terpisah dari obrolan kasual.
- **Pin / sematkan** pengumuman penting ke bagian atas.
- **Kategori filter**: Penting, Keuangan, Aturan, Umum.

### Kas Komunitas
- **Ringkasan iuran**: pemasukan vs pengeluaran dengan format Rupiah.
- **Tambah transaksi**: catat pemasukan & pengeluaran komunitas.

### Lokasi Event
- **Peta ilustrasi**: tampilan lokasi event dengan pin dan rute.
- **Detail lokasi**: penjelasan lengkap, tanggal, dan jam kegiatan.

### Notifikasi & Pengaturan
- **Halaman Notifikasi**: daftar pengumuman dengan sematkan (pin).
- **Pengaturan**: mode gelap/terang, dan dialog **Tentang Aplikasi** (info versi & pengembang).

### Profil
- **Kartu profil**: avatar, role, statistik (Komunitas, Tugas, Event Ikut).
- **Tugas Saya**: progres panitia + daftar tugas yang dipegang.
- **Edit profil** dan **Logout** dengan dialog konfirmasi.

---

## Tech Stack & Arsitektur
- **Framework**: [Flutter](https://flutter.dev) (Material 3)
- **State Management**: [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier` reactive architecture)
- **Notifikasi Lokal**: [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) & [`timezone`](https://pub.dev/packages/timezone)
- **Formatting**: [`intl`](https://pub.dev/packages/intl)
- **Persistensi**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)

---

## Struktur Proyek
```text
lib/
├── main.dart                      # Entry point, Theme config, & Provider setup
├── models/
│   └── models.dart                # User, Community, Event, Announcement, Task, dsb.
├── services/
│   ├── data_service.dart          # State reaktif pusat & data seed komunitas
│   ├── app_settings.dart          # Tema gelap/terang & komunitas aktif
│   └── notification_service.dart  # Penjadwalan notifikasi lokal lintas platform
├── widgets/
│   ├── aura_logo.dart             # Logo Baraya dengan aura hijau
│   ├── event_card.dart            # Badge tanggal, aksi RSVP & toggle reminder
│   ├── compact_event_card.dart    # Kartu event versi ringkas
│   ├── announcement_feed.dart     # Filter kategori, kartu pin, toggle semat
│   ├── task_card.dart             # Checklist tugas, tag penanggung jawab
│   ├── about_dialog.dart          # Dialog "Tentang Aplikasi" (shared)
│   └── ...                        # Gradient background, tombol sosial, dsb.
└── screens/
    ├── splash_screen.dart         # Splash logo Baraya
    ├── onboarding_screen.dart     # Perkenalan 3 langkah
    ├── login_screen.dart          # Login dengan sosial media
    ├── register_screen.dart       # Pendaftaran akun
    ├── home_screen.dart           # Dashboard + bottom nav (Beranda, Komunitas, Event, Kas, Profil)
    ├── communities_screen.dart    # Daftar & tambah komunitas
    ├── community_detail_screen.dart # Menu detail komunitas (Anggota, Tugas, Diskusi, Kas, Lokasi)
    ├── members_screen.dart        # Daftar anggota & statistik
    ├── discussions_screen.dart    # Diskusi antar komunitas
    ├── event_detail_screen.dart   # Detail event, RSVP, & tugas panitia
    ├── location_detail_screen.dart# Peta & penjelasan lokasi event
    ├── notification_screen.dart   # Notifikasi pin
    ├── settings_screen.dart       # Mode gelap & tentang aplikasi
    ├── profile_screen.dart        # Profil, tugas saya, edit, logout
    └── ...                        # About, Add Community, Treasury, dsb.
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