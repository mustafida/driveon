// lib/screens/booking_screen.dart

import 'package:flutter/material.dart';
import '../models/car.dart';
import '../models/order.dart';
import '../data/orders_store.dart';
import '../data/user_store.dart';
import 'order_detail_screen.dart';
import 'profile_screen.dart';

class BookingScreen extends StatefulWidget {
  final Car car;

  const BookingScreen({super.key, required this.car});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? _startDate;
  TimeOfDay? _startTime;

  DateTime? _endDate;
  TimeOfDay? _endTime;

  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  @override
  void dispose() {
    _lokasiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // ---------------- PICKER ----------------

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final base = _startDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? base,
      firstDate: base,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pilih Tanggal sewa',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tanggal & jam mulai
                  _dateTimeCard(
                    title: 'Tanggal Pinjam',
                    date: _startDate,
                    time: _startTime,
                    onPickDate: _pickStartDate,
                    onPickTime: _pickStartTime,
                  ),
                  const SizedBox(height: 16),

                  // Tanggal & jam kembali
                  _dateTimeCard(
                    title: 'Tanggal Kembali',
                    date: _endDate,
                    time: _endTime,
                    onPickDate: _pickEndDate,
                    onPickTime: _pickEndTime,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Lokasi Penjemputan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _lokasiController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan lokasi penjemputan',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Catatan Tambahan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan (opsional)',
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tombol konfirmasi (NAIK DIKIT + SAFEAREA)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onConfirmPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Konfirmasi Pemesanan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeCard({
    required String title,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onPickDate,
    required VoidCallback onPickTime,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _smallPickerButton(
                  icon: Icons.calendar_today_rounded,
                  label: date == null
                      ? 'Pilih tanggal'
                      : '${date.day} ${_monthName(date.month)} ${date.year}',
                  onTap: onPickDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _smallPickerButton(
                  icon: Icons.access_time_rounded,
                  label: time == null
                      ? 'Pilih jam'
                      : time.format(context),
                  onTap: onPickTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallPickerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  // ---------------- KONFIRMASI ----------------

  void _onConfirmPressed() {
    final dateStart = _startDate;
    final timeStart = _startTime;
    final dateEnd = _endDate;
    final timeEnd = _endTime;

    if (dateStart == null ||
        timeStart == null ||
        dateEnd == null ||
        timeEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tanggal & jam mulai dan kembali harus diisi')),
      );
      return;
    }

    // gabungkan tanggal + jam
    final start = DateTime(
      dateStart.year,
      dateStart.month,
      dateStart.day,
      timeStart.hour,
      timeStart.minute,
    );
    final end = DateTime(
      dateEnd.year,
      dateEnd.month,
      dateEnd.day,
      timeEnd.hour,
      timeEnd.minute,
    );

    // VALIDASI: end harus setelah start
    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal / jam kembali harus lebih akhir dari tanggal / jam pinjam',
          ),
        ),
      );
      return;
    }

    final userStore = UserStore.instance;

    // kalau belum login -> ke profil / daftar dulu
    if (!userStore.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }

    // sudah login -> buat order & ke detail pesanan
    final store = OrdersStore.instance;
    final id = store.genId();

    final order = Order(
      id: id,
      car: widget.car,
      startDate: start,
      endDate: end,
      pickupLocation: _lokasiController.text.trim(),
      note: _catatanController.text.trim(),
    );

    store.addOrder(order);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(order: order),
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return names[m];
  }
}
