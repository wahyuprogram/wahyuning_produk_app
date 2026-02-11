class Produk {
  int? id;
  String? kodeProduk;
  String? namaProduk;
  int? hargaProduk;
  String? foto; // Pastikan ini ada!

  Produk({this.id, this.kodeProduk, this.namaProduk, this.hargaProduk, this.foto});

  factory Produk.fromJson(Map<String, dynamic> obj) {
    return Produk(
      id: (obj['id'] is int) ? obj['id'] : int.tryParse(obj['id'].toString()) ?? 0,
      kodeProduk: obj['kode'],
      namaProduk: obj['nama'],
      hargaProduk: (obj['harga'] is int)
          ? obj['harga']
          : double.parse(obj['harga'].toString()).toInt(),
      foto: obj['foto'], // Mapping kolom foto dari database
    );
  }
}