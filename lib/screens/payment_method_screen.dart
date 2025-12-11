// lib/screens/payment_method_screen.dart

import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatefulWidget {
  /// metode yang sedang terpilih (boleh null)
  final String? initialMethod;

  const PaymentMethodScreen({super.key, this.initialMethod});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  static const primaryBlue = Color(0xFF0066FF);

  final List<String> _methods = const [
    'Qris',
    'BRI',
    'BCA',
    'Mandiri',
    'BNI',
    'Bank DBS',
    'Dana',
    'GoPay',
    'OVO',
  ];

  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMethod;
  }

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
          'Metode Pembayaran',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _methods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final method = _methods[index];
                final selected = _selected == method;

                return Material(
                  color: Colors.white,
                  elevation: 1,
                  borderRadius: BorderRadius.circular(18),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    leading: _buildMethodIcon(method),
                    title: Text(
                      method,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected ? Colors.red : Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        _selected = method;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Tombol bawah (SAFEAREA + dinaikin)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null
                      ? null
                      : () {
                          // kirim balik nama metode
                          Navigator.pop(context, _selected);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    disabledBackgroundColor: Colors.grey,
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
            ),
          ),
        ],
      ),
    );
  }

  // Kalau kamu nanti punya logo bank/e-wallet, bisa diatur di sini.
  Widget _buildMethodIcon(String method) {
    // sementara pakai huruf pertama sebagai ikon bulat
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey.shade200,
      child: Text(
        method[0],
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }
}
