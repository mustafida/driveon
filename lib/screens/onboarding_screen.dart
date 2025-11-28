import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      imagePath: 'assets/images/onboard1.png',
      title: 'Hemat seperti belum pernah sebelumnya',
      description:
          'Bandingkan harga dari penyediaan berbeda dan dapatkan penawaran terbaik.',
      buttonText: 'Berikutnya',
    ),
    _OnboardData(
      imagePath: 'assets/images/onboard2.png',
      title: 'Proses menyewa mobil yang mudah',
      description: 'Pesan mobil ideal Anda dengan beberapa klik sederhana.',
      buttonText: 'Berikutnya',
    ),
    _OnboardData(
      imagePath: 'assets/images/onboard3.png',
      title: 'Menemukan Mobil Terbaik',
      description:
          'Kami mencari mobil rental terbaik yang memenuhi kebutuhan Anda.',
      buttonText: 'Mulai Memesan',
    ),
  ];

  Future<void> _goNext() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasOnboarded', true);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemBuilder: (context, index) {
            final data = _pages[index];
            return _OnboardingPage(
              data: data,
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _goNext,
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardData data;
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const _OnboardingPage({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            data.imagePath,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: size.height * 0.50,
          left: 0,
          right: 0,
          child: _PageIndicator(
            currentPage: currentPage,
            totalPages: totalPages,
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: size.height * 0.32,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      data.buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageIndicator({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 10 : 8,
          height: isActive ? 10 : 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isActive ? 1 : 0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

class _OnboardData {
  final String imagePath;
  final String title;
  final String description;
  final String buttonText;

  const _OnboardData({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.buttonText,
  });
}
