// lib/data/user_store.dart
//
// Penyimpanan sederhana untuk status user + login Google (tanpa Firebase Auth dulu)

import 'package:google_sign_in/google_sign_in.dart';

class UserStore {
  UserStore._();

  /// singleton, panggil: UserStore.instance
  static final UserStore instance = UserStore._();

  bool isLoggedIn = false;

  String firstName = '';
  String lastName = '';
  String email = '';
  String region = 'Pilih wilayah';

  /// GoogleSignIn versi klasik
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String get fullName {
    if (firstName.isEmpty && lastName.isEmpty) return 'Pengguna DriveOn';
    if (lastName.isEmpty) return firstName;
    return '$firstName $lastName';
  }

  /// ===================== LOGIN GOOGLE =====================
  ///
  /// Dipanggil dari ProfileScreen._showLoginSheet()
  /// Tombol "Lanjutkan Dengan Google"
  Future<void> loginWithGoogle() async {
    try {
      // Buka UI pilih akun Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // Kalau user batal / back, account bisa null
      if (account == null) {
        return;
      }

      // Berhasil login -> simpan status & data dasar
      isLoggedIn = true;

      email = account.email;

      final displayName = account.displayName?.trim() ?? '';
      if (displayName.isEmpty) {
        // kalau tidak ada nama, kasih default
        firstName = 'Pengguna';
        lastName = 'DriveOn';
      } else {
        final parts = displayName.split(' ');
        firstName = parts.first;
        lastName =
            parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
    } catch (e) {
      // Kalau gagal login, jangan bikin app crash
      isLoggedIn = false;
    }
  }

  /// ===================== EMAIL (DUMMY) =====================
  ///
  /// Supaya layar auth email kamu nggak error.
  /// Nanti kalau mau, tinggal diganti pakai Firebase Auth / backend beneran.

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    isLoggedIn = true;
    this.email = email;
    if (firstName.isEmpty && lastName.isEmpty) {
      firstName = 'Pengguna';
      lastName = 'DriveOn';
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    isLoggedIn = true;
    this.email = email;
    if (firstName != null && firstName.isNotEmpty) {
      this.firstName = firstName;
    } else if (this.firstName.isEmpty) {
      this.firstName = 'Pengguna';
    }

    if (lastName != null && lastName.isNotEmpty) {
      this.lastName = lastName;
    } else if (this.lastName.isEmpty) {
      this.lastName = 'DriveOn';
    }
  }

  /// ===================== PROFIL & LOGOUT =====================

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? region,
  }) {
    if (firstName != null) this.firstName = firstName;
    if (lastName != null) this.lastName = lastName;
    if (email != null) this.email = email;
    if (region != null) this.region = region;
  }

  /// Logout lokal + usahakan juga signOut dari Google
  Future<void> logoutGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // kalau gagal signOut di plugin, abaikan saja
    }
    logout();
  }

  void logout() {
    isLoggedIn = false;
    firstName = '';
    lastName = '';
    email = '';
    region = 'Pilih wilayah';
  }

  void deleteAccount() {
    // Untuk sekarang sama seperti logout,
    // nanti kalau sudah ada backend bisa ditambah logika hapus akun.
    logout();
  }
}
