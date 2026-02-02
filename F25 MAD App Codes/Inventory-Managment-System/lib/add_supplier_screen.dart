import 'package:flutter/material.dart';
import 'services/supplier_service.dart';

class AddSupplierScreen extends StatefulWidget {
  final Supplier? supplier; // If provided, we're editing

  const AddSupplierScreen({super.key, this.supplier});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  List<String> _suppliedProducts = [];
  final _productController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.supplier!;
      _nameController.text = s.name;
      _contactPersonController.text = s.contactPerson;
      _phoneController.text = s.phone;
      _emailController.text = s.email;
      _addressController.text = s.address;
      _notesController.text = s.notes ?? '';
      _suppliedProducts = List.from(s.suppliedProducts);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _productController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          _isEditing ? 'Edit Supplier' : 'Add Supplier',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company/Supplier Name
              _buildSectionTitle('Supplier Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Company/Supplier Name',
                icon: Icons.business,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Please enter supplier name' : null,
              ),
              const SizedBox(height: 16),

              // Contact Person
              _buildTextField(
                controller: _contactPersonController,
                label: 'Contact Person',
                icon: Icons.person,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Please enter contact person' : null,
              ),
              const SizedBox(height: 24),

              // Contact Information
              _buildSectionTitle('Contact Information'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Please enter email';
                  if (!v!.contains('@')) return 'Please enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _addressController,
                label: 'Address (Optional)',
                icon: Icons.location_on,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Supplied Products
              _buildSectionTitle('Supplied Products'),
              const SizedBox(height: 12),
              _buildProductsSection(isDark),
              const SizedBox(height: 24),

              // Notes
              _buildSectionTitle('Additional Notes'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _notesController,
                label: 'Notes (Optional)',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSupplier,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A99E0),
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
                          _isEditing ? 'Update Supplier' : 'Add Supplier',
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      validator: validator,
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

  Widget _buildProductsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add product input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _productController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Add a product category...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _addProduct(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addProduct,
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFF6A99E0),
                size: 32,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Product chips
        if (_suppliedProducts.isEmpty)
          Text(
            'No products added yet',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suppliedProducts
                .map(
                  (product) => Chip(
                    label: Text(product),
                    backgroundColor: const Color(0xFF6A99E0).withOpacity(0.1),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () =>
                        setState(() => _suppliedProducts.remove(product)),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  void _addProduct() {
    final product = _productController.text.trim();
    if (product.isNotEmpty && !_suppliedProducts.contains(product)) {
      setState(() {
        _suppliedProducts.add(product);
        _productController.clear();
      });
    }
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = supplierService.currentUserId;
      if (userId == null) {
        throw 'User not logged in';
      }

      final supplier = Supplier(
        id: widget.supplier?.id,
        name: _nameController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        suppliedProducts: _suppliedProducts,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        userId: userId,
        createdAt: widget.supplier?.createdAt,
      );

      if (_isEditing) {
        await supplierService.updateSupplier(supplier);
      } else {
        await supplierService.addSupplier(supplier);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
