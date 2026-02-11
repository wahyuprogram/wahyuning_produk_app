import 'dart:convert';
import 'package:apktyas/model/produk.dart';
import 'package:apktyas/ui/produk_form.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProdukDetail extends StatefulWidget {
  final Produk produk;

  const ProdukDetail({Key? key, required this.produk}) : super(key: key);

  @override
  _ProdukDetailState createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  final String baseUrl = 'http://localhost/produk'; // Sesuaikan

  void confirmHapus() {
    AlertDialog alertDialog = AlertDialog(
      content: Text("Yakin ingin menghapus data '${widget.produk.namaProduk}'?"),
      actions: [
        OutlinedButton(
          child: const Text("Batal"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Hapus"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
             Navigator.pop(context);
             await hapusData();
          },
        ),
      ],
    );
    showDialog(context: context, builder: (context) => alertDialog);
  }

  Future<void> hapusData() async {
    String url = '$baseUrl/delete.php?id=${widget.produk.id}';
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['success'] != null) {
           Navigator.pop(context, 'update'); // Kembali ke list dengan sinyal update
        } else {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus")));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // TAMPILKAN GAMBAR BESAR
            (widget.produk.foto != null && widget.produk.foto != "")
              ? Image.network(
                  "$baseUrl/uploads/${widget.produk.foto}",
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 100),
                )
              : const Icon(Icons.image_not_supported, size: 100),
            
            const SizedBox(height: 20),
            Text("Kode : ${widget.produk.kodeProduk}", style: const TextStyle(fontSize: 20)),
            Text("Nama : ${widget.produk.namaProduk}", style: const TextStyle(fontSize: 18)),
            Text("Harga : Rp ${widget.produk.hargaProduk}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                      // Masuk ke halaman Edit
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProdukForm(produk: widget.produk),
                        )
                      );
                      // Jika sukses edit, kembali ke list agar refresh
                      if (result == 'update') {
                        Navigator.pop(context, 'update');
                      }
                  }, 
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Edit", style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: confirmHapus,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Hapus", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}