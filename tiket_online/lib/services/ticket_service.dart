import 'package:flutter/material.dart';

import '../models/tiket.dart';
import '../models/tiket_ekonomi.dart';
import '../models/tiket_vip.dart';
import '../models/booked_ticket.dart';
import '../models/exceptions.dart';

import 'dart:math';

class TicketService extends ChangeNotifier {
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
      fasilitas: 'Tempat duduk standar, kabin ber-AC, durasi 45 menit.',
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

  List<Tiket> get tiketTersedia => List.from(_tiketTersedia);
  List<BookedTicket> get tiketDipesan => List.from(_tiketDipesan);

  Future<List<Tiket>> ambilDaftarTiket() async {
    await Future.delayed(const Duration(seconds: 2));
    return List<Tiket>.from(_tiketTersedia);
  }

  List<Tiket> getTiketByRute(String rute) {
    return _tiketTersedia.where((t) => t.rute == rute).toList();
  }

  // ✅ PERBAIKAN: Tambah parameter namaPemesan dan jumlahTiket
  Future<Map<String, dynamic>> pesanTiket({
    required Tiket tiket,
    required String nama,
    required String email,
    required String telepon,
    required int jumlahTiket,
  }) async {
    try {
      if (tiket.kursiTersisa < jumlahTiket) {
        return {'success': false, 'message': 'Maaf, tiket tidak cukup'};
      }

      await Future.delayed(const Duration(seconds: 2));

      final random = Random();
      if (random.nextDouble() < 0.05) {
        return {
          'success': false,
          'message': 'Koneksi ke payment gateway terputus.',
        };
      }

      _kurangiKursi(tiket, jumlahTiket);

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

      // ✅ PERBAIKAN: Tambahkan namaPemesan dan jumlahTiket
      final bookedTicket = BookedTicket(
        namaTiket: tiket.nama,
        rute: tiket.rute,
        waktuKeberangkatan: tiket.waktuKeberangkatan,
        waktuKedatangan: tiket.waktuKedatangan,
        tanggal: tiket.rute.contains('Jailolo')
            ? 'Okt 05, 2026'
            : 'Okt 06, 2026',
        penumpang: '$jumlahTiket Dewasa',
        kursi: nomorKursi,
        noPesanan: nomorPesanan,
        totalHarga: totalHarga,
        status: 'TERKONFIRMASI',
        jumlahTiket: jumlahTiket, // ✅ BARU
        namaPemesan: nama, // ✅ BARU: Wajib ada
      );

      _tiketDipesan.add(bookedTicket);
      notifyListeners();

      return {
        'success': true,
        'nomorPesanan': nomorPesanan,
        'message': 'Pemesanan berhasil!',
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ✅ PERBAIKAN: Tambah parameter jumlah
  void _kurangiKursi(Tiket tiket, int jumlah) {
    for (int i = 0; i < _tiketTersedia.length; i++) {
      final currentTiket = _tiketTersedia[i];

      final tipeCocok =
          (currentTiket is TiketEkonomi && tiket is TiketEkonomi) ||
          (currentTiket is TiketVIP && tiket is TiketVIP);

      if (tipeCocok &&
          currentTiket.nama == tiket.nama &&
          currentTiket.rute == tiket.rute &&
          currentTiket.kursiTersisa >= jumlah) {
        Tiket updatedTiket;

        if (currentTiket is TiketEkonomi) {
          updatedTiket = currentTiket.copyWith(
            kursiTersisaBaru: currentTiket.kursiTersisa - jumlah,
          );
        } else if (currentTiket is TiketVIP) {
          updatedTiket = currentTiket.copyWith(
            kursiTersisaBaru: currentTiket.kursiTersisa - jumlah,
          );
        } else {
          return;
        }

        _tiketTersedia[i] = updatedTiket;
        notifyListeners();
        return;
      }
    }
  }
}
