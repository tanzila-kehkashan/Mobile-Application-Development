import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';

class BookTicketScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> event;

  const BookTicketScreen({Key? key, required this.event}) : super(key: key);

  @override
  ConsumerState<BookTicketScreen> createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends ConsumerState<BookTicketScreen> {
  int _numberOfTickets = 1;
  String _selectedPaymentMethod = 'Credit Card';
  bool _isProcessing = false;

  // Controllers for Card Details
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'PayPal',
    'Apple Pay',
    'Google Pay',
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  double get _pricePerTicket => (widget.event['price'] ?? 0.0).toDouble();
  double get _totalAmount => _pricePerTicket * _numberOfTickets;

  // Widget to show card fields only when Card/Debit is selected
  Widget _buildCardFields() {
    if (_selectedPaymentMethod != 'Credit Card' && _selectedPaymentMethod != 'Debit Card') {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Card Information (Sandbox Mode)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '4242 4242 4242 4242',
            labelText: 'Card Number',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _expiryController,
                decoration: InputDecoration(
                  hintText: 'MM/YY',
                  labelText: 'Expiry',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _cvcController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '123',
                  labelText: 'CVC',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _processBooking() async {
    final currentUser = ref.read(authStateProvider).value;
    if (currentUser == null) {
      _showSnackBar('Please sign in to book tickets', isError: true);
      return;
    }

    // Validation for card fields
    if ((_selectedPaymentMethod == 'Credit Card' || _selectedPaymentMethod == 'Debit Card') &&
        (_cardNumberController.text.isEmpty || _cvcController.text.isEmpty)) {
      _showSnackBar('Please enter card details for testing', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Initialize Polar Service
      final polarService = PolarPaymentService();

      // 2. Perform Transactional API Call (No Webhooks)
      final paymentResult = await polarService.processPayment(
        amount: _totalAmount,
        currency: 'USD',
        description: 'Tickets for ${widget.event['title']}',
        metadata: {
          'userId': currentUser.uid,
          'eventId': widget.event['id'],
        },
        paymentMethod: _selectedPaymentMethod,
      );

      if (paymentResult['success'] == true) {
        // 3. Create Firestore Booking Record after payment confirmation
        final bookingService = ref.read(bookingServiceProvider);
        final booking = Booking(
          id: '',
          userId: currentUser.uid,
          userName: currentUser.displayName ?? 'User',
          eventId: widget.event['id'],
          eventTitle: widget.event['title'],
          eventLocation: widget.event['location'],
          eventDate: (widget.event['date'] as Timestamp).toDate(),
          eventStartTime: widget.event['startTime'],
          numberOfTickets: _numberOfTickets,
          pricePerTicket: _pricePerTicket,
          totalAmount: _totalAmount,
          paymentMethod: _selectedPaymentMethod,
          bookingStatus: 'confirmed',
          bookedAt: DateTime.now(),
        );

        await bookingService.createBooking(booking);

        if (mounted) {
          setState(() => _isProcessing = false);
          _showSuccessDialog();
        }
      } else {
        throw paymentResult['error'] ?? 'Payment Failed';
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnackBar('$e', isError: true);
    }
  }

  // --- Existing Helper Methods (Dialog/Snack) ---

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF00D9A5), size: 64),
            SizedBox(height: 16),
            Text('Booking Successful!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Your ticket${_numberOfTickets > 1 ? 's have' : ' has'} been booked successfully. View them in "My Tickets".',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF5B4EFF))),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF5B4EFF),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Book Ticket', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Info Card (Kept as original)
                  _buildEventInfoCard(),
                  const SizedBox(height: 24),

                  // Number of Tickets (Kept as original)
                  _buildTicketCounter(),
                  const SizedBox(height: 24),

                  // Payment Method Selection
                  const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map((method) => _buildPaymentOption(method)).toList(),
                  const SizedBox(height: 24),

                  // ADDED: Card Detail Fields
                  _buildCardFields(),

                  // Price Summary (Kept as original)
                  _buildPriceSummary(),
                ],
              ),
            ),
          ),

          // Bottom Confirm Button
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // --- UI Modularized Methods for cleaner code ---

  Widget _buildEventInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF5B4EFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.event['title'] ?? 'Event Title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.grey), const SizedBox(width: 8), Text('${widget.event['day']} ${widget.event['month']}, ${widget.event['year']}', style: const TextStyle(color: Colors.grey))]),
        ],
      ),
    );
  }

  Widget _buildTicketCounter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tickets', style: TextStyle(fontSize: 16)),
          Row(
            children: [
              IconButton(onPressed: _numberOfTickets > 1 ? () => setState(() => _numberOfTickets--) : null, icon: Icon(Icons.remove_circle_outline, color: _numberOfTickets > 1 ? const Color(0xFF5B4EFF) : Colors.grey)),
              Text('$_numberOfTickets', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => setState(() => _numberOfTickets++), icon: const Icon(Icons.add_circle_outline, color: Color(0xFF5B4EFF))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: _selectedPaymentMethod == method ? const Color(0xFF5B4EFF) : Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RadioListTile<String>(
        value: method,
        groupValue: _selectedPaymentMethod,
        activeColor: const Color(0xFF5B4EFF),
        onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
        title: Text(method),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Amount'), Text('\$${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5B4EFF)))]),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : ElevatedButton(
        onPressed: _processBooking,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B4EFF), minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Text('CONFIRM BOOKING - \$${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}