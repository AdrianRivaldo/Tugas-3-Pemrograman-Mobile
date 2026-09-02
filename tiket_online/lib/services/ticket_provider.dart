import 'package:flutter/material.dart';

import '../models/tiket.dart';
import '../models/tiket_ekonomi.dart';
import '../models/tiket_vip.dart';
import '../models/booked_ticket.dart';
import '../models/exceptions.dart';

import 'dart:math';

class TicketProvider extends ChangeNotifier {
  final List<Tiket> _tiketTersedia = [
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
      waktuKeberangkatan: '08:00',
      waktuKedatangan: '08:45',
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
      kursiTersisa: 0,
      fasilitas: 'Tempat duduk standar,kabin ber-AC, durasi 45 menit.',
    ),
    TiketVIP(
      nama: 'Ocean Jet Pro',
      harga: 450000,
      rute: 'Ternate → Sofifi',
      waktuKeberangkatan: '10:30',
      waktuKedatangan: '11:15',
      durasiMenit: 45,
      kursiTersisa: 12,
      fasilitasVIP: [
        'Kursi premium dapat direbahkan',
        'Makanan & minuman gratis',
        'Akses lounge VIP',
      ],
    ),
  ];

  final List<BookedTicket> _tiketDipesan = [];
  int _counter = 8492;
  final ValueNotifier<int> updateTrigger = ValueNotifier<int>(0);

  List<Tiket> get tiketTersedia => List.from(_tiketTersedia);
  List<BookedTicket> get tiketDipesan => List.from(_tiketDipesan);

  Future<List<Tiket>> ambilDaftarTiket() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final random = Random();
    if (random.nextDouble() < 0.05) {
      throw Exception('Gagal mengambil data tiket. Silakan coba lagi.');
    }
    return List<Tiket>.from(_tiketTersedia);
  }

  Future<List<BookedTicket>> ambilDaftarTiketDipesan() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    final random = Random();
    if (random.nextDouble() < 0.03) {
      throw Exception('Gagal memuat riwayat pesanan. Silakan coba lagi.');
    }
    return List<BookedTicket>.from(_tiketDipesan);
  }

  Future<Map<String, dynamic>> ambilDataProfil() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final random = Random();
    if (random.nextDouble() < 0.03) {
      throw Exception('Gagal memuat data profil. Silakan coba lagi.');
    }
    return {
      'nama': 'Adrian Rivaldo',
      'email': 'rivaldo@gmail.com',
      'terverifikasi': true,
    };
  }

  List<Tiket> getTiketByRute(String rute) {
    return _tiketTersedia.where((t) => t.rute == rute).toList();
  }

  Future<String> pesanTiket({
    required Tiket tiket,
    required String nama,
    required String email,
    required String telepon,
    required int jumlahTiket,
  }) async {
    if (tiket.kursiTersisa < jumlahTiket) {
      throw TiketHabisException(
        tiket.nama,
        'Maaf, kursi tersisa hanya ${tiket.kursiTersisa}. Tidak cukup untuk $jumlahTiket tiket.',
      );
    }

    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    if (random.nextDouble() < 0.05) {
      throw PembayaranGagalException('Koneksi ke payment gateway terputus.');
    }

    _kurangiKursiBanyak(tiket, jumlahTiket);

    _counter++;
    String nomorPesanan =
        'SW-$_counter${String.fromCharCode(65 + (_counter % 26))}';

    List<String> daftarKursi = [];
    for (int i = 0; i < jumlahTiket; i++) {
      String huruf = String.fromCharCode(65 + ((_counter + i) % 5));
      String angka = '${10 + ((_counter + i) % 20)}';
      daftarKursi.add('$huruf$angka');
    }
    String nomorKursi = daftarKursi.join(', ');

    double hargaSatuan = tiket.harga;
    if (tiket is TiketVIP) {
      hargaSatuan = (tiket as TiketVIP).hitungHargaDiskon(20);
    }
    double totalHarga = hargaSatuan * jumlahTiket;

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
      status: 'TERKONFIRMASI',
      jumlahTiket: jumlahTiket,
      namaPemesan: nama, // ✅ Wajib ada
    );

    _tiketDipesan.add(bookedTicket);
    updateTrigger.value++;
    notifyListeners();

    return nomorPesanan;
  }

  void _kurangiKursiBanyak(Tiket tiketYangDipesan, int jumlah) {
    for (int i = 0; i < _tiketTersedia.length; i++) {
      final tiketTersedia = _tiketTersedia[i];

      if (tiketTersedia.nama == tiketYangDipesan.nama &&
          tiketTersedia.rute == tiketYangDipesan.rute &&
          tiketTersedia.runtimeType == tiketYangDipesan.runtimeType &&
          tiketTersedia.kursiTersisa >= jumlah) {
        Tiket tiketUpdated;
        if (tiketTersedia is TiketEkonomi) {
          tiketUpdated = tiketTersedia.copyWith(
            kursiTersisaBaru: tiketTersedia.kursiTersisa - jumlah,
          );
        } else if (tiketTersedia is TiketVIP) {
          tiketUpdated = tiketTersedia.copyWith(
            kursiTersisaBaru: tiketTersedia.kursiTersisa - jumlah,
          );
        } else {
          return;
        }

        _tiketTersedia[i] = tiketUpdated;
        notifyListeners();
        return;
      }
    }
  }
}
