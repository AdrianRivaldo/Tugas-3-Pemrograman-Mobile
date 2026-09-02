import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/ticket_provider.dart';
import '../models/booked_ticket.dart';
import '../helpers/currency_helper.dart';

class MyTicketsScreen extends StatelessWidget {
  final TicketProvider provider;

  const MyTicketsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tiket Saya',
          style: TextStyle(
            color: Color(0xFF0a1628),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
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
            const Text(
              'Perjalanan Mendatang',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0a1628),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tiket kapal',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // TAB: Hanya "Tiket yang dipesan" (full width)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF0a1628),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Tiket yang dipesan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FutureBuilder
            FutureBuilder<List<BookedTicket>>(
              future: provider.ambilDaftarTiketDipesan(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF1a3a6b),
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Memuat tiket Anda...',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
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
                      ],
                    ),
                  );
                }

                if (snapshot.hasData) {
                  final tickets = snapshot.data!;

                  if (tickets.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada tiket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pesan tiket pertamamu sekarang!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: tickets
                        .map((ticket) => _buildTicketCard(ticket))
                        .toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(BookedTicket ticket) {
    final parts = ticket.rute.split(' → ');
    final asal = parts.isNotEmpty ? parts[0] : 'Asal';
    final tujuan = parts.length > 1 ? parts[1] : 'Tujuan';

    final qrData =
        '''
{
  "noPesanan": "${ticket.noPesanan}",
  "namaTiket": "${ticket.namaTiket}",
  "rute": "${ticket.rute}",
  "tanggal": "${ticket.formattedTanggal}",
  "keberangkatan": "${ticket.waktuKeberangkatan}",
  "kedatangan": "${ticket.waktuKedatangan}",
  "penumpang": "${ticket.penumpang}",
  "kursi": "${ticket.kursi}",
  "totalHarga": ${ticket.totalHarga}
}
    ''';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Header: Nama Tiket & Status
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_boat,
                      color: Color(0xFF1a5276),
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.namaTiket.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1a5276),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: ticket.status == 'TERKONFIRMASI'
                        ? const Color(0xFFe8f5e9)
                        : const Color(0xFFfff3e0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: ticket.status == 'TERKONFIRMASI'
                              ? const Color(0xFF2e7d32)
                              : const Color(0xFFe65100),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ticket.status,
                        style: TextStyle(
                          color: ticket.status == 'TERKONFIRMASI'
                              ? const Color(0xFF2e7d32)
                              : const Color(0xFFe65100),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ✅ BARU: Nama Pemesan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.person, size: 18, color: Color(0xFF1a5276)),
                const SizedBox(width: 8),
                const Text(
                  'Pemesan: ',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                Expanded(
                  child: Text(
                    ticket.namaPemesan,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0a1628),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Waktu Keberangkatan & Kedatangan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keberangkatan',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      ticket.waktuKeberangkatan,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      asal,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      '45 min',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const Icon(
                      Icons.directions_boat,
                      size: 20,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 4),
                    Container(width: 40, height: 2, color: Colors.grey[300]),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Kedatangan',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      ticket.waktuKedatangan,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      tujuan,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),

          // Tanggal, Jumlah, Kursi
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _infoItem('TANGGAL', ticket.formattedTanggal),
                const SizedBox(width: 12),
                _infoItem('JUMLAH', '${ticket.jumlahTiket} Tiket'),
                const SizedBox(width: 12),
                _infoItem('KURSI', ticket.kursi),
              ],
            ),
          ),
          const Divider(height: 1),

          // No. Pesanan & QR Code
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'No. Pesanan',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      ticket.noPesanan,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${CurrencyHelper.format(ticket.totalHarga)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF0d7377),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 80,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
