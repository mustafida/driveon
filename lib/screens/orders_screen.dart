// lib/screens/orders_screen.dart

import 'package:flutter/material.dart';

import '../data/orders_store.dart';
import '../models/order.dart';
import '../utils/format_price.dart';

import 'payment_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  final OrdersStore _store = OrdersStore.instance;

  /// id pesanan UNPAID yang dicentang (untuk bayar banyak sekaligus)
  final Set<String> _selectedUnpaidIds = {};

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return DefaultTabController(
      length: 3, // Belum Dibayar, Sedang Disewa, Untuk Diulas
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: primaryBlue,
            indicatorWeight: 3,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Belum Dibayar'),
              Tab(text: 'Sedang Disewa'),
              Tab(text: 'Untuk Diulas'),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF4F4F4),
        body: TabBarView(
          children: [
            _buildUnpaidTab(primaryBlue),
            _buildRentedTab(primaryBlue),
            _buildToReviewTab(primaryBlue),
          ],
        ),
      ),
    );
  }

  // =============== TAB 1: BELUM DIBAYAR ===============

  Widget _buildUnpaidTab(Color primaryBlue) {
    final List<Order> unpaid = _store.orders
        .where((o) =>
            o.status == OrderStatus.unpaid && !o.isPaymentExpired // masih valid
        )
        .toList();

    if (unpaid.isEmpty) {
      return const _EmptyState(
        title: 'Tidak ada pesanan menunggu pembayaran',
        subtitle: 'Pesanan yang belum kamu bayar akan muncul di sini.',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: unpaid.length,
            itemBuilder: (_, i) {
              final order = unpaid[i];
              final selected = _selectedUnpaidIds.contains(order.id);

              return _OrderCard(
                order: order,
                primaryBlue: primaryBlue,
                statusText: 'Belum Dibayar',
                statusColor: Colors.orange,
                actionText: 'Lanjut Pembayaran',
                onCardTap: () {
                  // buka detail
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(order: order),
                    ),
                  );
                },
                onActionTap: () {
                  // bayar satu pesanan ini
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        orderIds: [order.id],
                        showMainOrderCard: false,
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      // refresh list + kosongkan pilihan
                      _selectedUnpaidIds.clear();
                    });
                  });
                },

                // ====== bagian multi-select ======
                selectable: true,
                selected: selected,
                onSelectedChanged: (value) {
                  setState(() {
                    if (value) {
                      _selectedUnpaidIds.add(order.id);
                    } else {
                      _selectedUnpaidIds.remove(order.id);
                    }
                  });
                },
              );
            },
          ),
        ),

        // tombol bawah untuk bayar banyak sekaligus
        if (_selectedUnpaidIds.isNotEmpty)
          Container(
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _paySelectedUnpaid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'Bayar ${_selectedUnpaidIds.length} Pesanan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _paySelectedUnpaid() {
    final ids = _selectedUnpaidIds.toList();
    if (ids.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          orderIds: ids,
          showMainOrderCard: false, // datang dari tab Pesanan
        ),
      ),
    ).then((_) {
      setState(() {
        _selectedUnpaidIds.clear();
      });
    });
  }

  // =============== TAB 2: SEDANG DISEWA ===============

  Widget _buildRentedTab(Color primaryBlue) {
    final List<Order> rented =
        _store.orders.where((o) => o.status == OrderStatus.rented).toList();

    if (rented.isEmpty) {
      return const _EmptyState(
        title: 'Belum ada mobil yang sedang disewa',
        subtitle:
            'Saat kamu menyelesaikan pembayaran, pesanan akan pindah ke sini.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: rented.length,
      itemBuilder: (_, i) {
        final order = rented[i];
        return _OrderCard(
          order: order,
          primaryBlue: primaryBlue,
          statusText: 'Sedang Disewa',
          statusColor: Colors.green,
          actionText: 'Detail Pesanan',
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
          onActionTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
        );
      },
    );
  }

  // =============== TAB 3: UNTUK DIULAS ===============

  Widget _buildToReviewTab(Color primaryBlue) {
    // order selesai tapi belum ada rating
    final List<Order> toReview = _store.orders
        .where((o) =>
            o.status == OrderStatus.finished && o.rating == null) // belum rating
        .toList();

    if (toReview.isEmpty) {
      return const _EmptyState(
        title: 'Tidak ada pesanan untuk diulas',
        subtitle:
            'Setelah masa sewa selesai, kamu bisa memberi rating di sini.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: toReview.length,
      itemBuilder: (_, i) {
        final order = toReview[i];
        return _OrderCard(
          order: order,
          primaryBlue: primaryBlue,
          statusText: 'Selesai',
          statusColor: Colors.blueGrey,
          actionText: 'Beri Rating',
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
          onActionTap: () async {
            final rating = await _showRatingDialog(order);
            if (rating != null) {
              _store.setRating(order.id, rating);
              setState(() {});
            }
          },
        );
      },
    );
  }

  // =============== POPUP RATING ===============

  Future<int?> _showRatingDialog(Order order) async {
    int tempRating = 5;

    return showDialog<int>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Beri Rating'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                order.car.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final selected = starIndex <= tempRating;
                      return IconButton(
                        onPressed: () {
                          setStateDialog(() {
                            tempRating = starIndex;
                          });
                        },
                        icon: Icon(
                          selected ? Icons.star_rounded : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop<int>(context, tempRating),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

// =============== WIDGET CARD PESANAN ===============

class _OrderCard extends StatelessWidget {
  final Order order;
  final Color primaryBlue;
  final String statusText;
  final Color statusColor;
  final String actionText;
  final VoidCallback onCardTap;
  final VoidCallback onActionTap;

  /// untuk tab "Belum Dibayar" → ada checkbox
  final bool selectable;
  final bool selected;
  final ValueChanged<bool>? onSelectedChanged;

  const _OrderCard({
    required this.order,
    required this.primaryBlue,
    required this.statusText,
    required this.statusColor,
    required this.actionText,
    required this.onCardTap,
    required this.onActionTap,
    this.selectable = false,
    this.selected = false,
    this.onSelectedChanged,
  });

  String _dateText(DateTime d) {
    const months = [
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              if (selectable)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Checkbox(
                    value: selected,
                    onChanged: (v) =>
                        onSelectedChanged?.call(v ?? false),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  ),
                ),

              // gambar mobil
              SizedBox(
                width: 90,
                height: 70,
                child: Image.asset(
                  order.car.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),

              // detail text
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
                      '${_dateText(order.startDate)} - ${_dateText(order.endDate)}',
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Total: Rp. ${formatPrice(order.total)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: onActionTap,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            actionText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============== EMPTY STATE ===============

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 54,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
