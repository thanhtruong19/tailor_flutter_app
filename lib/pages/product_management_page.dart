import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:file_picker/file_picker.dart';

class ProductManagementPage extends StatefulWidget {
  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() {
    return _ProductManagementPageState();
  }
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  final List<Product> products = [];

  Future<void> showAddProductDialog(BuildContext context) async{
    final formKey = GlobalKey<FormState>(); 
    final productNameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    PlatformFile? selectedImage;
    const maxImageSizeInBytes = 5 * 1024 * 1024;

    await showDialog(
      context: context, 
      builder: (dialogContext){
        return StatefulBuilder(
          builder: (context, setDialogState){
          return AlertDialog(
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
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                            Text(
                              selectedImage?.name ?? 'Chưa chọn ảnh',
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

                                setDialogState(() {
                                  selectedImage = file;
                                });
                              }, 
                              child: Text('Chọn ảnh mặt trước')
                            ),
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
                    description: descriptionController.text.trim()
                  );

                  setState(() {
                    products.add(product);
                  });

                  Navigator.pop(context);
                }, 
                child: Text('Thêm sản phẩm'))
            ],
          );
          }
        );
      }
    );
    productNameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
      ),
      body: Center(
        child: Text(
          'Chưa có sản phẩm',
          style: TextStyle(fontSize: 20),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showAddProductDialog(context);
        },
        child: Icon(Icons.add)),
    );
  }
}