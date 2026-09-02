import 'package:flutter/material.dart';

import '../models/tiket.dart';
import '../models/tiket_vip.dart';
import '../models/tiket_ekonomi.dart';
import '../helpers/currency_helper.dart';

class TicketCard extends StatelessWidget {
  final Tiket tiket;
  final VoidCallback onPesan;

  const TicketCard({super.key, required this.tiket, required this.onPesan});

  bool get _isVIP => tiket is TiketVIP;

  // ✅ Helper untuk mendapatkan teks fasilitas dengan aman
  String _getFasilitasText() {
    if (tiket is TiketEkonomi) {
      return (tiket as TiketEkonomi).fasilitas;
    } else if (tiket is TiketVIP) {
      return (tiket as TiketVIP).daftarFasilitas;
    }
    return 'Fasilitas standar';
  }

  @override
  Widget build(BuildContext context) {
    final double hargaTampil = _isVIP
        ? (tiket as TiketVIP).hitungHargaDiskon(20)
        : tiket.harga;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(
                  _isVIP ? Icons.stars : Icons.directions_boat_outlined,
                  color: _isVIP
                      ? const Color(0xFF0d7377)
                      : const Color(0xFF1a3a6b),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  _isVIP ? 'KELAS VIP' : 'KELAS EKONOMI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _isVIP
                        ? const Color(0xFF0d7377)
                        : const Color(0xFF1a3a6b),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tiket.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0a1628),
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ Tampilkan fasilitas dengan aman
                Text(
                  _getFasilitasText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFF1a3a6b),
                ),
                const SizedBox(width: 6),
                Text(
                  tiket.waktuKeberangkatan,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 20),
                Icon(
                  Icons.event_seat,
                  size: 18,
                  color: tiket.kursiTersisa <= 5
                      ? Colors.red
                      : const Color(0xFF0d7377),
                ),
                const SizedBox(width: 6),
                Text(
                  tiket.kursiTersisa <= 5
                      ? 'Hanya sisa ${tiket.kursiTersisa}!'
                      : '${tiket.kursiTersisa} kursi tersisa',
                  style: TextStyle(
                    fontSize: 14,
                    color: tiket.kursiTersisa <= 5
                        ? Colors.red
                        : const Color(0xFF0d7377),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Divider(),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mulai dari',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (_isVIP)
                  Text(
                    CurrencyHelper.format(tiket.harga),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      CurrencyHelper.format(hargaTampil),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0a1628),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: tiket.kursiTersisa > 0 ? onPesan : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tiket.kursiTersisa > 0
                            ? const Color(0xFF1a5276)
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        tiket.kursiTersisa > 0 ? 'Pesan Sekarang' : 'Habis',
                        style: const TextStyle(
                          fontSize: 16,
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
    );
  }
}
