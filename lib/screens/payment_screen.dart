// lib/screens/payment_screen.dart

import 'package:flutter/material.dart';

import '../data/orders_store.dart';
import '../models/order.dart';
import '../utils/format_price.dart';
import 'payment_method_screen.dart';

class PaymentScreen extends StatefulWidget {
  /// daftar id order yang mau dibayar (bisa 1 atau lebih)
  final List<String> orderIds;

  /// kalau true => tampilkan kartu info order utama di atas
  /// kalau false => hide (dipakai kalau datang dari tab Pesanan)
  final bool showMainOrderCard;

  const PaymentScreen({
    super.key,
    required this.orderIds,
    this.showMainOrderCard = true,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final OrdersStore _store = OrdersStore.instance;

  late final List<Order> _orders;

  /// metode pembayaran terpilih (null = belum pilih)
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();

    // Ambil order berdasarkan id yang dikirim dari OrdersScreen / OrderDetail
    _orders = widget.orderIds
        .map((id) => _store.getById(id))
        .whereType<Order>()
        .toList();
  }

  int get _total {
    int sum = 0;
    for (final o in _orders) {
      sum += o.total;
    }
    return sum;
  }

  String _dateText(DateTime d) =>
      '${d.day} ${_monthName(d.month)} ${d.year} 12.00';

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[m - 1];
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);
    final order = _orders.isNotEmpty ? _orders.first : null;

    // tampilkan kartu utama hanya kalau:
    // - showMainOrderCard = true, dan
    // - cuma ada 1 order
    final bool showMainCard =
        widget.showMainOrderCard && _orders.length == 1 && order != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Selesaikan Pembayaran',
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
          // ======== LIST + DETAIL + METODE (scrollable) ========
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu utama hanya kalau datang dari Home (showMainOrderCard = true)
                  if (showMainCard) ...[
                    _mainOrderCard(order!),
                    const SizedBox(height: 16),
                  ],

                  // Jika ada lebih dari satu order, tampilkan kartu2 kecil tambahan
                  if (_orders.length > 1) ...[
                    for (final o in _orders)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _miniOrderCard(o),
                      ),
                    const SizedBox(height: 4),
                  ],

                  // ----- DETAILS (subtotal, trip fee, total) -----
                  const Text(
                    'Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final o in _orders)
                          _detailRow(
                            left:
                                'Rp.${formatPrice(o.car.pricePerDay)} × ${o.totalDays} hari',
                            right: 'Rp.${formatPrice(o.subtotal)}',
                          ),
                        _detailRow(
                          left: 'Trip Free',
                          right:
                              'Rp.${formatPrice(_orders.fold<int>(0, (s, o) => s + o.tripFee))}',
                        ),
                        const Divider(),
                        _detailRow(
                          left: 'Total',
                          right: 'Rp.${formatPrice(_total)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ----- METODE PEMBAYARAN -----
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // kalau belum pilih => tombol "Pilih Metode Pembayaran"
                  if (_selectedMethod == null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openMethodPicker,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          child: const Text(
                            'Pilih Metode Pembayaran',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    // kalau sudah pilih => kartu putih + nama metode + radio merah
                    GestureDetector(
                      onTap: _openMethodPicker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Text(
                              _selectedMethod!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.radio_button_checked,
                              color: Colors.red,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // ======== TOTAL + KONFIRMASI (fixed di bawah) ========
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor: primaryBlue,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Total   Rp.${formatPrice(_total)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (_selectedMethod == null) ? null : _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor: Colors.grey,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Konfirmasi Pembayaran',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ---------- helper widgets ----------

  /// Kartu utama di bagian atas: menampilkan mobil + tanggal pinjam & kembali
  Widget _mainOrderCard(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.car.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tanggal Pinjam',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _dateText(order.startDate),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tanggal Kembali',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _dateText(order.endDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 90,
            child: Image.asset(
              order.car.imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu kecil per-order (kalau ada lebih dari 1 order)
  Widget _miniOrderCard(Order order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.car.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tanggal Pinjam: ${_dateText(order.startDate)}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Tanggal Kembali: ${_dateText(order.endDate)}',
                  style: const TextStyle(fontSize: 11),
                ),
                Text(
                  'Total: Rp ${formatPrice(order.total)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 60,
            child: Image.asset(
              order.car.imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow({
    required String left,
    required String right,
    bool isBold = false,
  }) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(left, style: style),
          Text(right, style: style),
        ],
      ),
    );
  }

  // ---------- actions ----------

  Future<void> _openMethodPicker() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(
          initialMethod: _selectedMethod,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      setState(() {
        _selectedMethod = result;
      });
    }
  }

  void _confirmPayment() {
    for (final o in _orders) {
      _store.markAsPaid(o.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pembayaran berhasil dengan metode $_selectedMethod',
        ),
      ),
    );

    // kembali ke home (root)
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
