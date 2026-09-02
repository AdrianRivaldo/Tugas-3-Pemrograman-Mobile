mixin BisaDiskon {
  double hitungHargaDiskon(double persen) {
    return hargaDasar * (1 - (persen / 100));
  }

  double get hargaDasar;
}
