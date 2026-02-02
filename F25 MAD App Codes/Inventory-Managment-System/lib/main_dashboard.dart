import 'package:flutter/material.dart';
import 'main_profile.dart';
import 'report_product.dart';
import 'new_product.dart' show NewProductPage;
import 'low_stock.dart';
import 'total_stock.dart';
import 'services/product_service.dart';
import 'services/favorites_service.dart';
import 'barcode_scanner_screen.dart';
import 'sales_screen.dart';

void main() {
  runApp(const MyApp());
}

// --- 1. Custom Theme & Colors ---
class AppColors {
  // Light mode colors (default)
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

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkSearchBar = Color(0xFF2C2C2C);
  static const Color darkDivider = Color(0xFF3C3C3C);
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
      // Set the new MainHomePage as the initial screen for preview
      home: const MainHomePage(),
    );
  }
}

// --- 2. Custom Widgets (Specific to the Home Screen) ---

// Search Bar matching the design
class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSearchBar : AppColors.searchBarBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          children: [
            Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                onChanged: onChanged,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search Products......',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white38
                        : AppColors.primaryText.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Action Button matching the design (Add/Scan)
class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ActionButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: isDark
              ? AppColors.darkCard
              : AppColors.actionButtonBackground,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Custom Bottom Navigation Bar matching the image
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Height to accommodate the custom shape and padding
      decoration: const BoxDecoration(color: AppColors.bottomNavColor),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Row(
          children: [
            _buildNavItem(0, 'Home', Icons.home_outlined),
            _buildNavItem(1, 'Product', Icons.shopping_bag_outlined),
            _buildNavItem(2, 'Report', Icons.insert_chart_outlined),
            _buildNavItem(3, 'Profile', Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final bool isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onItemTapped(index),
        child: Container(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.bottomNavActiveColor
                    : AppColors.bottomNavActiveColor.withOpacity(0.6),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.bottomNavActiveColor
                      : AppColors.bottomNavActiveColor.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. Main Home Page (Matching iPhone 13 & 14 - 5.png) ---
class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 0; // Home is selected
  String _searchQuery = ''; // Search query for filtering products

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to different pages based on selected index
    switch (index) {
      case 0:
        // Already on Home, do nothing
        break;
      case 1:
        // Product tab -> Total Stock
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TotalStockScreen()),
        );
        break;
      case 2:
        // Report tab -> Report Product
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportProductPage()),
        );
        break;
      case 3:
        // Profile tab -> My Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProfilePage()),
        );
        break;
    }
  }

  void _showScanOptions(BuildContext context) {
    // Navigate directly to Sales screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SalesScreen()),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header (Back Arrow, Title (Implicit), Illustration) ---
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Back Arrow (Matching previous screens)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const Spacer(),
                          // Illustration Placeholder (Top Right - smaller version)
                          Container(
                            width: 60,
                            height: 60,
                            // Mimicking the small inventory illustration in the top right
                            decoration: BoxDecoration(
                              color: AppColors.illustrationColor.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.inventory_2,
                              size: 30,
                              color: AppColors.illustrationColor.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Search Bar ---
                    CustomSearchBar(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // --- Action Buttons (Add new product / Record Sale) ---
                    Row(
                      children: [
                        ActionButton(
                          text: 'Add new product',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NewProductPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 15),
                        ActionButton(
                          text: 'Record Sale',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SalesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Quick Stats Cards (Real-time) ---
                    StreamBuilder<List<Product>>(
                      stream: productService.getProductsStream(),
                      builder: (context, snapshot) {
                        final products = snapshot.data ?? [];
                        final totalProducts = products.length;
                        final totalValue = products.fold<double>(
                          0,
                          (sum, p) => sum + (p.price * p.quantity),
                        );
                        final categories = products
                            .map((p) => p.category)
                            .toSet()
                            .length;

                        return Row(
                          children: [
                            _buildStatCard(
                              'Total Products',
                              '$totalProducts',
                              Icons.inventory_2_outlined,
                              Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Inventory Value',
                              'PKR ${totalValue.toStringAsFixed(0)}',
                              Icons.attach_money,
                              Colors.green,
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Categories',
                              '$categories',
                              Icons.category_outlined,
                              Colors.orange,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    // --- Low Stock Alert (Real-time from Firebase) ---
                    StreamBuilder<List<Product>>(
                      stream: productService.getLowStockProductsStream(),
                      builder: (context, snapshot) {
                        final lowStockCount = snapshot.data?.length ?? 0;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LowStockAlertScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: lowStockCount > 0
                                  ? AppColors.lowStockAlertBackground
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              lowStockCount > 0
                                  ? 'Low Stock Alert: $lowStockCount\nitem${lowStockCount > 1 ? 's' : ''} need reorder'
                                  : 'All products are well stocked!',
                              style: const TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // --- My Inventory Header ---
                    const Text(
                      'My Inventory',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Inventory List (Real-time from Firebase) ---
                    StreamBuilder<List<Product>>(
                      stream: productService.getProductsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final allProducts = snapshot.data ?? [];

                        // Filter products based on search query
                        final products = _searchQuery.isEmpty
                            ? allProducts
                            : allProducts
                                  .where(
                                    (product) =>
                                        product.name.toLowerCase().contains(
                                          _searchQuery,
                                        ) ||
                                        product.category.toLowerCase().contains(
                                          _searchQuery,
                                        ),
                                  )
                                  .toList();

                        if (allProducts.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add your first product to get started',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Show "no results" message when search has no matches
                        if (products.isEmpty && _searchQuery.isNotEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No products found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Try a different search term',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Show first 4 products
                        final displayProducts = products.take(4).toList();

                        return Column(
                          children: [
                            ...displayProducts.map(
                              (product) => Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: _buildProductCard(product),
                              ),
                            ),
                            if (products.length > 4)
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TotalStockScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Show all ${products.length} products',
                                    style: const TextStyle(
                                      color: AppColors.primaryText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // --- Bottom Navigation Bar ---
            CustomBottomNavBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return _ProductCardWithFavorite(
      product: product,
      onFavoriteToggled: () {
        if (mounted) setState(() {});
      },
    );
  }
}

// Separate StatefulWidget for product card with favorites
class _ProductCardWithFavorite extends StatefulWidget {
  final Product product;
  final VoidCallback onFavoriteToggled;

  const _ProductCardWithFavorite({
    required this.product,
    required this.onFavoriteToggled,
  });

  @override
  State<_ProductCardWithFavorite> createState() =>
      _ProductCardWithFavoriteState();
}

class _ProductCardWithFavoriteState extends State<_ProductCardWithFavorite> {
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFav = await favoritesService.isFavorite(widget.product.id ?? '');
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    // Optimistic update - change UI immediately
    final wasFavorite = _isFavorite;
    setState(() => _isFavorite = !_isFavorite);

    // Show snackbar immediately
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              !wasFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                !wasFavorite
                    ? '${widget.product.name} added to favorites!'
                    : '${widget.product.name} removed from favorites',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: !wasFavorite ? Colors.pink : Colors.grey,
        duration: const Duration(seconds: 1),
      ),
    );

    widget.onFavoriteToggled();

    // Save in background (don't await)
    favoritesService.toggleFavorite(widget.product).then((result) {
      // Only update if different from optimistic result
      if (mounted && result != !wasFavorite) {
        setState(() => _isFavorite = result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.searchBarBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryText.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        border: widget.product.isLowStock
            ? Border.all(color: Colors.red.shade300, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Row(
          children: [
            // Favorite Icon
            GestureDetector(
              onTap: _toggleFavorite,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.pink : Colors.grey,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 10),
            // Product Icon
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.illustrationColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  widget.product.imageUrl != null &&
                      widget.product.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.illustrationColor,
                          size: 22,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.illustrationColor,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stock: ${widget.product.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.product.isLowStock
                              ? Colors.red
                              : Colors.grey,
                          fontWeight: widget.product.isLowStock
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (widget.product.isLowStock) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.warning,
                          size: 12,
                          color: Colors.red.shade600,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Price
            Text(
              'PKR ${widget.product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
