// lib/models/order.dart

import 'car.dart';

/// Status sederhana
enum OrderStatus {
  unpaid,   // Belum dibayar
  rented,   // Sedang disewa
  finished, // Selesai, bisa diulas / riwayat
}

class Order {
  final String id;
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String note;

  OrderStatus status;
  int? rating; // 1–5 bintang

  // 👉 tambahan helper: dianggap sudah diulas kalau rating != null
  bool get reviewed => rating != null;

  final DateTime createdAt;
  final Duration paymentDeadline; // default: 2 jam

  Order({
    required this.id,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.note,
    this.status = OrderStatus.unpaid,
    this.rating,
    DateTime? createdAt,
    Duration? paymentDeadline,
  })  : createdAt = createdAt ?? DateTime.now(),
        paymentDeadline = paymentDeadline ?? const Duration(hours: 2);

  /// Waktu kadaluarsa pembayaran
  DateTime get paymentExpiredAt => createdAt.add(paymentDeadline);

  /// Apakah pembayaran sudah kadaluarsa
  bool get isPaymentExpired => DateTime.now().isAfter(paymentExpiredAt);

  /// Lama sewa minimal 1 hari
  int get totalDays {
    final days = endDate.difference(startDate).inDays;
    return days <= 0 ? 1 : days;
  }

  /// Subtotal = harga per hari x jumlah hari
  int get subtotal => totalDays * car.pricePerDay;

  /// Trip fee dummy (biar sama kayak desain figma)
  int get tripFee => 1000;

  /// Total bayar
  int get total => subtotal + tripFee;
}
