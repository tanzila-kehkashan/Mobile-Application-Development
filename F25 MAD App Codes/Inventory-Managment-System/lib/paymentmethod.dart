import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// --- 1. Custom Theme & Colors (Consistent with previous screens) ---
class AppColors {
  // Primary App Colors
  static const Color accentOrange = Color(0xFFE08F4C);
  static const Color primaryText = Colors.black;
  static const Color backgroundColor = Color(
    0xFFF0F4F9,
  ); // Very light blue/lavender
  static const Color buttonColor = Color(0xFF70B8C0); // Muted teal/cyan
  static const Color illustrationColor = Color(0xFF6A99E0);
  static const Color textFieldBackground = Colors.white;
  static const Color dividerColor = Color(0xFFE5E5E5);

  // Home Screen Colors
  static const Color searchBarBackground = Colors.white;
  static const Color actionButtonBackground = Color(0xFFE5E5E5);
  static const Color lowStockAlertBackground = Color(0xFFFFCCCC);
  static const Color bottomNavColor = Color(0xFF6B7280);
  static const Color bottomNavActiveColor = Colors.white;

  // Report Page Colors
  static const Color submitButtonColor = Color(0xFF1F487B);

  // Minimal Splash Button Color
  static const Color premiumButtonColor = Color(0xFFB0B0B0);
  static const Color premiumButtonShadow = Color(0x22000000);

  // New Payment Method Colors
  static const Color confirmButtonColor = Color(
    0xFF1F487B,
  ); // Deep blue, same as report submit
  static const Color backButtonColor = Color(0xFFE5E5E5); // Light grey/beige
  static const Color otherMethodColor = Color(
    0xFFB0B0B0,
  ); // Greyish for the "Other Method" button
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
      // Set the new PaymentMethodPage as the initial screen for preview
      home: const PaymentMethodPage(),
    );
  }
}

// --- 2. Shared Custom Widgets ---

// Custom Bottom Navigation Bar matching the image (Needed for consistency)
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
      height: 80,
      decoration: const BoxDecoration(color: AppColors.bottomNavColor),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? AppColors.bottomNavActiveColor
                  : AppColors.bottomNavActiveColor.withOpacity(0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Payment Option Tile (Now uses a NetworkImage to match the visual design)
class PaymentOptionTile extends StatelessWidget {
  final String logoUrl; // URL for the payment logo
  final String logoName; // Text for error/accessibility
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentOptionTile({
    super.key,
    required this.logoUrl,
    required this.logoName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120, // Give it a fixed height to show the image clearly
          decoration: BoxDecoration(
            color: AppColors.textFieldBackground, // White background
            borderRadius: BorderRadius.circular(15.0),
            border: isSelected
                ? Border.all(color: AppColors.confirmButtonColor, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryText.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20.0),
          child: Center(
            child: Image.network(
              logoUrl,
              height: 60, // Sizing the image to fit the container
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                logoName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 3. Payment Method Page (Matching Payment method.png) ---
class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  int _selectedIndex = 3;
  String? _selectedPayment;
  String? _accountHolderName;
  String? _accountNumber;

  // Debit card details
  String? _cardNumber;
  String? _cardExpiry;
  String? _cardCvv;
  String? _cardHolderName;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Show debit card dialog
  void _showDebitCardDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      'Add Debit Card',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card Visual Preview
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade900.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.credit_card,
                            color: Colors.white54,
                            size: 30,
                          ),
                          Image.network(
                            'https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg',
                            width: 50,
                            height: 20,
                            color: Colors.white,
                            errorBuilder: (_, __, ___) => const Text(
                              'VISA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        cardNumberController.text.isEmpty
                            ? '•••• •••• •••• ••••'
                            : _formatCardNumber(cardNumberController.text),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          letterSpacing: 2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CARD HOLDER',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                nameController.text.isEmpty
                                    ? 'YOUR NAME'
                                    : nameController.text.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'EXPIRES',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                expiryController.text.isEmpty
                                    ? 'MM/YY'
                                    : expiryController.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Card Number
                const Text(
                  'Card Number',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: '1234 5678 9012 3456',
                    counterText: '',
                    prefixIcon: const Icon(Icons.credit_card),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A237E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry and CVV Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Expiry Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: expiryController,
                            keyboardType: TextInputType.datetime,
                            maxLength: 5,
                            onChanged: (_) => setModalState(() {}),
                            decoration: InputDecoration(
                              hintText: 'MM/YY',
                              counterText: '',
                              prefixIcon: const Icon(Icons.calendar_today),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1A237E),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CVV',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: cvvController,
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '•••',
                              counterText: '',
                              prefixIcon: const Icon(Icons.lock_outline),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1A237E),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Cardholder Name
                const Text(
                  'Cardholder Name',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Enter name on card',
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF1A237E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (cardNumberController.text.trim().length < 16) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter valid card number'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (expiryController.text.trim().length < 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter expiry date'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (cvvController.text.trim().length < 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter valid CVV'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (nameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter cardholder name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        _selectedPayment = 'DebitCard';
                        _cardNumber = cardNumberController.text.trim();
                        _cardExpiry = expiryController.text.trim();
                        _cardCvv = cvvController.text.trim();
                        _cardHolderName = nameController.text.trim();
                        _accountHolderName = nameController.text.trim();
                        _accountNumber =
                            '****' +
                            cardNumberController.text.trim().substring(
                              cardNumberController.text.trim().length - 4,
                            );
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Text('Debit card added successfully!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Add Card',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCardNumber(String number) {
    number = number.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < number.length; i++) {
      if (i > 0 && i % 4 == 0) formatted += ' ';
      formatted += number[i];
    }
    return formatted;
  }

  // Show payment details dialog
  void _showPaymentDialog(String paymentMethod) {
    final nameController = TextEditingController();
    final numberController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: paymentMethod == 'JazzCash'
                        ? const Color(0xFFE31937)
                        : const Color(0xFF00A651),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      paymentMethod == 'JazzCash' ? 'JC' : 'EP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  paymentMethod,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Account Holder Name
            const Text(
              'Account Holder Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: paymentMethod == 'JazzCash'
                        ? const Color(0xFFE31937)
                        : const Color(0xFF00A651),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Account Number
            const Text(
              'Account Number / Mobile Number',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '03XX-XXXXXXX',
                prefixIcon: const Icon(Icons.phone_android),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: paymentMethod == 'JazzCash'
                        ? const Color(0xFFE31937)
                        : const Color(0xFF00A651),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter account holder name'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (numberController.text.trim().isEmpty ||
                      numberController.text.trim().length < 10) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter valid account number'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _selectedPayment = paymentMethod;
                    _accountHolderName = nameController.text.trim();
                    _accountNumber = numberController.text.trim();
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 10),
                          Text('$paymentMethod account linked!'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: paymentMethod == 'JazzCash'
                      ? const Color(0xFFE31937)
                      : const Color(0xFF00A651),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Save Account',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmPayment() {
    if (_selectedPayment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_accountHolderName == null || _accountNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your account details'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Method Saved!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '$_selectedPayment\n$_accountHolderName\n$_accountNumber',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Go back to profile
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.confirmButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder URLs for the logos to achieve the visual effect
  static const String jazzCashLogoUrl =
      'https://upload.wikimedia.org/wikipedia/commons/b/b3/JazzCash_logo.png';
  static const String easyPaisaLogoUrl =
      'https://upload.wikimedia.org/wikipedia/commons/1/1a/Easypaisa_logo.png';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Top Header ---
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Arrow
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const Spacer(),
                  // Illustration Placeholder
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.illustrationColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.payment,
                      size: 20,
                      color: AppColors.illustrationColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // --- Content Area ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select your payment method',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // JazzCash and Easypaisa options (in a row)
                    Row(
                      children: [
                        PaymentOptionTile(
                          logoUrl: jazzCashLogoUrl,
                          logoName: 'JazzCash',
                          isSelected: _selectedPayment == 'JazzCash',
                          onTap: () => _showPaymentDialog('JazzCash'),
                        ),
                        const SizedBox(width: 20),
                        PaymentOptionTile(
                          logoUrl: easyPaisaLogoUrl,
                          logoName: 'Easypaisa',
                          isSelected: _selectedPayment == 'Easypaisa',
                          onTap: () => _showPaymentDialog('Easypaisa'),
                        ),
                      ],
                    ),

                    // Show saved account info if available
                    if (_selectedPayment != null && _accountHolderName != null)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_selectedPayment Account',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$_accountHolderName • $_accountNumber',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedPayment = null;
                                  _accountHolderName = null;
                                  _accountNumber = null;
                                });
                              },
                              icon: const Icon(Icons.close, size: 20),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 40),

                    // 'or' separator
                    const Text(
                      'or',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Add Debit Card
                    GestureDetector(
                      onTap: _showDebitCardDialog,
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: _selectedPayment == 'DebitCard'
                              ? Colors.blue.shade50
                              : AppColors.backButtonColor,
                          borderRadius: BorderRadius.circular(15),
                          border: _selectedPayment == 'DebitCard'
                              ? Border.all(
                                  color: const Color(0xFF1A237E),
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.credit_card,
                              color: _selectedPayment == 'DebitCard'
                                  ? const Color(0xFF1A237E)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedPayment == 'DebitCard' &&
                                        _cardHolderName != null
                                    ? '$_cardHolderName • $_accountNumber'
                                    : 'Add Debit card',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedPayment == 'DebitCard'
                                      ? const Color(0xFF1A237E)
                                      : AppColors.primaryText.withOpacity(0.7),
                                  fontWeight: _selectedPayment == 'DebitCard'
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_selectedPayment == 'DebitCard')
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF1A237E),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // --- Confirm Button ---
                    Container(
                      width: double.infinity,
                      height: 60,
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: ElevatedButton(
                        onPressed: _confirmPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.confirmButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // --- BACK Button ---
                    Container(
                      width: double.infinity,
                      height: 55,
                      margin: const EdgeInsets.only(bottom: 20.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backButtonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'BACK',
                          style: TextStyle(
                            color: AppColors.primaryText,
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
}

// Placeholder classes for other screens (omitted for brevity)
// You would paste the full content of these from earlier steps for a complete app.
/*
class MinimalSplashPage extends StatelessWidget {
  const MinimalSplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Minimal Splash Page')));
  }
}
class ReportProductPage extends StatefulWidget {
  const ReportProductPage({super.key});
  @override
  State<ReportProductPage> createState() => _ReportProductPageState();
}


class _ReportProductPageState extends State<ReportProductPage> {
  int _selectedIndex = 2;
  void _onItemTapped(int index) {setState(() {_selectedIndex = index;});}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Report Product Page Content')),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
    );
  }
}
*/
