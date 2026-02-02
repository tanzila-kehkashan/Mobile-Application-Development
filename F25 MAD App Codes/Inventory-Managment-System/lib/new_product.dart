import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'services/product_service.dart';
import 'services/image_service.dart';
import 'services/supplier_service.dart';

void main() {
  runApp(const MyApp());
}

// --- 1. Custom Theme & Colors ---
class AppColors {
  static const Color accentOrange = Color(0xFFE08F4C);
  static const Color primaryText = Colors.black;
  static const Color backgroundColor = Color(0xFFF0F4F9);
  static const Color buttonColor = Color(0xFF70B8C0);
  static const Color illustrationColor = Color(0xFF6A99E0);
  static const Color textFieldBackground = Colors.white;
  static const Color dividerColor = Color(0xFFE5E5E5);
  static const Color searchBarBackground = Colors.white;
  static const Color actionButtonBackground = Color(0xFFE5E5E5);
  static const Color lowStockAlertBackground = Color(0xFFFFCCCC);
  static const Color bottomNavColor = Color(0xFF6B7280);
  static const Color bottomNavActiveColor = Colors.white;
  static const Color submitButtonColor = Color(0xFF1F487B);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Inventory',
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primaryText),
        ),
      ),
      home: const NewProductPage(),
    );
  }
}

// --- 2. Custom Form Field ---
class ProductTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const ProductTextField({
    super.key,
    this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
            child: Text(
              label!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primaryText,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.primaryText.withOpacity(0.4),
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.textFieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: AppColors.dividerColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: AppColors.dividerColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: AppColors.illustrationColor,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}

// --- 3. New Product Page ---
class NewProductPage extends StatefulWidget {
  final String? initialSku;

  const NewProductPage({super.key, this.initialSku});

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  String? _selectedCategory;
  bool _isLoading = false;
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  // Supplier details (inline entry)
  final _supplierNameController = TextEditingController();
  final _supplierContactController = TextEditingController();

  // Form controllers
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _skuController = TextEditingController();
  final _minStockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _categories = [
    'Electronics',
    'Clothing',
    'Food & Beverages',
    'Home & Garden',
    'Sports & Outdoors',
    'Health & Beauty',
    'Toys & Games',
    'Books & Stationery',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial SKU from barcode scanner if provided
    if (widget.initialSku != null) {
      _skuController.text = widget.initialSku!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _skuController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    _supplierNameController.dispose();
    _supplierContactController.dispose();
    super.dispose();
  }

  /// Show image source selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.illustrationColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.illustrationColor,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select an existing photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.buttonColor,
                  ),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text('Remove Image'),
                  subtitle: const Text('Delete selected image'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _imageBytes = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _imageBytes = bytes;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    source == ImageSource.camera
                        ? 'Photo captured!'
                        : 'Image selected!',
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Could not open camera. Please check permissions in Settings.'
                  : 'Could not open gallery.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Open barcode scanner
  void _openBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Stack(
          children: [
            // Camera Scanner
            MobileScanner(
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  final code = barcodes.first.rawValue!;
                  Navigator.pop(context);
                  setState(() {
                    _skuController.text = code;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Barcode scanned: $code'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            // Overlay
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 50,
                      color: Colors.white54,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Point at barcode',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
            // Title
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: const Text(
                'Scan Barcode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    // Check if user is logged in
    if (productService.currentUserId == null) {
      _showError('You must be logged in to add products. Please login first.');
      return;
    }

    // Validate form
    if (_nameController.text.isEmpty) {
      _showError('Please enter product name');
      return;
    }
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }
    if (_priceController.text.isEmpty) {
      _showError('Please enter price');
      return;
    }
    if (_quantityController.text.isEmpty) {
      _showError('Please enter quantity');
      return;
    }

    // Store values before navigating
    final productName = _nameController.text.trim();
    final category = _selectedCategory!;
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final sku = _skuController.text.trim().isEmpty
        ? null
        : _skuController.text.trim();
    final minStock = int.tryParse(_minStockController.text) ?? 10;
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();
    final userId = productService.currentUserId!;
    final imageBytes = _imageBytes;

    // Navigate back immediately (optimistic update)
    Navigator.pop(context, true);

    // Save in background - no await
    _saveProductInBackground(
      productName: productName,
      category: category,
      price: price,
      quantity: quantity,
      sku: sku,
      minStock: minStock,
      description: description,
      userId: userId,
      imageBytes: imageBytes,
      supplierName: _supplierNameController.text.trim().isEmpty
          ? null
          : _supplierNameController.text.trim(),
      supplierContact: _supplierContactController.text.trim().isEmpty
          ? null
          : _supplierContactController.text.trim(),
    );
  }

  Future<void> _saveProductInBackground({
    required String productName,
    required String category,
    required double price,
    required int quantity,
    required String? sku,
    required int minStock,
    required String? description,
    required String userId,
    required Uint8List? imageBytes,
    String? supplierName,
    String? supplierContact,
  }) async {
    try {
      String? imageUrl;

      // Upload image if selected (skip for speed, or upload in background)
      if (imageBytes != null) {
        try {
          final tempProductId = DateTime.now().millisecondsSinceEpoch
              .toString();
          imageUrl = await imageService.uploadImageBytes(
            imageBytes,
            tempProductId,
          );
          print('Image uploaded: $imageUrl');
        } catch (e) {
          print('Image upload failed: $e');
          // Continue without image
        }
      }

      final product = Product(
        name: productName,
        category: category,
        price: price,
        quantity: quantity,
        sku: sku,
        minStockLevel: minStock,
        description: description,
        imageUrl: imageUrl,
        userId: userId,
        supplierName: supplierName,
        supplierContact: supplierContact,
      );

      final docId = await productService.addProduct(product);
      print('Product "$productName" saved with ID: $docId');
    } catch (e) {
      print('Add product error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header ---
            AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primaryText,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              centerTitle: true,
              title: const Text(
                'Add New Product',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),

            // --- Form Content ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Upload
                      Center(
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.textFieldBackground,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _selectedImage != null
                                    ? AppColors.illustrationColor
                                    : AppColors.dividerColor,
                                width: 2,
                              ),
                              boxShadow: _selectedImage != null
                                  ? [
                                      BoxShadow(
                                        color: AppColors.illustrationColor
                                            .withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _imageBytes != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Image.memory(
                                          _imageBytes!,
                                          width: 140,
                                          height: 140,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: AppColors.illustrationColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 45,
                                        color: AppColors.primaryText
                                            .withOpacity(0.4),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add Image',
                                        style: TextStyle(
                                          color: AppColors.primaryText
                                              .withOpacity(0.5),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Tap to select',
                                        style: TextStyle(
                                          color: AppColors.primaryText
                                              .withOpacity(0.3),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Product Name
                      ProductTextField(
                        controller: _nameController,
                        label: 'Product Name',
                        hint: 'Enter product name',
                      ),

                      // Category Dropdown
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
                        child: const Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: AppColors.textFieldBackground,
                          borderRadius: BorderRadius.circular(15.0),
                          border: Border.all(
                            color: AppColors.dividerColor,
                            width: 1.0,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            hint: Text(
                              'Select category',
                              style: TextStyle(
                                color: AppColors.primaryText.withOpacity(0.5),
                              ),
                            ),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Supplier Dropdown (Seller)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 15.0),
                        child: Row(
                          children: [
                            const Text(
                              'Supplier / Seller',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '(Optional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryText.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Supplier Name Field
                      ProductTextField(
                        controller: _supplierNameController,
                        label: '',
                        hint: 'Supplier/Seller Name',
                      ),
                      // Supplier Contact Field
                      ProductTextField(
                        controller: _supplierContactController,
                        label: '',
                        hint: 'Supplier Phone/Contact',
                        keyboardType: TextInputType.phone,
                      ),

                      // Price and Quantity Row
                      Row(
                        children: [
                          Expanded(
                            child: ProductTextField(
                              controller: _priceController,
                              label: 'Price',
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: Text(
                                  'PKR',
                                  style: TextStyle(
                                    color: AppColors.primaryText.withOpacity(
                                      0.5,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ProductTextField(
                              controller: _quantityController,
                              label: 'Quantity',
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      // SKU / Barcode with Scanner
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0, top: 15.0),
                            child: Text(
                              'SKU / Barcode',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _skuController,
                            decoration: InputDecoration(
                              hintText: 'Enter SKU or scan barcode',
                              hintStyle: TextStyle(
                                color: AppColors.primaryText.withOpacity(0.4),
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: AppColors.textFieldBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: AppColors.dividerColor,
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: AppColors.dividerColor,
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                  color: AppColors.illustrationColor,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 15,
                              ),
                              suffixIcon: IconButton(
                                onPressed: _openBarcodeScanner,
                                icon: const Icon(
                                  Icons.qr_code_scanner,
                                  size: 24,
                                  color: AppColors.illustrationColor,
                                ),
                                tooltip: 'Scan Barcode',
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Minimum Stock Level
                      ProductTextField(
                        controller: _minStockController,
                        label: 'Minimum Stock Level',
                        hint: 'Alert when stock falls below this (default: 10)',
                        keyboardType: TextInputType.number,
                      ),

                      // Description
                      ProductTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter product description (optional)',
                        maxLines: 4,
                      ),

                      const SizedBox(height: 40),

                      // --- Add Product Button ---
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(bottom: 20.0),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.submitButtonColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5,
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
                              : const Text(
                                  'Add Product',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    );
  }
}
