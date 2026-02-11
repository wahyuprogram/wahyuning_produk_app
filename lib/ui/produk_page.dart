import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:apktyas/model/produk.dart';
import 'package:apktyas/ui/produk_form.dart';
import 'package:apktyas/ui/produk_detail.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  // Gunakan localhost untuk Chrome
  String url = 'http://localhost/produk/list.php';

  Future<List<Produk>> getProduk() async {
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Produk.fromJson(data)).toList();
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Navigasi ke Form Tambah
              var result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProdukForm()),
              );
              // Jika sukses tambah, refresh halaman
              if (result == 'update') {
                setState(() {});
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Produk>>(
        future: getProduk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data produk"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              // Kita kirim fungsi refresh ke ItemProduk
              return ItemProduk(
                produk: snapshot.data![index],
                onRefresh: () {
                  setState(() {}); // Panggil ini biar list refresh
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ItemProduk extends StatelessWidget {
  final Produk produk;
  final VoidCallback onRefresh; // Callback buat refresh

  const ItemProduk({Key? key, required this.produk, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // URL Gambar
    String imageUrl = "http://localhost/produk/uploads/${produk.foto}";

    return GestureDetector(
      child: Card(
        child: ListTile(
          // TAMPILKAN GAMBAR DI SINI
          leading: (produk.foto != null && produk.foto != "")
            ? Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
              )
            : const Icon(Icons.image_not_supported),
          
          title: Text(produk.namaProduk ?? ''),
          subtitle: Text("Rp ${produk.hargaProduk}"),
          trailing: Text(produk.kodeProduk ?? ''),
        ),
      ),
      onTap: () async {
        // Masuk ke Detail
        var result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProdukDetail(produk: produk),
          ),
        );
        
        // Cek apakah perlu refresh (karena habis edit/hapus)
        if (result == 'update') {
          onRefresh();
        }
      },
    );
  }
}