import 'dart:convert';
import 'dart:io'; 
import 'package:apktyas/model/produk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProdukForm extends StatefulWidget {
  final Produk? produk;
  const ProdukForm({Key? key, this.produk}) : super(key: key);

  @override
  _ProdukFormState createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  
  XFile? _imageFile; 
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  
  final String baseUrl = 'http://localhost/produk'; 

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _kodeController.text = widget.produk!.kodeProduk ?? '';
      _namaController.text = widget.produk!.namaProduk ?? '';
      _hargaController.text = widget.produk!.hargaProduk.toString();
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _imageFile = pickedFile; });
    }
  }

  Future<void> simpanData() async {
    setState(() { _isLoading = true; });
    
    String url = widget.produk != null ? '$baseUrl/update.php' : '$baseUrl/create.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      if (widget.produk != null) {
        request.fields['id'] = widget.produk!.id.toString();
      }
      
      request.fields['kode'] = _kodeController.text;
      request.fields['nama'] = _namaController.text;
      request.fields['harga'] = _hargaController.text;

      if (_imageFile != null) {
        if (kIsWeb) {
            request.files.add(http.MultipartFile.fromBytes(
                'foto', 
                await _imageFile!.readAsBytes(),
                filename: _imageFile!.name
            ));
        } else {
            request.files.add(await http.MultipartFile.fromPath('foto', _imageFile!.path));
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);
        
        if (data['success'] == true) {
          // CEK APAKAH INI EDIT ATAU TAMBAH UNTUK SINYAL NOTIFIKASI
          Navigator.pop(context, widget.produk != null ? 'edit' : 'add');
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${data['error']}")));
        }
      } else {
        throw Exception("Gagal koneksi ke server");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.produk != null ? "Edit Produk" : "Tambah Produk", style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _kodeController, 
              decoration: InputDecoration(
                labelText: "Kode",
                prefixIcon: const Icon(Icons.qr_code_scanner, color: Colors.teal),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal)),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _namaController, 
              decoration: InputDecoration(
                labelText: "Nama",
                prefixIcon: const Icon(Icons.inventory_2_outlined, color: Colors.teal),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal)),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _hargaController, 
              decoration: InputDecoration(
                labelText: "Harga",
                prefixIcon: const Icon(Icons.attach_money, color: Colors.teal),
                prefixText: "Rp ",
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.teal)),
              ), 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 24),
            
            Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.teal.shade200, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _imageFile != null
                  ? (kIsWeb 
                      ? Image.network(_imageFile!.path, width: 150, height: 150, fit: BoxFit.cover) 
                      : Image.file(File(_imageFile!.path), width: 150, height: 150, fit: BoxFit.cover))
                  : (widget.produk?.foto != null && widget.produk!.foto != ""
                      ? Image.network(
                          "$baseUrl/uploads/${widget.produk!.foto}", width: 150, height: 150, fit: BoxFit.cover,
                          errorBuilder: (ctx,err,stack) => const Center(child: Text("Gagal memuat", textAlign: TextAlign.center))
                        ) 
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Belum ada gambar", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        )),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickImage, icon: const Icon(Icons.photo_library), label: const Text("Pilih Gambar"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal, side: BorderSide(color: Colors.teal.shade300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.teal)
              : ElevatedButton.icon(
                  onPressed: simpanData, icon: const Icon(Icons.save_outlined, color: Colors.white),
                  label: const Text("SIMPAN", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ), 
                )
          ],
        ),
      ),
    );
  }
}