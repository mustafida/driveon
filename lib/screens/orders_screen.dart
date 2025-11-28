// lib/screens/orders_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';

import '../data/orders_store.dart';
import '../models/order.dart';
import '../utils/format_price.dart';
import 'order_detail_screen.dart';
import 'payment_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersStore _store = OrdersStore.instance;

  int _tabIndex = 0; // 0 = Belum dibayar, 1 = Disewa, 2 = Untuk diulas
  String _search = '';
  final TextEditingController _searchController = TextEditingController();

  late Timer _timer;

  /// id-id pesanan yang dipilih (hanya untuk tab "Belum dibayar")
  final Set<String> _selectedUnpaidIds = {};

  @override
  void initState() {
    super.initState();
    // timer untuk update countdown & hapus pesanan kadaluarsa
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _store.removeExpiredUnpaid();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Order> get _filtered {
    List<Order> list = _store.orders.where((o) {
      switch (_tabIndex) {
        case 0:
          return o.status == OrderStatus.unpaid;
        case 1:
          return o.status == OrderStatus.rented;
        case 2:
          return o.status == OrderStatus.finished;
        default:
          return false;
      }
    }).toList();

    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((o) => o.car.name.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  int get _selectedTotal {
    if (_tabIndex != 0) return 0;
    int sum = 0;
    for (final o in _store.orders) {
      if (_selectedUnpaidIds.contains(o.id) &&
          o.status == OrderStatus.unpaid) {
        sum += o.total;
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'Pesanan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Search
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      hintText: 'Cari pesanan Anda',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (_search.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _search = '');
                    },
                    child: const Icon(Icons.close_rounded, size: 20),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Tab bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _tabButton(0, 'Belum dibayar'),
              _tabButton(1, 'Disewa'),
              _tabButton(2, 'Untuk diulas'),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // List + bar bayar (khusus tab 0)
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text('Belum ada pesanan'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final order = _filtered[index];
                          switch (_tabIndex) {
                            case 0:
                              return _UnpaidOrderCard(
                                order: order,
                                selected: _selectedUnpaidIds
                                    .contains(order.id),
                                onSelectedChanged: (v) {
                                  setState(() {
                                    if (v == true) {
                                      _selectedUnpaidIds.add(order.id);
                                    } else {
                                      _selectedUnpaidIds.remove(order.id);
                                    }
                                  });
                                },
                              );
                            case 1:
                              return _RentedOrderCard(order: order);
                            case 2:
                              return _ReviewOrderCard(
                                order: order,
                                onReviewed: (stars) {
                                  OrdersStore.instance
                                      .setRating(order.id, stars);
                                  setState(() {});
                                },
                              );
                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      ),
              ),

              // BAR BAYAR BAWAH (hanya tab "Belum dibayar")
              if (_tabIndex == 0)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Total: Rp ${formatPrice(_selectedTotal)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedUnpaidIds.isEmpty
                              ? null
                              : () {
                                  final ids =
                                      _selectedUnpaidIds.toList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentScreen(
                                        orderIds: ids,
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            disabledBackgroundColor:
                                primaryBlue.withOpacity(0.4),
                            minimumSize:
                                const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(26),
                            ),
                          ),
                          child: const Text(
                            'Bayar sekarang',
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabButton(int index, String label) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tabIndex = index;
          if (_tabIndex != 0) _selectedUnpaidIds.clear();
        }),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            if (selected)
              Container(
                width: 24,
                height: 2.5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============== CARD: BELUM DIBAYAR ==================

class _UnpaidOrderCard extends StatelessWidget {
  final Order order;
  final bool selected;
  final ValueChanged<bool?> onSelectedChanged;

  const _UnpaidOrderCard({
    required this.order,
    required this.selected,
    required this.onSelectedChanged,
  });

  Duration get _remaining {
    final deadline =
        order.createdAt.add(const Duration(hours: 2));
    final diff = deadline.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  String get _hms {
    final d = _remaining;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(h)} : ${two(m)} : ${two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [
          // bar "Selesaikan sebelum"
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Selesaikan Sebelum',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _hms,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: onSelectedChanged,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _orderText(order),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 70,
                  child: Image.asset(
                    order.car.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderText(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.car.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tanggal Pinjam:  ${order.startDate.day} ${_monthName(order.startDate.month)} ${order.startDate.year} (07.00)',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          'Tanggal Kembali: ${order.endDate.day} ${_monthName(order.endDate.month)} ${order.endDate.year} (06.00)',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          'Total: Rp ${formatPrice(order.total)}',
          style: const TextStyle(fontSize: 11),
        ),
        const Text(
          'Status: Menunggu Pembayaran',
          style: TextStyle(fontSize: 11),
        ),
      ],
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

// =============== CARD: DISEWA ==================

class _RentedOrderCard extends StatelessWidget {
  final Order order;

  const _RentedOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _orderText(order)),
              SizedBox(
                height: 70,
                child: Image.asset(
                  order.car.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OrderDetailScreen(order: order),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                minimumSize:
                    const Size.fromHeight(40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Lihat Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderText(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.car.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tanggal Pinjam:  ${order.startDate.day} ${_monthName(order.startDate.month)} ${order.startDate.year} (07.00)',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          'Tanggal Kembali: ${order.endDate.day} ${_monthName(order.endDate.month)} ${order.endDate.year} (06.00)',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          'Total: Rp ${formatPrice(order.total)}',
          style: const TextStyle(fontSize: 11),
        ),
        const Text(
          'Status: Sedang disewa',
          style: TextStyle(fontSize: 11),
        ),
      ],
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

// =============== CARD: UNTUK DIULAS ==================

class _ReviewOrderCard extends StatelessWidget {
  final Order order;
  final void Function(int stars) onReviewed;

  const _ReviewOrderCard({
    required this.order,
    required this.onReviewed,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = order.rating != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      padding:
          const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _orderText(order)),
              SizedBox(
                height: 70,
                child: Image.asset(
                  order.car.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Text(
                  'Ulasan cepat',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 16),
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      (order.rating != null &&
                              i <= (order.rating ?? 0))
                          ? Icons.star
                          : Icons.star_border,
                      size: 22,
                      color: Colors.amber,
                    ),
                    onPressed: disabled
                        ? null
                        : () {
                            onReviewed(i);
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Terima kasih atas ulasannya!'),
                              ),
                            );
                          },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderText(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.car.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Tanggal Pinjam:  ${order.startDate.day} ${_monthName(order.startDate.month)} ${order.startDate.year} (07.00)',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          'Tanggal Kembali: ${order.endDate.day} ${_monthName(order.endDate.month)} ${order.endDate.year} (06.00)',
          style: const TextStyle(fontSize: 11),
        ),
        Text(
          'Total: Rp ${formatPrice(order.total)}',
          style: const TextStyle(fontSize: 11),
        ),
        const Text(
          'Status: Selesai',
          style: TextStyle(fontSize: 11),
        ),
      ],
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
