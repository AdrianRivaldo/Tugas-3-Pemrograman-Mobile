class TiketHabisException implements Exception {
  final String message;
  final String namaTiket;

  TiketHabisException(this.namaTiket, [this.message = '']);

  @override
  String toString() {
    return 'TiketHabisException: Tiket "$namaTiket" sudah habis! '
        '${message.isNotEmpty ? message : 'Silakan pilih tiket lain.'}';
  }
}

class PembayaranGagalException implements Exception {
  final String message;
  PembayaranGagalException([this.message = 'Pembayaran gagal diproses.']);

  @override
  String toString() => 'PembayaranGagalException: $message';
}
