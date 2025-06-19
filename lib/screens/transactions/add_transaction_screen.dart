import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/transaction.dart';
import '../../models/product.dart';

class AddTransactionScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  final _selectedProduct = Rxn<Product>();
  final _selectedType = 'in'.obs;

  AddTransactionScreen({super.key});

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
    final productController = Get.find<ProductController>();
    final transactionController = Get.find<TransactionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter transaction'),
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
                'Ajouter transaction',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24),
              Obx(
                () => DropdownButtonFormField<Product>(
                  decoration: _buildInputDecoration(
                    'Produit',
                    suffixIcon: Icon(Icons.inventory_2, color: Colors.grey),
                  ),
                  value: _selectedProduct.value,
                  items: productController.products
                      .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                      )
                      .toList(),
                  onChanged: (value) => _selectedProduct.value = value,
                  validator: (value) =>
                      value == null ? 'Produit est obligatoire' : null,
                ),
              ),
              SizedBox(height: 16),
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: EdgeInsets.all(4),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'in',
                        label: Text('Entrée'),
                        icon: Icon(Icons.arrow_downward),
                      ),
                      ButtonSegment(
                        value: 'out',
                        label: Text('Sortie'),
                        icon: Icon(Icons.arrow_upward),
                      ),
                    ],
                    selected: {_selectedType.value},
                    onSelectionChanged: (Set<String> newSelection) {
                      _selectedType.value = newSelection.first;
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Color(0xFF6C63FF);
                          }
                          return Colors.transparent;
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return Colors.black87;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _quantityController,
                decoration: _buildInputDecoration(
                  'Quantity',
                  suffixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'La quantité est obligatoire';
                  }
                  final quantity = int.tryParse(value!);
                  if (quantity == null || quantity <= 0) {
                    return 'Quantity must be greater than 0';
                  }
                  if (_selectedType.value == 'out' &&
                      _selectedProduct.value != null &&
                      quantity > _selectedProduct.value!.stockQuantity) {
                    return 'Le Stock est insuffisant';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: _buildInputDecoration(
                  'Notes',
                  suffixIcon: Icon(Icons.note, color: Colors.grey),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Obx(() {
                final product = _selectedProduct.value;
                if (product == null) return SizedBox.shrink();

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détails du produit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildDetailRow(
                          'Stock Actuel',
                          '${product.stockQuantity} units',
                          product.isLowStock ? Colors.red : Color(0xFF6C63FF),
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          'Prix d\'achat',
                          '${product.purchasePrice.toStringAsFixed(2)} F',
                          Color(0xFF6C63FF),
                        ),
                        SizedBox(height: 8),
                        _buildDetailRow(
                          'Prix de vente',
                          '\$${product.salePrice.toStringAsFixed(2)} F',
                          Color(0xFF6C63FF),
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
                      final product = _selectedProduct.value!;
                      final quantity = int.parse(_quantityController.text);
                      final unitPrice = _selectedType.value == 'in'
                          ? product.purchasePrice
                          : product.salePrice;

                      final transaction = Transaction(
                        id: 0,
                        productId: product.id,
                        userId: 1, // TODO: Get from auth controller
                        type: _selectedType.value,
                        quantity: quantity,
                        unitPrice: unitPrice,
                        totalPrice: unitPrice * quantity,
                        purchasePrice: product.purchasePrice,
                        salePrice: product.salePrice,
                        notes: _notesController.text.trim(),
                      );

                      final success = await transactionController
                          .addTransaction(transaction);
                      Get.back(result: success);
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
                    'Confirmer',
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

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.black54, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
