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
    
    // Tentukan URL: Update atau Create
    String url = widget.produk != null ? '$baseUrl/update.php' : '$baseUrl/create.php';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      // Kirim ID jika edit
      if (widget.produk != null) {
        request.fields['id'] = widget.produk!.id.toString();
      }
      
      request.fields['kode'] = _kodeController.text;
      request.fields['nama'] = _namaController.text;
      request.fields['harga'] = _hargaController.text;

      // Kirim Gambar (Jika ada gambar baru yang dipilih)
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
          // Sukses, kembali ke layar sebelumnya dg sinyal update
          Navigator.pop(context, 'update');
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
      appBar: AppBar(title: Text(widget.produk != null ? "Edit Produk" : "Tambah Produk")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _kodeController, decoration: const InputDecoration(labelText: "Kode")),
            TextField(controller: _namaController, decoration: const InputDecoration(labelText: "Nama")),
            TextField(controller: _hargaController, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            
            // LOGIKA PREVIEW GAMBAR
            _imageFile != null
              ? (kIsWeb 
                  ? Image.network(_imageFile!.path, height: 150, fit: BoxFit.cover) 
                  : Image.file(File(_imageFile!.path), height: 150, fit: BoxFit.cover))
              : (widget.produk?.foto != null && widget.produk!.foto != ""
                  ? Image.network("$baseUrl/uploads/${widget.produk!.foto}", height: 150, fit: BoxFit.cover,
                      errorBuilder: (ctx,err,stack) => const Text("Gagal memuat gambar lama")) 
                  : const Text("Belum ada gambar dipilih")),
            
            const SizedBox(height: 10),
            ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text("Pilih Gambar")),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: simpanData, style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)), child: const Text("SIMPAN"))
          ],
        ),
      ),
    );
  }
}