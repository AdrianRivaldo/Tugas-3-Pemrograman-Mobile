import 'tiket.dart';
import 'bisa_diskon.dart';
import '../helpers/currency_helper.dart';

class TiketVIP extends Tiket with BisaDiskon {
  final List<String> fasilitasVIP;

  TiketVIP({
    required super.nama,
    required super.harga,
    required super.rute,
    required super.waktuKeberangkatan,
    required super.waktuKedatangan,
    required super.durasiMenit,
    required super.kursiTersisa,
    this.fasilitasVIP = const [
      'Kursi dapat direbahkan',
      'Makanan ringan gratis',
      'Akses dek luar ruangan',
    ],
  });

  // ✅ Implementasi getter yang wajib dari mixin BisaDiskon
  @override
  double get hargaDasar => harga;

  @override
  String deskripsi() {
    final hargaDiskon = hitungHargaDiskon(20);
    return 'Kelas VIP - $nama\n'
        'Rute: $rute\n'
        'Keberangkatan: $waktuKeberangkatan\n'
        'Kedatangan: $waktuKedatangan\n'
        'Durasi: $durasiMenit menit\n'
        'Fasilitas VIP:\n${fasilitasVIP.map((f) => '  • $f').join('\n')}\n'
        'Kursi tersisa: $kursiTersisa\n'
        'Harga Normal: ${CurrencyHelper.format(harga)}\n'
        'Harga Promo (20%): ${CurrencyHelper.format(hargaDiskon)}';
  }

  String get daftarFasilitas => fasilitasVIP.join(', ');
  String get formattedHargaDiskon =>
      CurrencyHelper.format(hitungHargaDiskon(20));

  // ✅ Method copyWith untuk membuat instance baru dengan kursi yang diperbarui
  TiketVIP copyWith({int? kursiTersisaBaru}) {
    return TiketVIP(
      nama: nama,
      harga: harga,
      rute: rute,
      waktuKeberangkatan: waktuKeberangkatan,
      waktuKedatangan: waktuKedatangan,
      durasiMenit: durasiMenit,
      kursiTersisa: kursiTersisaBaru ?? this.kursiTersisa,
      // Gunakan List.from() agar tidak terjadi referensi memori yang sama
      fasilitasVIP: List.from(fasilitasVIP),
    );
  }
}
