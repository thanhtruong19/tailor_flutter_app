import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/product_variant.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  static const sizes = ['M', 'L', 'XL', '2XL'];

  List<ProductVariant> get variants => widget.product.variants;

  Future<void> _showVariantDialog({int? editingIndex}) async {
    final formKey = GlobalKey<FormState>();
    final editingVariant =
        editingIndex == null ? null : variants[editingIndex];

    final colorController = TextEditingController(
      text: editingVariant?.color ?? '',
    );
    var selectedSize = editingVariant?.size;
    final stockQuantityController = TextEditingController(
      text: editingVariant?.stockQuantity.toString() ?? '',
    );
    String? duplicateError;

    final result = await showDialog<ProductVariant>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                editingIndex == null ? 'Thêm biến thể' : 'Sửa biến thể',
              ),
              content: SizedBox(
                width: 400,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          initialValue: widget.product.name, // dùng để hiển thị giá trị ban đầu
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Tên sản phẩm',
                            prefixIcon: Icon(Icons.inventory_2_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: colorController,
                          decoration: const InputDecoration(
                            labelText: 'Màu sắc',
                            prefixIcon: Icon(Icons.palette_outlined),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (duplicateError != null) {
                              setDialogState(() => duplicateError = null);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập màu sắc';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSize,
                          decoration: const InputDecoration(
                            labelText: 'Kích thước',
                            prefixIcon: Icon(Icons.straighten_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: sizes.map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Text(size),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedSize = value;
                              duplicateError = null;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Vui lòng chọn kích thước';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: stockQuantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Số lượng trong kho',
                            prefixIcon: Icon(Icons.numbers_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập số lượng';
                            }
                            final quantity = int.tryParse(value.trim());
                            if (quantity == null || quantity < 0) {
                              return 'Số lượng phải là số nguyên không âm';
                            }
                            return null;
                          },
                        ),
                        if (duplicateError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            duplicateError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    final color = colorController.text.trim();
                    final stockQuantity = stockQuantityController.text.trim();
                    final normalizedColor = color.toLowerCase();
                    final duplicateIndex = variants.indexWhere(
                      (variant) =>
                          variant.color.trim().toLowerCase() ==
                              normalizedColor &&
                          variant.size == selectedSize,
                    );
                    final isDuplicate =
                        duplicateIndex != -1 && duplicateIndex != editingIndex;

                    if (isDuplicate) {
                      setDialogState(() {
                        duplicateError =
                            'Biến thể màu $color, size $selectedSize đã tồn tại';
                      });
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      ProductVariant(
                        id: editingVariant?.id,
                        color: color,
                        size: selectedSize!,
                        stockQuantity: int.parse(stockQuantity),
                      ),
                    );
                  },
                  child: Text(editingIndex == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    colorController.dispose();
    stockQuantityController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      if (editingIndex == null) {
        variants.add(result);
      } else {
        variants[editingIndex] = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: SizedBox(
                      width: 450,
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildProductImage(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tên sản phẩm',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.name,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Giá sản phẩm',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.price.toString(),
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Mô tả sản phẩm',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Biến thể sản phẩm',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        tooltip: 'Thêm biến thể',
                        onPressed: () => _showVariantDialog(),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (variants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Sản phẩm chưa có biến thể')),
                    )
                  else
                    ...variants.asMap().entries.map((entry) {
                      final index = entry.key;
                      final variant = entry.value;

                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.style_outlined),
                          title: Text('${variant.color} - ${variant.size}'),
                          subtitle: Text(
                            'Số lượng trong kho: ${variant.stockQuantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Sửa',
                                onPressed: () =>
                                    _showVariantDialog(editingIndex: index),
                                icon: const Icon(Icons.edit_outlined),
                              ),
                              IconButton(
                                tooltip: 'Xóa',
                                onPressed: () {
                                  setState(() => variants.removeAt(index));
                                },
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    if (widget.product.coverImageBytes != null) {
      return Image.memory(widget.product.coverImageBytes!, fit: BoxFit.contain);
    }

    final imageUrl = widget.product.coverImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const _ImagePlaceholder();
        },
      );
    }

    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 72, color: Colors.red),
      ),
    );
  }
}
