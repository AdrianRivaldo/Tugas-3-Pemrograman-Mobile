import 'package:flutter/material.dart';

import '../services/ticket_provider.dart';
import '../models/tiket.dart';
import '../models/tiket_vip.dart';
import '../models/tiket_ekonomi.dart';
import '../helpers/currency_helper.dart';
import '../widgets/countdown_stream.dart';
import 'booking_screen.dart';

class HomeScreen extends StatefulWidget {
  final TicketProvider provider;
  const HomeScreen({super.key, required this.provider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _ruteTerpilih = 'Ternate → Jailolo';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.provider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Row(
              children: [
                Icon(Icons.directions_boat, color: Color(0xFF1a3a6b), size: 28),
                SizedBox(width: 8),
                Text(
                  'Tiketin Aja',
                  style: TextStyle(
                    color: Color(0xFF0a1628),
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1a3a6b),
                ),
                onPressed: () {},
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ PROMO BANNER DI TENGAH
                Center(child: CountdownStream(totalDetik: 7845)),
                const SizedBox(height: 24),

                const Text(
                  'Tiket Tersedia',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0a1628),
                  ),
                ),
                const SizedBox(height: 16),

                // Route Selector
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _ruteTerpilih = 'Ternate → Jailolo'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _ruteTerpilih == 'Ternate → Jailolo'
                                ? const Color(0xFF1a5276)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _ruteTerpilih == 'Ternate → Jailolo'
                                  ? const Color(0xFF1a5276)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            'Ternate → Jailolo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _ruteTerpilih == 'Ternate → Jailolo'
                                  ? Colors.white
                                  : const Color(0xFF0a1628),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _ruteTerpilih = 'Ternate → Sofifi'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: _ruteTerpilih == 'Ternate → Sofifi'
                                ? const Color(0xFF1a5276)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _ruteTerpilih == 'Ternate → Sofifi'
                                  ? const Color(0xFF1a5276)
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            'Ternate → Sofifi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _ruteTerpilih == 'Ternate → Sofifi'
                                  ? Colors.white
                                  : const Color(0xFF0a1628),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // FutureBuilder
                FutureBuilder<List<Tiket>>(
                  future: widget.provider.ambilDaftarTiket(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF1a3a6b),
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Memuat daftar tiket...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              snapshot.error.toString(),
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1a3a6b),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasData) {
                      final semuaTiket = snapshot.data!;
                      final daftarTiket = semuaTiket
                          .where((tiket) => tiket.rute == _ruteTerpilih)
                          .toList();

                      if (daftarTiket.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.directions_boat_outlined,
                                  size: 64,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada tiket untuk rute $_ruteTerpilih',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: daftarTiket.map((tiket) {
                          final isVIP = tiket is TiketVIP;
                          final double hargaTampil = isVIP
                              ? (tiket as TiketVIP).hitungHargaDiskon(20)
                              : tiket.harga;
                          final bool isHabis = tiket.kursiTersisa <= 0;

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
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    12,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isVIP
                                            ? Icons.stars
                                            : Icons.directions_boat_outlined,
                                        color: isVIP
                                            ? const Color(0xFF0d7377)
                                            : const Color(0xFF1a3a6b),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isVIP ? 'KELAS VIP' : 'KELAS EKONOMI',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isVIP
                                              ? const Color(0xFF0d7377)
                                              : const Color(0xFF1a3a6b),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text(
                                        isVIP
                                            ? (tiket as TiketVIP)
                                                  .daftarFasilitas
                                            : (tiket as TiketEkonomi).fasilitas,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
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
                                        color: isHabis
                                            ? Colors.grey
                                            : (tiket.kursiTersisa <= 5
                                                  ? Colors.red
                                                  : const Color(0xFF0d7377)),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isHabis
                                            ? 'Tiket Habis'
                                            : (tiket.kursiTersisa <= 5
                                                  ? 'Hanya sisa ${tiket.kursiTersisa}!'
                                                  : '${tiket.kursiTersisa} kursi tersisa'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isHabis
                                              ? Colors.grey
                                              : (tiket.kursiTersisa <= 5
                                                    ? Colors.red
                                                    : const Color(0xFF0d7377)),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  child: Divider(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    20,
                                    20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mulai dari',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                          if (isVIP)
                                            Text(
                                              CurrencyHelper.format(
                                                tiket.harga,
                                              ),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[400],
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          Text(
                                            CurrencyHelper.format(hargaTampil),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0a1628),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (isHabis) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.error_outline,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Maaf, tiket ini sudah habis!',
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: Colors.red,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                            );
                                            return;
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BookingScreen(
                                                tiket: tiket,
                                                provider: widget.provider,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isHabis
                                              ? Colors.grey
                                              : const Color(0xFF1a5276),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          isHabis ? 'Habis' : 'Pesan Sekarang',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
