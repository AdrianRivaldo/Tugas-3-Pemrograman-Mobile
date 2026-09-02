import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/ticket_provider.dart';
import '../models/tiket.dart';
import '../models/tiket_vip.dart';
import '../models/exceptions.dart';
import '../helpers/currency_helper.dart';

class PaymentScreen extends StatefulWidget {
  final Tiket tiket;
  final TicketProvider provider;
  final String nama;
  final String email;
  final String telepon;
  final int jumlahTiket;

  const PaymentScreen({
    super.key,
    required this.tiket,
    required this.provider,
    required this.nama,
    required this.email,
    required this.telepon,
    required this.jumlahTiket,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  int _countdown = 300; // 5 menit countdown
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _showTimeExpired();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final menit = seconds ~/ 60;
    final detik = seconds % 60;
    return '${menit.toString().padLeft(2, '0')}:${detik.toString().padLeft(2, '0')}';
  }

  double _getHargaPerTiket() {
    final isVIP = widget.tiket is TiketVIP;
    return isVIP
        ? (widget.tiket as TiketVIP).hitungHargaDiskon(20)
        : widget.tiket.harga;
  }

  double _getTotalHarga() {
    return _getHargaPerTiket() * widget.jumlahTiket;
  }

  String _generateQrData() {
    final total = _getTotalHarga();
    return 'TIKETIN-AJA|${widget.tiket.nama}|${widget.tiket.rute}|'
        '${widget.jumlahTiket}tiket|Rp${total.toInt()}|${widget.nama}';
  }

  Future<void> _konfirmasiPembayaran() async {
    setState(() => _isProcessing = true);

    try {
      final nomorPesanan = await widget.provider.pesanTiket(
        tiket: widget.tiket,
        nama: widget.nama,
        email: widget.email,
        telepon: widget.telepon,
        jumlahTiket: widget.jumlahTiket,
      );

      if (mounted) {
        setState(() => _isProcessing = false);
        _timer.cancel();
        _showSuccessDialog(nomorPesanan);
      }
    } on TiketHabisException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorDialog('Tiket Habis', e.toString());
      }
    } on PembayaranGagalException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorDialog('Pembayaran Gagal', e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorDialog('Error', 'Terjadi kesalahan: $e');
      }
    }
  }

  void _showSuccessDialog(String nomorPesanan) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Pembayaran Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tiket Anda telah berhasil dipesan.'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Nomor Pesanan:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    nomorPesanan,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.jumlahTiket} tiket telah disimpan di "Tiket Saya"',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Tutup dialog
              Navigator.pop(context); // Kembali ke Beranda
              Navigator.pop(context); // Kembali dari PaymentScreen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1a5276),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showTimeExpired() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Waktu Habis'),
          ],
        ),
        content: const Text(
          'Waktu pembayaran telah habis. Silakan coba pesan kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHarga = _getTotalHarga();
    final qrData = _generateQrData();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1a3a6b)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pembayaran QRIS',
          style: TextStyle(
            color: Color(0xFF0a1628),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card Info Pembayaran
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header QRIS
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1a3a6b), Color(0xFF0d7377)],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'QRIS',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1a3a6b),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.qr_code,
                                color: Color(0xFF1a3a6b),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Scan QR untuk membayar',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  // QR Code
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF0a1628),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF0a1628),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Countdown Timer
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _countdown < 60
                                ? Colors.red[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _countdown < 60
                                  ? Colors.red[300]!
                                  : Colors.orange[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                size: 18,
                                color: _countdown < 60
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bayar dalam ${_formatTime(_countdown)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _countdown < 60
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Detail Pembayaran
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _paymentRow('Nama', widget.nama),
                        const SizedBox(height: 12),
                        _paymentRow(
                          'Tiket',
                          '${widget.tiket.nama} (${widget.jumlahTiket}x)',
                        ),
                        const SizedBox(height: 12),
                        _paymentRow('Rute', widget.tiket.rute),
                        const SizedBox(height: 12),
                        _paymentRow(
                          'Keberangkatan',
                          widget.tiket.waktuKeberangkatan,
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0a1628),
                              ),
                            ),
                            Text(
                              CurrencyHelper.format(totalHarga),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0d7377),
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
            const SizedBox(height: 16),

            // Card Instruksi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Instruksi Pembayaran',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1. Buka aplikasi e-wallet/banking Anda\n'
                          '2. Pilih menu Scan/QRIS\n'
                          '3. Arahkan kamera ke QR code\n'
                          '4. Konfirmasi pembayaran di aplikasi Anda\n'
                          '5. Klik tombol di bawah setelah pembayaran selesai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Konfirmasi
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _konfirmasiPembayaran,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0a1628),
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Memproses Pembayaran...',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Konfirmasi Pembayaran',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Batalkan Pembayaran',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _paymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0a1628),
          ),
        ),
      ],
    );
  }
}
