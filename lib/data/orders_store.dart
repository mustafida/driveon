import '../models/order.dart';

class OrdersStore {
  OrdersStore._();

  /// singleton, panggil: OrdersStore.instance
  static final OrdersStore instance = OrdersStore._();

  final List<Order> _orders = [];

  /// hanya bisa dibaca dari luar
  List<Order> get orders => List.unmodifiable(_orders);

  /// id sederhana: 1, 2, 3, ...
  int _idCounter = 0;

  String genId() {
    _idCounter++;
    return _idCounter.toString();
  }

  /// tambah pesanan baru
  void addOrder(Order order) {
    _orders.add(order);
  }

  /// cari order berdasarkan id
  Order? getById(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Hapus pesanan yang:
  /// - status masih UNPAID
  /// - dan waktu pembayaran sudah kadaluarsa (lebih dari 2 jam)
  void removeExpiredUnpaid() {
    _orders.removeWhere(
      (o) => o.status == OrderStatus.unpaid && o.isPaymentExpired,
    );
  }

  /// Dipanggil dari PaymentScreen ketika pembayaran berhasil:
  /// store.markAsPaid(o.id);
  ///
  /// Ubah status dari UNPAID -> RENTED (Sedang disewa)
  void markAsPaid(String id) {
    final order = getById(id);
    if (order == null) return;

    order.status = OrderStatus.rented;
  }

  /// Dipanggil dari tab "Untuk diulas" ketika user pilih bintang:
  /// OrdersStore.instance.setRating(order.id, stars);
  ///
  /// - simpan rating (1–5)
  /// - pindahkan status ke FINISHED (Selesai)
  void setRating(String id, int rating) {
    final order = getById(id);
    if (order == null) return;

    order.rating = rating;
    order.status = OrderStatus.finished;
  }

  /// Versi lama (biar kalau masih ada kode yang pakai setReviewed tidak error)
  /// Kalau reviewed = true, kita anggap rating default = 5 & status FINISHED.
  void setReviewed(String id, bool reviewed) {
    final order = getById(id);
    if (order == null) return;

    if (reviewed) {
      order.rating ??= 5;
      order.status = OrderStatus.finished;
    }
  }

  /// ======== BARU: dipanggil saat user LOGOUT ========
  ///
  /// Hapus semua pesanan & reset idCounter,
  /// supaya setelah ganti akun data pesanan mulai dari nol lagi.
  void clearAll() {
    _orders.clear();
    _idCounter = 0;
  }
}
