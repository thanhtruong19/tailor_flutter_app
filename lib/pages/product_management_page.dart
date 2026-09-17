import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

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

  Future<void> showAddProductDialog(BuildContext context, int? editingIndex) async{
    final formKey = GlobalKey<FormState>(); 
    Uint8List? selectedImageBytes;
    String? selectedImageName;
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
      selectedImageBytes = products[editingIndex].coverImageBytes;
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
            title: Text('Thêm sản phẩm'),
            
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

                        final price = int.tryParse(value.trim());

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
                                child: selectedImageBytes == null
                                  ? Icon(
                                      Icons.image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.memory( //hiển thị ảnh từ dữ liệu byte , chỉ dùng trong trường hợp đọc file cục bộ
                                      selectedImageBytes!,
                                      width: double.infinity,
                                      fit: BoxFit.contain  //hiển thị sao cho ảnh toàn vẹn 
                                    ),
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
                onPressed: () {
                  final isValid = formKey.currentState!.validate();
                  if(!isValid){
                    return;
                  }
                  final product = Product(
                    name: productNameController.text.trim(), 
                    price: int.parse(priceController.text.trim()), 
                    description: descriptionController.text.trim(),
                    coverImageBytes: selectedImageBytes,
                    coverImageName: selectedImageName
                  );

                  if(editingIndex == null){
                    setState(() {
                      products.add(product);
                    });
                  }
                  else
                  {
                    setState(() {
                      products[editingIndex] = product;
                    });
                  }

                  Navigator.pop(context);
                }, 
                child: Text('Thêm sản phẩm'))
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
                    clipBehavior: Clip.antiAlias, //cắt nội dung con theo hình dạng và góc bo của Card
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch, //stretch yêu cầu các widget con giãn sao cho hết chiều ngang
                      children: [
                        Expanded(child: product.coverImageBytes == null // dùng cái này để ảnh chiếm hết height còn lại
                                      ? const Center(
                                                child: Icon(
                                                  Icons.image_outlined,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                        )
                                      : Image.memory(
                                          product.coverImageBytes!,
                                          fit: BoxFit.cover,
                                        ),
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
                              onPressed: (){
                                setState(() {
                                  products.removeAt(index);
                                });
                              }, 
                              icon: Icon(Icons.delete_outline)
                            ),
                          ],
                        ),
                      ],
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