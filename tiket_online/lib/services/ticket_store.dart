import 'package:flutter/material.dart';

import '../models/tiket.dart';
import '../models/tiket_ekonomi.dart';
import '../models/tiket_vip.dart';
import '../models/booked_ticket.dart';

class TicketStore extends ChangeNotifier {
  final List<Tiket> _daftarTiket = [
    TiketEkonomi(
      nama: 'KM Cantika 76',
      harga: 150000,
      rute: 'Ternate → Jailolo',
      waktuKeberangkatan: '08:00',
      waktuKedatangan: '08:45',
      durasiMenit: 45,
      kursiTersisa: 42,
      fasilitas: 'Tempat duduk standar, kabin ber-AC, durasi 45 menit.',
    ),
    TiketVIP(
      nama: 'KM Cantika 76',
      harga: 350000,
      rute: 'Ternate → Jailolo',
      waktuKeberangkatan: '08:30',
      waktuKedatangan: '09:15',
      durasiMenit: 45,
      kursiTersisa: 5,
      fasilitasVIP: [
        'Kursi dapat direbahkan',
        'Makanan ringan gratis',
        'Akses dek luar ruangan',
      ],
    ),
    TiketEkonomi(
      nama: 'Ocean Jet Pro',
      harga: 200000,
      rute: 'Ternate → Sofifi',
      waktuKeberangkatan: '10:30',
      waktuKedatangan: '11:15',
      durasiMenit: 45,
      kursiTersisa: 28,
      fasilitas: 'Kapal cepat, kabin ber-AC, durasi 45 menit.',
    ),
    TiketVIP(
      nama: 'Blue Water Express',
      harga: 450000,
      rute: 'Ternate → Sofifi',
      waktuKeberangkatan: '14:00',
      waktuKedatangan: '16:15',
      durasiMenit: 135,
      kursiTersisa: 12,
      fasilitasVIP: [
        'Kursi premium dapat direbahkan',
        'Makanan & minuman gratis',
        'Akses lounge VIP',
        'Wi-Fi onboard',
      ],
    ),
  ];

  final List<BookedTicket> _bookedTickets = [];
  int _orderCounter = 8492;

  List<Tiket> get daftarTiket => List.unmodifiable(_daftarTiket);
  List<BookedTicket> get bookedTickets => List.unmodifiable(_bookedTickets);

  Future<List<Tiket>> ambilDaftarTiket() async {
    await Future.delayed(const Duration(seconds: 2));
    return List<Tiket>.from(_daftarTiket);
  }

  void kurangiKursiTersisa(Tiket tiket, int jumlah) {
    for (int i = 0; i < _daftarTiket.length; i++) {
      if (_daftarTiket[i].nama == tiket.nama &&
          _daftarTiket[i].rute == tiket.rute &&
          _daftarTiket[i].kursiTersisa >= jumlah) {
        _daftarTiket[i] = _buatTiketDenganKursiBaru(
          _daftarTiket[i],
          _daftarTiket[i].kursiTersisa - jumlah,
        );
        notifyListeners();
        break;
      }
    }
  }

  Tiket _buatTiketDenganKursiBaru(Tiket tiket, int kursiBaru) {
    if (tiket is TiketVIP) {
      return TiketVIP(
        nama: tiket.nama,
        harga: tiket.harga,
        rute: tiket.rute,
        waktuKeberangkatan: tiket.waktuKeberangkatan,
        waktuKedatangan: tiket.waktuKedatangan,
        durasiMenit: tiket.durasiMenit,
        kursiTersisa: kursiBaru,
        fasilitasVIP: tiket.fasilitasVIP,
      );
    } else if (tiket is TiketEkonomi) {
      return TiketEkonomi(
        nama: tiket.nama,
        harga: tiket.harga,
        rute: tiket.rute,
        waktuKeberangkatan: tiket.waktuKeberangkatan,
        waktuKedatangan: tiket.waktuKedatangan,
        durasiMenit: tiket.durasiMenit,
        kursiTersisa: kursiBaru,
        fasilitas: tiket.fasilitas,
      );
    }
    return tiket;
  }

  // ✅ PERBAIKAN: Tambah parameter namaPemesan
  BookedTicket simpanTiket({
    required Tiket tiket,
    required String namaPenumpang,
    required String email,
    required String telepon,
    required String status,
    required int jumlahTiket,
    required String namaPemesan, // ✅ BARU: Wajib ada
  }) {
    _orderCounter++;
    final nomorPesanan =
        'SW-$_orderCounter${String.fromCharCode(65 + (_orderCounter % 26))}';
    final nomorKursi = _generateNomorKursi(jumlahTiket);

    double hargaSatuan = tiket.harga;
    if (tiket is TiketVIP) {
      hargaSatuan = (tiket as TiketVIP).hitungHargaDiskon(20);
    }
    double totalHarga = hargaSatuan * jumlahTiket;

    // ✅ PERBAIKAN: Tambahkan namaPemesan
    final bookedTicket = BookedTicket(
      namaTiket: tiket.nama,
      rute: tiket.rute,
      waktuKeberangkatan: tiket.waktuKeberangkatan,
      waktuKedatangan: tiket.waktuKedatangan,
      tanggal: tiket.rute.contains('Jailolo') ? 'Okt 05, 2026' : 'Okt 06, 2026',
      penumpang: '$jumlahTiket Dewasa',
      kursi: nomorKursi,
      noPesanan: nomorPesanan,
      totalHarga: totalHarga,
      status: status,
      jumlahTiket: jumlahTiket,
      namaPemesan: namaPemesan, // ✅ BARU: Wajib ada
    );

    _bookedTickets.add(bookedTicket);
    notifyListeners();
    return bookedTicket;
  }

  String _generateNomorKursi(int jumlah) {
    List<String> kursiList = [];
    for (int i = 0; i < jumlah; i++) {
      final huruf = String.fromCharCode(65 + ((_orderCounter + i) % 5));
      final angka = 10 + ((_orderCounter + i) % 20);
      kursiList.add('$huruf$angka');
    }
    return kursiList.join(', ');
  }

  List<Tiket> getTiketByRute(String rute) {
    return _daftarTiket.where((t) => t.rute == rute).toList();
  }
}
