import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_detail_page.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ProductManagementPage extends StatefulWidget {
  final String token;

  const ProductManagementPage({super.key, required this.token});

  @override
  State<ProductManagementPage> createState() {
    return _ProductManagementPageState();
  }
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final List<Product> products = [];
  final productNameController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  PlatformFile? selectedImage;

  @override
  void initState() { //chạy một lần khi mở page
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/products'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Lỗi tải sản phẩm: ${response.statusCode} ${response.body}');
        return;
      }

      final data = jsonDecode(response.body);
      final items = data['products'] as List;
      if (!mounted) return;

      setState(() {
        products
          ..clear()
          ..addAll(items.map((item) => Product(
            id: item['id'] as int,
            name: item['name'] as String,
            price: double.parse(item['price']),
            description: item['description'] as String? ?? '',
            coverImageUrl: item['cover_image_url'] as String?,
          )));
        });
    }catch (error, stackTrace) {
      debugPrint('Không tải được sản phẩm: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
  

  Future<void> showAddProductDialog(BuildContext context, int? editingIndex) async{
    final formKey = GlobalKey<FormState>(); 
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    String? coverImageUrl;
    const maxImageSizeInBytes = 5 * 1024 * 1024;
    if(editingIndex == null){
      productNameController.clear();
      priceController.clear();
      descriptionController.clear();
    }
    else{
      productNameController.text = products[editingIndex].name;  
      priceController.text = products[editingIndex].price.toString();  
      descriptionController.text = products[editingIndex].description;
      coverImageUrl = products[editingIndex].coverImageUrl;
      selectedImageName = products[editingIndex].coverImageName;
    }
    await showDialog(
      context: context, 
      builder: (dialogContext){
        return StatefulBuilder( 
          builder: (context, setDialogState){
          return AlertDialog(
            // Giảm khoảng cách giữa modal và cạnh màn hình
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            title: Text(
                editingIndex == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm',
            ),
            
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: productNameController,
                        decoration: InputDecoration(
                          hintText: 'Nhập tên sản phẩm',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                          border: OutlineInputBorder()
                        ),
                        validator: (value){
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên sản phẩm';
                          }
                          if (value.length > 255){
                            return 'Tên không được quá 255 kí tự';
                          }
                          return null;
                        },  
                      ),
                      
                      SizedBox(height: 16),

                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Nhập giá sản phẩm',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                          border: OutlineInputBorder()
                        ),
                        validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập giá sản phẩm';
                        }

                        final price = double.tryParse(value.trim());

                        if (price == null || price <= 0) {
                          return 'Giá sản phẩm không hợp lệ';
                        }
                        return null;
                      },
                      ),

                      SizedBox(height: 16),

                      TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 6,
                        decoration: InputDecoration(
                          hintText: 'Mô tả sản phẩm',
                          alignLabelWithHint: true,
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: 70),
                            child: Icon(Icons.description_outlined),
                          ),
                          border: OutlineInputBorder()
                        ),
                        validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập mô tả sản phẩm';
                        }

                        return null;
                      },
                      ),

                      SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 12,
                                    left: 12,
                                    right: 12,
                                  ),
                                child: selectedImageBytes != null
                                ? Image.memory(
                                    selectedImageBytes!,
                                    width: double.infinity,
                                    fit: BoxFit.contain,
                                  )
                                : coverImageUrl != null
                                    ? Image.network(
                                        coverImageUrl!,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                      )
                                    : const Icon(
                                        Icons.image_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                ),
                            ),

                            SizedBox(height: 8),

                            Text(
                              selectedImageName ?? 'Chưa chọn ảnh',
                              textAlign: TextAlign.center
                            ),
                            
                            SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () async{
                                final file = await FilePicker.pickFile(
                                  type: FileType.custom,
                                  allowedExtensions: [
                                    'jpg',
                                    'jpeg',
                                    'png',
                                    'webp',
                                  ],
                                );

                                if (file == null) {
                                  return;
                                }
                                selectedImage = file;

                                final fileSize = file.lengthSync() ?? await file.length();

                                if (!dialogContext.mounted) {
                                  return;
                                }

                                if(fileSize !> maxImageSizeInBytes){
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    SnackBar(
                                      content: Text('Ảnh không được lớn hơn 5MB'),
                                    )
                                  );
                                  return;
                                }

                                final imageBytes = await file.readAsBytes(); //đọc byte ảnh
                                
                                setDialogState(() {
                                  selectedImageName = file.name;
                                  selectedImageBytes = imageBytes;
                                });
                              }, 
                              child: Text('Chọn ảnh mặt trước'),
                            ),
                            SizedBox(height: 8),
                          ],
                        )
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(dialogContext);
                }, 
              child: Text('Hủy'),
              ),

              ElevatedButton(
                onPressed: () async {
                  final isValid = formKey.currentState!.validate();
                  if(!isValid){
                    return;
                  }
                  if (editingIndex == null && selectedImageBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn ảnh sản phẩm')),
                    );
                    return;
                  }
                  final editingProduct = editingIndex == null
                      ? null
                      : products[editingIndex];
                  final product = Product(
                    id: editingProduct?.id,
                    name: productNameController.text.trim(), 
                    price: double.parse(priceController.text.trim()), 
                    description: descriptionController.text.trim(),
                    coverImageUrl: editingProduct?.coverImageUrl,
                    coverImageName: selectedImageName,
                    variants: editingIndex == null
                        ? null
                        : products[editingIndex].variants,
                  );

                    try {
                      http.MultipartRequest request;
                      if(editingIndex == null){
                        request = http.MultipartRequest(
                          'POST',
                          Uri.parse('http://127.0.0.1:8000/api/products'));
                      }
                      else{
                        final id = product.id;
                        if (id == null) {
                          throw StateError('Sản phẩm cần sửa chưa có ID');
                        }
                        request = http.MultipartRequest(
                          'PUT',
                          Uri.parse('http://127.0.0.1:8000/api/products/$id'));
                      }

                      request.headers['Accept'] = 'application/json';
                      request.fields['name'] = productNameController.text.trim();
                      request.fields['price'] = priceController.text.trim();
                      request.fields['description'] = descriptionController.text.trim();
                      if (selectedImageBytes != null) {
                        request.files.add(
                          http.MultipartFile.fromBytes(
                            'cover_image',
                            selectedImageBytes!,
                            filename: selectedImageName,
                          ),
                        );
                      }
                      request.headers["Authorization"] = 'Bearer ${widget.token}';

                      final streamedResponse = await request.send();
                      final response = await http.Response.fromStream(streamedResponse);
                      if (response.statusCode == (editingIndex == null ? 201 : 200)) {
                        final responseData = jsonDecode(response.body);
                        final saved = responseData['product'];
                        product.id = saved['id'] as int;
                        product.coverImageUrl = saved['cover_image_url'] as String?;
                        if (!mounted || !dialogContext.mounted) return;
                        setState(() {
                          if(editingIndex == null){
                            products.add(product);
                          }
                          else{
                              products[editingIndex] = product;
                          }
                       });
                        Navigator.pop(dialogContext);
                      } else {
                        debugPrint('Lưu sản phẩm thất bại: ${response.statusCode} ${response.body}');
                        if (!dialogContext.mounted) return;
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('Không lưu được sản phẩm')),
                        );
                      }
                    }catch(error, stackTrace){
                      debugPrint('Lỗi lưu sản phẩm: $error');
                      debugPrintStack(stackTrace: stackTrace);
                      if (!dialogContext.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Không thể kết nối tới máy chủ'),
                        ),
                      );        
                    }
                }, 
                child: Text(
                  editingIndex == null 
                  ? 'Thêm sản phẩm' 
                  : 'Sửa sản phẩm'
                  )
                )
            ],
          );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
      ),
      body: products.isEmpty
          ? Center(
              child: Text(
                'Chưa có sản phẩm',
                style: TextStyle(fontSize: 20),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent( //định nghĩa các quy tắc dành cho GridView để hiển thị
                maxCrossAxisExtent: 220, //item rộng tối đa 220
                mainAxisSpacing: 16, // khoảng cách dọc giữa các item
                crossAxisSpacing: 16, // khoảng cách ngang giữa các item
                childAspectRatio: 0.85
              ), 
              itemBuilder: (context, index) {
                  final product = products[index];

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell( //dùng khi widget không hỗ trợ nhận sự kiện lcick
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ProductDetailPage(
                                product: product,
                              );
                            },
                          ),
                        );
                      }, //cắt nội dung con theo hình dạng và góc bo của Card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, //stretch yêu cầu các widget con giãn sao cho hết chiều ngang
                      children: [
                        Expanded(child: product.coverImageUrl == null // dùng cái này để ảnh chiếm hết height còn lại
                                      ? const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                        )
                                      : Image.network(
                                          product.coverImageUrl!,
                                          fit: BoxFit.cover,
                                        )
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: (){
                                showAddProductDialog(context, index);
                              }, 
                              icon: Icon(Icons.edit_outlined)
                            ),
                            IconButton(
                              onPressed: () async{
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: const Text('Bạn xác nhận xóa sản phẩm?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogContext, false),
                                          child: const Text('Hủy'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(dialogContext, true),
                                          child: const Text('Xóa'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if(!mounted || confirmed != true) return;

                                try {
                                  final productId = product.id;
                                  final response = await http.delete(
                                    Uri.parse('http://127.0.0.1:8000/api/products/$productId'),
                                    headers: {
                                      'Accept': 'application/json',
                                      'Authorization': 'Bearer ${widget.token}',
                                      //không có content-type vì không gửi body
                                    }
                                  );
                                  final responseData = jsonDecode(response.body);
                                  if (!mounted) {
                                    return;
                                  }
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      products.removeWhere((item) => item.id == productId);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        backgroundColor: Colors.white,
                                        content: Text(
                                          'Đã xóa sản phẩm',
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ),
                                    );
                                  }
                                  else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          responseData['message'] ?? 'Không xóa được sản phẩm',
                                        ),
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  if (!mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Không thể kết nối tới máy chủ'),
                                    ),
                                  );
                                }
                              }, 
                              icon: Icon(Icons.delete_outline)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              showAddProductDialog(context, null);
            },
            child: Icon(Icons.add)
          ),
    );
  }
  @override
  void dispose() {
    productNameController.dispose(); //Giải phóng controller do bạn tạo
    priceController.dispose();
    descriptionController.dispose();
    super.dispose(); //Flutter hoàn tất việc hủy State và dọn tài nguyên nội bộ 
  }
}
