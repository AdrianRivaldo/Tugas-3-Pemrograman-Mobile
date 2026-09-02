class BookedTicket {
  final String namaTiket;
  final String rute;
  final String waktuKeberangkatan;
  final String waktuKedatangan;
  final String tanggal;
  final String penumpang;
  final String kursi;
  final String noPesanan;
  final double totalHarga;
  final String status;
  final int jumlahTiket;
  final String namaPemesan; // ✅ BARU: Nama pemesan
  final DateTime waktuPemesanan;

  BookedTicket({
    required this.namaTiket,
    required this.rute,
    required this.waktuKeberangkatan,
    required this.waktuKedatangan,
    required this.tanggal,
    required this.penumpang,
    required this.kursi,
    required this.noPesanan,
    required this.totalHarga,
    required this.status,
    required this.jumlahTiket,
    required this.namaPemesan, // ✅ BARU: Required parameter
    DateTime? waktuPemesanan,
  }) : waktuPemesanan = waktuPemesanan ?? DateTime.now();

  String get formattedTanggal {
    final bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${waktuPemesanan.day.toString().padLeft(2, '0')} '
        '${bulan[waktuPemesanan.month - 1]} ${waktuPemesanan.year}';
  }
}
