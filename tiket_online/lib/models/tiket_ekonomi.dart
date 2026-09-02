import 'tiket.dart';
import '../helpers/currency_helper.dart';

class TiketEkonomi extends Tiket {
  final String fasilitas;

  TiketEkonomi({
    required super.nama,
    required super.harga,
    required super.rute,
    required super.waktuKeberangkatan,
    required super.waktuKedatangan,
    required super.durasiMenit,
    required super.kursiTersisa,
    this.fasilitas = 'Tempat duduk standar, kabin ber-AC',
  });

  @override
  String deskripsi() {
    return 'Kelas Ekonomi - $nama\n'
        'Rute: $rute\n'
        'Keberangkatan: $waktuKeberangkatan\n'
        'Kedatangan: $waktuKedatangan\n'
        'Durasi: $durasiMenit menit\n'
        'Fasilitas: $fasilitas\n'
        'Kursi tersisa: $kursiTersisa\n'
        'Harga: ${CurrencyHelper.format(harga)}';
  }

  // ✅ Method copyWith untuk membuat instance baru dengan kursi yang diperbarui
  TiketEkonomi copyWith({int? kursiTersisaBaru}) {
    return TiketEkonomi(
      nama: nama,
      harga: harga,
      rute: rute,
      waktuKeberangkatan: waktuKeberangkatan,
      waktuKedatangan: waktuKedatangan,
      durasiMenit: durasiMenit,
      kursiTersisa: kursiTersisaBaru ?? this.kursiTersisa,
      fasilitas: fasilitas,
    );
  }
}
