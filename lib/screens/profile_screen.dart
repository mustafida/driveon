// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../data/user_store.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = UserStore.instance;

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user.isLoggedIn;
    const primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil',
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
          const SizedBox(height: 12),

          // HEADER
          if (isLoggedIn)
            _buildLoggedInHeader()
          else
            _buildGuestHeader(primaryBlue),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // LIST MENU
          Expanded(
            child: ListView(
              children: [
                if (isLoggedIn)
                  _menuTile(
                    icon: Icons.place_outlined,
                    title: 'Wilayah',
                    trailingText: user.region,
                    onTap: _editRegion,
                  )
                else
                  _menuTile(
                    icon: Icons.place_outlined,
                    title: 'Wilayah',
                    onTap: _editRegion,
                  ),
                _menuTile(
                  icon: Icons.person_outline,
                  title: 'Tentang Kami',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  },
                ),
                if (isLoggedIn)
                  _menuTile(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Akun',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountSettingsScreen(),
                        ),
                      );
                      setState(() {}); // refresh nama & email di header
                    },
                  ),
                if (isLoggedIn)
                  _menuTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar',
                    titleColor: Colors.red,
                    onTap: _showLogoutSheet,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- HEADER ----------------

  Widget _buildLoggedInHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Color(0xFFE0E0E0),
          child: Icon(
            Icons.person,
            size: 48,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGuestHeader(Color primaryBlue) {
    return Column(
      children: [
        const SizedBox(height: 4),
        SizedBox(
          width: 140,
          child: ElevatedButton(
            onPressed: _showLoginSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Daftar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ---------------- MENU TILE ----------------

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, size: 22),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: titleColor ?? Colors.black,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(
                  trailingText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  // ---------------- ACTIONS ----------------

  void _showLoginSheet() {
    const primaryBlue = Color(0xFF0066FF);

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masuk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silahkan Masuk Untuk Menyimpan Pilihan Yang Anda Inginkan',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // login google beneran (bukan dummy lagi)
                    await user.loginWithGoogle();
                    if (mounted) {
                      Navigator.pop(context); // tutup bottom sheet
                      setState(() {}); // refresh profil
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Image.asset(
                          'assets/icons/icon_google.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lanjutkan Dengan Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editRegion() {
    final controller = TextEditingController(
      text: user.region == 'Pilih wilayah' ? '' : user.region,
    );

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Wilayah'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Provinsi / Kota',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                user.updateProfile(
                  region: controller.text.trim().isEmpty
                      ? 'Pilih wilayah'
                      : controller.text.trim(),
                );
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutSheet() {
    const primaryBlue = Color(0xFF0066FF);

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.white.withOpacity(0.98),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Oh tidak!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda yakin Ingin Keluar',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await user.logoutGoogle(); // logout Google + reset lokal
                    if (mounted) {
                      Navigator.pop(context);
                      setState(() {});
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Keluar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ================== TENTANG KAMI ==================

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tentang Kami',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SingleChildScrollView(
          child: Text(
            '''Selamat datang di DriveOn, layanan rental mobil terpercaya yang siap memenuhi kebutuhan transportasi Anda dengan mudah, cepat, dan aman.

Kami hadir untuk memberikan pengalaman sewa mobil yang praktis melalui sistem pemesanan berbasis aplikasi, sehingga Anda dapat menyewa kendaraan kapan pun dan di mana pun hanya dengan beberapa sentuhan.

Kami menyediakan berbagai pilihan mobil mulai dari kelas ekonomis hingga premium — seperti Toyota Avanza, Daihatsu Xenia, Honda Brio, Honda Mobilio, Mitsubishi Xpander, hingga Toyota Calya — semuanya dalam kondisi terawat, bersih, dan siap digunakan untuk perjalanan keluarga, liburan, bisnis, maupun kegiatan sehari-hari.

Visi:
• Menjadi layanan rental mobil berbasis digital terbaik di Indonesia yang mengutamakan kenyamanan, kepercayaan, dan kemudahan pengguna.

Misi:
• Memberikan pelayanan cepat, ramah, dan profesional.
• Menyediakan armada berkualitas yang selalu siap digunakan.
• Meningkatkan pengalaman pengguna dengan sistem aplikasi yang modern dan efisien.

Aturan Pengguna (Ringkasan):
1. Pengguna wajib memiliki identitas diri yang sah (KTP/SIM) saat melakukan penyewaan.
2. Mobil yang disewa harus dikembalikan sesuai waktu yang telah disepakati.
3. Segala kerusakan atau kehilangan yang terjadi selama masa sewa menjadi tanggung jawab penyewa.
4. Dilarang menggunakan kendaraan untuk kegiatan ilegal, balap, atau tindakan yang melanggar hukum.
5. Keterlambatan pengembalian akan dikenakan biaya tambahan sesuai ketentuan.

Dengan menggunakan aplikasi DriveOn, Anda setuju dengan ketentuan dan kebijakan yang berlaku. Terima kasih telah mempercayakan perjalanan Anda kepada kami.''',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

// ================== PENGATURAN AKUN ==================

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final user = UserStore.instance;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0066FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengaturan Akun',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Nama Depan', _firstNameController),
            const Divider(),
            _infoRow('Nama Belakang', _lastNameController),
            const Divider(),
            _infoRow('Email', _emailController),
            const Divider(),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showDeleteAccountSheet,
              child: const Text(
                'Hapus Akun?',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  user.updateProfile(
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                    email: _emailController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountSheet() {
    const primaryBlue = Color(0xFF0066FF);

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Hapus Akun?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Apakah Anda Yakin Ingin Menghapus Akun Anda?\nSetelah dihapus semua data akan dihapus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    user.deleteAccount();
                    Navigator.pop(context); // tutup sheet
                    Navigator.pop(context); // keluar dari pengaturan
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
