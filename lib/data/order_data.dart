// lib/data/order_data.dart
import '../models/car.dart';

class Order {
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String note;
  final int totalDays;
  final int totalPrice;
  final DateTime createdAt;

  // status nanti bisa: 'Belum dibayar', 'Disewa', 'Selesai'
  String status;

  Order({
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    required this.note,
    required this.totalDays,
    required this.totalPrice,
    required this.createdAt,
    required this.status,
  });
}

// sementara kita simpan semua pesanan di list global sederhana
List<Order> allOrders = [];
