import 'package:google_sign_in/google_sign_in.dart' as g_sign;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/orders_store.dart';

class UserStore {
  UserStore._();

  static final UserStore instance = UserStore._();

  /// Google Sign-In
  final g_sign.GoogleSignIn _googleSignIn = g_sign.GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
    ],
  );

  // ================== STATE USER ==================

  bool _isLoggedIn = false;
  String firstName = '';
  String lastName = '';
  String email = '';
  String region = 'Pilih wilayah';

  bool get isLoggedIn => _isLoggedIn;

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) {
      return 'Pengguna DriveOn';
    }
    if (lastName.isEmpty) return firstName;
    return '$firstName $lastName';
  }

  // ================== SHARED PREFERENCES ==================

  static const _keyLoggedIn = 'user_logged_in';
  static const _keyFirstName = 'user_first_name';
  static const _keyLastName = 'user_last_name';
  static const _keyEmail = 'user_email';
  static const _keyRegion = 'user_region';

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    firstName = prefs.getString(_keyFirstName) ?? '';
    lastName = prefs.getString(_keyLastName) ?? '';
    email = prefs.getString(_keyEmail) ?? '';
    region = prefs.getString(_keyRegion) ?? 'Pilih wilayah';
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, _isLoggedIn);
    await prefs.setString(_keyFirstName, firstName);
    await prefs.setString(_keyLastName, lastName);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRegion, region);
  }

  void _resetLocal() {
    _isLoggedIn = false;
    firstName = '';
    lastName = '';
    email = '';
    region = 'Pilih wilayah';
  }

  // ================== GOOGLE LOGIN ==================

  /// Dipanggil dari ProfileScreen → tombol "Lanjutkan dengan Google"
  Future<void> loginWithGoogle() async {
    try {
      // buka UI pilih akun Google
      final g_sign.GoogleSignInAccount? account =
          await _googleSignIn.signIn();

      // kalau user batal / back, account = null
      if (account == null) return;

      // Ambil nama & email
      final displayName = account.displayName ?? '';
      email = account.email;

      final parts = displayName.trim().split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
      }
      if (parts.length > 1) {
        lastName = parts.sublist(1).join(' ');
      }

      _isLoggedIn = true;
      await _saveToPrefs();
    } catch (e) {
      // boleh kamu tambahkan debugPrint(e.toString());
    }
  }

  /// Dipanggil dari ProfileScreen → "Keluar"
  Future<void> logoutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // ignore error
    }

    // Reset user lokal
    _resetLocal();
    await _saveToPrefs();

    // ========= PENTING: hapus semua pesanan =========
    OrdersStore.instance.clearAll();
  }

  /// Dipanggil dari Pengaturan Akun → "Hapus Akun?"
  Future<void> deleteAccount() async {
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // kalau gagal disconnect tidak apa2, lanjut reset lokal
    }

    _resetLocal();
    await _saveToPrefs();

    // Sekalian bersihkan semua pesanan
    OrdersStore.instance.clearAll();
  }

  // ================== UPDATE PROFIL ==================

  /// Dipakai di Profile & AccountSettings
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? region,
  }) async {
    if (firstName != null) this.firstName = firstName;
    if (lastName != null) this.lastName = lastName;
    if (email != null) this.email = email;
    if (region != null) this.region = region;

    await _saveToPrefs();
  }

  // ================== EMAIL / PASSWORD (LOCAL DUMMY) ==================
  //
  // Ini supaya kode di EmailAuthScreen tetap jalan walaupun
  // belum ada backend beneran. Kita simpan di SharedPreferences saja.

  static const _keyAuthEmail = 'auth_email';
  static const _keyAuthPassword = 'auth_password';

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan "akun" lokal
    await prefs.setString(_keyAuthEmail, email);
    await prefs.setString(_keyAuthPassword, password);

    // anggap langsung login
    this.email = email;
    this.firstName = firstName;
    this.lastName = lastName;
    _isLoggedIn = true;

    await _saveToPrefs();
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final savedEmail = prefs.getString(_keyAuthEmail);
    final savedPass = prefs.getString(_keyAuthPassword);

    if (savedEmail == email && savedPass == password) {
      // login berhasil, tapi nama mungkin kosong
      this.email = email;
      if (firstName.isEmpty && lastName.isEmpty) {
        firstName = email.split('@').first;
      }
      _isLoggedIn = true;
      await _saveToPrefs();
    } else {
      // kalau kredensial salah, untuk sekarang cukup lempar exception sederhana
      throw Exception('Email atau password salah');
    }
  }
}
