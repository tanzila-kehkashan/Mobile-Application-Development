import 'package:flutter/material.dart';
import 'services/transaction_service.dart';
import 'services/product_service.dart';
import 'services/supplier_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _customerController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _transactionType = TransactionType.sale;
  Product? _selectedProduct;
  Supplier? _selectedSupplier;
  List<Product> _products = [];
  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final products = await productService.getProducts();
      final suppliers = await supplierService.getSuppliers();
      if (mounted) {
        setState(() {
          _products = products;
          _suppliers = suppliers;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _customerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    final qty = int.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_unitPriceController.text) ?? 0;
    return qty * price;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSale = _transactionType == TransactionType.sale;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF0F4F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Transaction',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Type Toggle
                    _buildSectionTitle('Transaction Type'),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () => _transactionType = TransactionType.sale,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isSale
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSale
                                      ? Border.all(
                                          color: Colors.green,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color: isSale
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sale',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSale
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () =>
                                    _transactionType = TransactionType.purchase,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: !isSale
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: !isSale
                                      ? Border.all(
                                          color: Colors.orange,
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color: !isSale
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Purchase',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: !isSale
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Product Selection
                    _buildSectionTitle('Select Product'),
                    const SizedBox(height: 12),
                    _buildProductDropdown(isDark),
                    if (_selectedProduct != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Available: ${_selectedProduct!.quantity} units',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Quantity and Price
                    _buildSectionTitle('Quantity & Price'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _quantityController,
                            label: 'Quantity',
                            icon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Required';
                              final qty = int.tryParse(v!);
                              if (qty == null || qty <= 0) return 'Invalid';
                              if (isSale &&
                                  _selectedProduct != null &&
                                  qty > _selectedProduct!.quantity) {
                                return 'Max: ${_selectedProduct!.quantity}';
                              }
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _unitPriceController,
                            label: 'Unit Price (Rs)',
                            icon: Icons.attach_money,
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v?.isEmpty ?? true) return 'Required';
                              if (double.tryParse(v!) == null) return 'Invalid';
                              return null;
                            },
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Total Amount Display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (isSale ? Colors.green : Colors.orange)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSale ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Rs ${_totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isSale ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Customer/Supplier
                    if (isSale) ...[
                      _buildSectionTitle('Customer (Optional)'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _customerController,
                        label: 'Customer Name',
                        icon: Icons.person,
                      ),
                    ] else ...[
                      _buildSectionTitle('Supplier (Optional)'),
                      const SizedBox(height: 12),
                      _buildSupplierDropdown(isDark),
                    ],
                    const SizedBox(height: 24),

                    // Notes
                    _buildSectionTitle('Notes (Optional)'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Add notes...',
                      icon: Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSale
                              ? Colors.green
                              : Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isSale ? 'Record Sale' : 'Record Purchase',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildProductDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Product>(
          isExpanded: true,
          hint: Text(
            'Select a product',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          value: _selectedProduct,
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          items: _products.map((product) {
            return DropdownMenuItem(
              value: product,
              child: Row(
                children: [
                  Expanded(child: Text(product.name)),
                  Text(
                    '(${product.quantity})',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (product) {
            setState(() {
              _selectedProduct = product;
              if (product != null) {
                _unitPriceController.text = product.price.toStringAsFixed(0);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildSupplierDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Supplier>(
          isExpanded: true,
          hint: Text(
            'Select a supplier',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          value: _selectedSupplier,
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          items: _suppliers.map((supplier) {
            return DropdownMenuItem(
              value: supplier,
              child: Text(supplier.name),
            );
          }).toList(),
          onChanged: (supplier) => setState(() => _selectedSupplier = supplier),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey.shade600,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF6A99E0)),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A99E0), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Get data before navigating
    final userId = transactionService.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final transaction = InventoryTransaction(
      productId: _selectedProduct!.id!,
      productName: _selectedProduct!.name,
      type: _transactionType,
      quantity: int.parse(_quantityController.text),
      unitPrice: double.parse(_unitPriceController.text),
      supplierId: _selectedSupplier?.id,
      supplierName: _selectedSupplier?.name,
      customerName: _customerController.text.trim().isEmpty
          ? null
          : _customerController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      userId: userId,
    );

    // Navigate back immediately (optimistic UI)
    Navigator.pop(context, true);

    // Save transaction in background
    transactionService
        .addTransaction(transaction)
        .then((_) {
          // Success - transaction saved
        })
        .catchError((e) {
          // Show error if save fails (user may have left this screen)
          debugPrint('Transaction save error: $e');
        });
  }
}
