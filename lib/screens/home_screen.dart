// lib/screens/home_screen.dart

import 'package:flutter/material.dart';

// data & model
import '../models/car.dart';
import '../data/car_data.dart';

// screens
import 'booking_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

// order store & status (untuk cek mobil sedang disewa & riwayat)
import '../data/orders_store.dart';
import '../models/order.dart';

// format harga
import '../utils/format_price.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // ====== KATEGORI (untuk swipe) ======
  final List<String> _categories = const ['All', 'Ekonomi', 'Menengah', 'Luxury'];
  String _selectedCategory = 'All';
  int _currentCategoryIndex = 0;
  late final PageController _categoryPageController;

  // ====== DATA MOBIL ======
  final List<Car> all = allCars;

  late final List<Car> popular = allCars.where((c) {
    const pop = [
      'Toyota Avanza',
      'Mitsubishi Xpander',
      'Toyota Innova Reborn',
      'Mitsubishi Pajero Sport',
      'BMW 5 Series'
    ];
    return pop.contains(c.name);
  }).toList();

  // ====== LOADING (SKELETON) ======
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _categoryPageController = PageController(initialPage: 0);

    // simulasi loading awal biar skeleton kelihatan stabil
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryPageController.dispose();
    super.dispose();
  }

  /// Filter list mobil berdasarkan kategori + search
  List<Car> _filteredForCategory(String category) {
    List<Car> base;
    if (category == 'All') {
      base = popular;
    } else {
      base = all.where((c) => c.category == category).toList();
    }

    if (_searchQuery.isEmpty) return base;

    final q = _searchQuery.toLowerCase();
    return base.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  /// 🔍 cek apakah mobil ini sedang disewa (ada order dengan status rented)
  bool _isCarRented(Car car) {
    final orders = OrdersStore.instance.orders;
    return orders.any(
      (o) => o.car.name == car.name && o.status == OrderStatus.rented,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    final tabs = [
      _buildHome(primaryBlue),
      const OrdersScreen(),
      const _HistoryScreen(), // ✅ sekarang bukan dummy lagi
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(child: tabs[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: primaryBlue,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: ''),
        ],
      ),
    );
  }

  // ---------------- HOME TAB -------------------

  Widget _buildHome(Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Halo!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const Text(
            "Selamat Datang",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Search
          _searchBar(),

          const SizedBox(height: 16),

          // Kategori
          _categoryRow(),

          const SizedBox(height: 14),

          Text(
            _currentCategoryIndex == 0
                ? 'Sewa Terlaris'
                : 'Sewa ${_categories[_currentCategoryIndex]}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),

          // ====== LIST / PAGEVIEW + SKELETON ======
          Expanded(
            child: _isLoading
                ? _buildSkeletonList()
                : PageView.builder(
                    controller: _categoryPageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentCategoryIndex = page;
                        _selectedCategory = _categories[page];
                        // tiap pindah kategori, reset search biar nggak bikin bingung
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                    itemCount: _categories.length,
                    itemBuilder: (context, pageIndex) {
                      final categoryName = _categories[pageIndex];
                      final cars = _filteredForCategory(categoryName);

                      if (cars.isEmpty) {
                        return const Center(child: Text('Tidak ada hasil'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: cars.length,
                        itemBuilder: (_, i) =>
                            _carCard(cars[i], primaryBlue),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  // ---------------- Widgets kecil -------------------

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search_rounded),
          const SizedBox(width: 6),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Cari mobil...',
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Icon(Icons.close_rounded),
            )
        ],
      ),
    );
  }

  Widget _categoryRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_categories.length, (index) {
          final c = _categories[index];
          final selected = index == _currentCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentCategoryIndex = index;
                _selectedCategory = c;
                _searchQuery = '';
                _searchController.clear();
              });

              _categoryPageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Text(
                    c,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  if (selected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _carCard(Car car, Color primaryBlue) {
    final rented = _isCarRented(car); // ✅ cek status sewa

    return GestureDetector(
      // klik di mana saja di card -> masuk ke detail (kalau tidak sedang disewa)
      onTap: () {
        if (rented) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailScreen(car: car),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              // TEKS KIRI
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      car.type,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: rented ? Colors.red : primaryBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        rented ? 'Sedang Disewa' : 'Tersedia',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // GAMBAR + HARGA KANAN
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 150,
                    height: 100,
                    child: Image.asset(
                      car.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rp. ${formatPrice(car.pricePerDay)}/hari',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: 5,
      itemBuilder: (_, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 36,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 150,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------------------- RIWAYAT SCREEN (TERHUBUNG) --------------------

class _HistoryScreen extends StatelessWidget {
  const _HistoryScreen();

  @override
  Widget build(BuildContext context) {
    // ambil semua order yang status-nya finished (sudah dinilai/diulas)
    final finishedOrders = OrdersStore.instance.orders
        .where((o) => o.status == OrderStatus.finished)
        .toList();

    if (finishedOrders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Belum ada riwayat pesanan.\n'
            'Pesanan yang sudah selesai dan sudah kamu berikan rating '
            'akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: finishedOrders.length,
      itemBuilder: (context, index) {
        final order = finishedOrders[index];
        return _HistoryOrderCard(order: order);
      },
    );
  }
}

class _HistoryOrderCard extends StatelessWidget {
  final Order order;

  const _HistoryOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final car = order.car;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // gambar mobil
            SizedBox(
              width: 80,
              height: 60,
              child: Image.asset(
                car.imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            // teks
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pesanan selesai dan sudah diulas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- DETAIL MOBIL --------------------

class CarDetailScreen extends StatelessWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

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

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          car.name,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      height: 245,
                      child: Image.asset(
                        car.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    car.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp. ${formatPrice(car.pricePerDay)}.00',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tentang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    car.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SpecTable(car: car),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // tombol Pesan Sekarang -> lanjut ke BookingScreen
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingScreen(car: car),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Pesan Sekarang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SpecTable extends StatelessWidget {
  final Car car;

  const _SpecTable({required this.car});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );

    Widget row(String left, String right) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left, style: textStyle),
            Text(right, style: textStyle),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Divider(),
        row(car.brand, car.seatInfo),
        const Divider(),
        row(car.color, car.transmission),
        const Divider(),
        row(car.year, car.plate),
        const Divider(),
      ],
    );
  }
}
