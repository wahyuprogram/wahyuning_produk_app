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
           // MENGIRIM SINYAL DELETE
           Navigator.pop(context, 'delete'); 
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
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: const Text('Detail Produk'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1, 
      ),
      body: Center( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card( 
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: (widget.produk.foto != null && widget.produk.foto != "")
                      ? Image.network(
                          "$baseUrl/uploads/${widget.produk.foto}", height: 200, fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                        )
                      : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text("Kode : ${widget.produk.kodeProduk}", style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text("${widget.produk.namaProduk}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text("Rp ${widget.produk.hargaProduk}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.teal)),
                  
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                            var result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProdukForm(produk: widget.produk))
                            );
                            // MENERUSKAN SINYAL EDIT KE HALAMAN UTAMA
                            if (result == 'edit' || result == 'update') {
                              Navigator.pop(context, 'edit');
                            }
                        }, 
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                        label: const Text("Edit", style: TextStyle(color: Colors.white)),
                      ),
                      
                      ElevatedButton.icon(
                        onPressed: confirmHapus,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                        label: const Text("Hapus", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}