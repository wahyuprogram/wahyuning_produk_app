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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Katalog Produk', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 28),
              onPressed: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProdukForm()),
                );
                // NOTIFIKASI SAAT BERHASIL TAMBAH
                if (result == 'add') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil menambah produk baru!"), backgroundColor: Colors.green, duration: Duration(seconds: 2))
                  );
                  setState(() {});
                } else if (result == 'update') {
                  setState(() {});
                }
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Produk>>(
        future: getProduk(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.grey)),
                ],
              )
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("Belum ada data produk", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              )
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ItemProduk(
                produk: snapshot.data![index],
                onRefresh: () {
                  setState(() {});
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
  final VoidCallback onRefresh;

  const ItemProduk({Key? key, required this.produk, required this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageUrl = "http://localhost/produk/uploads/${produk.foto}";

    return GestureDetector(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (produk.foto != null && produk.foto != "")
                ? Image.network(
                    imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60, height: 60, color: Colors.grey.shade100,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  )
                : Container(
                    width: 60, height: 60, color: Colors.grey.shade100,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
            ),
            title: Text(
              produk.namaProduk ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                "Rp ${produk.hargaProduk}",
                style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.orange),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                produk.kodeProduk ?? '',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.teal.shade700, fontSize: 12),
              ),
            ),
          ),
        ),
      ),
      onTap: () async {
        var result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProdukDetail(produk: produk)),
        );
        
        // NOTIFIKASI SAAT BERHASIL HAPUS / EDIT
        if (result == 'delete') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil dihapus!"), backgroundColor: Colors.red, duration: Duration(seconds: 2))
          );
          onRefresh();
        } else if (result == 'edit') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Perubahan produk berhasil disimpan!"), backgroundColor: Colors.teal, duration: Duration(seconds: 2))
          );
          onRefresh();
        } else if (result == 'update') {
          onRefresh();
        }
      },
    );
  }
}