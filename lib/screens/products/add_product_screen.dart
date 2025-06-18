import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../controllers/product_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/product.dart';
import '../../models/category.dart';

class AddProductScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _selectedCategory = Rxn<Category>();
  final _image = Rxn<File>();

  AddProductScreen({super.key});

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    final productController = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Name'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration('Description'),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<Category>(
                  decoration: _buildInputDecoration('Category'),
                  value: _selectedCategory.value,
                  items: categoryController.categories
                      .map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (value) => _selectedCategory.value = value,
                  validator: (value) =>
                      value == null ? 'Category is required' : null,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: _buildInputDecoration(
                        'Price',
                        suffixIcon: Icon(
                          Icons.attach_money,
                          color: Colors.grey,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Price is required' : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration: _buildInputDecoration(
                        'Stock Quantity',
                        suffixIcon: Icon(Icons.inventory_2, color: Colors.grey),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Stock is required' : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      decoration: _buildInputDecoration(
                        'Minimum Stock',
                        suffixIcon: Icon(
                          Icons.warning_amber,
                          color: Colors.grey,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Minimum stock is required'
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: _buildInputDecoration(
                        'Barcode',
                        suffixIcon: Icon(
                          Icons.qr_code_scanner,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      decoration: _buildInputDecoration(
                        'Purchase Price',
                        suffixIcon: Icon(
                          Icons.shopping_cart,
                          color: Colors.grey,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Purchase price is required'
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration: _buildInputDecoration(
                        'Sale Price',
                        suffixIcon: Icon(Icons.sell, color: Colors.grey),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Sale price is required'
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Obx(
                () => _image.value != null
                    ? Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _image.value!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.close, color: Colors.white),
                                onPressed: () => _image.value = null,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              _image.value = File(pickedFile.path);
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 48,
                                color: Color(0xFF6C63FF),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add Product Image',
                                style: TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final product = Product(
                        id: 0,
                        categoryId: _selectedCategory.value!.id,
                        name: _nameController.text.trim(),
                        slug: _nameController.text.toLowerCase().replaceAll(
                          ' ',
                          '-',
                        ),
                        description: _descriptionController.text.trim(),
                        price: double.parse(_priceController.text),
                        stockQuantity: int.parse(_stockController.text),
                        minimumStock: int.parse(_minStockController.text),
                        barcode: _barcodeController.text.trim(),
                        purchasePrice: double.parse(
                          _purchasePriceController.text,
                        ),
                        salePrice: double.parse(_salePriceController.text),
                      );

                      try {
                        await productController.addProduct(
                          product,
                          image: _image.value,
                        );
                        Get.back();
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to add product: $e',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
