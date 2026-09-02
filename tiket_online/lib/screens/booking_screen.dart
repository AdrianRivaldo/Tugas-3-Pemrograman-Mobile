import 'package:flutter/material.dart';

import '../services/ticket_provider.dart';
import '../models/tiket.dart';
import '../models/tiket_vip.dart';
import '../helpers/currency_helper.dart';
import 'payment_screen.dart'; // ✅ Import PaymentScreen

class BookingScreen extends StatefulWidget {
  final Tiket tiket;
  final TicketProvider provider;

  const BookingScreen({super.key, required this.tiket, required this.provider});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController(text: 'contoh@email.com');
  final _teleponController = TextEditingController(text: '+62 812 3456 7890');
  int _jumlahTiket = 1;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    super.dispose();
  }

  double _getHargaPerTiket() {
    final isVIP = widget.tiket is TiketVIP;
    return isVIP
        ? (widget.tiket as TiketVIP).hitungHargaDiskon(20)
        : widget.tiket.harga;
  }

  double _getTotalHarga() {
    return _getHargaPerTiket() * _jumlahTiket;
  }

  // ✅ UBAH: Navigate ke PaymentScreen alih-alih langsung memesan
  void _lanjutKePembayaran() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          tiket: widget.tiket,
          provider: widget.provider,
          nama: _namaController.text,
          email: _emailController.text,
          telepon: _teleponController.text,
          jumlahTiket: _jumlahTiket,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isVIP = widget.tiket is TiketVIP;
    final double hargaPerTiket = _getHargaPerTiket();
    final double totalHarga = _getTotalHarga();
    final int maxTiket = widget.tiket.kursiTersisa;

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
          'Tiketin Aja',
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
            // Card Info Tiket
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFe8f4f8),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tiket.nama,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isVIP
                                ? const Color(0xFF80deea)
                                : const Color(0xFFb2dfdb),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isVIP ? 'KELAS VIP' : 'KELAS EKONOMI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isVIP
                                  ? const Color(0xFF006064)
                                  : const Color(0xFF004d40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_boat, size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Keberangkatan',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  widget.tiket.rute.split(' → ')[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 24),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tujuan',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  widget.tiket.rute.split(' → ')[1],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Harga per Tiket'),
                            Text(CurrencyHelper.format(hargaPerTiket)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Jumlah Tiket ($_jumlahTiket)',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              CurrencyHelper.format(totalHarga),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Harga',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              CurrencyHelper.format(totalHarga),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0a1628),
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

            // Card Pemilihan Jumlah Tiket
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Jumlah Tiket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0a1628),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maksimal $maxTiket tiket tersedia',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _jumlahTiket <= 1
                              ? Colors.grey[300]
                              : const Color(0xFF1a5276),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _jumlahTiket > 1
                              ? () => setState(() => _jumlahTiket--)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFe8f4f8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1a5276),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$_jumlahTiket',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1a5276),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: _jumlahTiket >= maxTiket
                              ? Colors.grey[300]
                              : const Color(0xFF1a5276),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: _jumlahTiket < maxTiket
                              ? () => setState(() => _jumlahTiket++)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Anda akan memesan $_jumlahTiket tiket dengan total ${CurrencyHelper.format(totalHarga)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Form Detail Penumpang
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Penumpang',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _namaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              !v!.contains('@') ? 'Email tidak valid' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _teleponController,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.length < 10 ? 'Nomor tidak valid' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      // ✅ UBAH: Panggil _lanjutKePembayaran alih-alih _prosesPemesanan
                      onPressed: _lanjutKePembayaran,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0a1628),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lanjut ke Pembayaran',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
