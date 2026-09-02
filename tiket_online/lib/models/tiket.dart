import '../helpers/currency_helper.dart';

// ============================================================
// ABSTRACT CLASS: Tiket
// ============================================================
abstract class Tiket {
  final String nama;
  final double harga;
  final String rute;
  final String waktuKeberangkatan;
  final String waktuKedatangan;
  final int durasiMenit;
  final int kursiTersisa;

  Tiket({
    required this.nama,
    required this.harga,
    required this.rute,
    required this.waktuKeberangkatan,
    required this.waktuKedatangan,
    required this.durasiMenit,
    required this.kursiTersisa,
  });

  // Abstract method — wajib diimplementasikan subclass
  String deskripsi();

  String get formattedHarga => CurrencyHelper.format(harga);

  @override
  String toString() {
    return '$nama | ${CurrencyHelper.format(harga)} | $rute';
  }
}
