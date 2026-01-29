import 'package:flutter/material.dart';
import 'package:quizz_app/services/help_service.dart';
import 'package:intl/intl.dart';

class AdminHelpRequestsScreen extends StatelessWidget {
  const AdminHelpRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HelpService _helpService = HelpService();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2c2c2c),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF3a3a3a), elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Help Requests", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _helpService.getHelpRequests(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No help requests yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            final requests = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _buildRequestCard(context, request, _helpService);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Map<String, dynamic> request, HelpService helpService) {
    final status = request['status'] ?? 'pending';
    final isPending = status == 'pending';
    final userName = request['userName'] ?? 'User';
    final userEmail = request['userEmail'] ?? 'No email';
    final subject = request['subject'] ?? 'No subject';
    final message = request['message'] ?? 'No message';
    final timestamp = request['timestamp'];
    final requestId = request['id'] ?? '';

    String formattedDate = 'Unknown date';
    if (timestamp != null) {
      try {
        final date = (timestamp as dynamic).toDate();
        formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(date);
      } catch (e) {
        formattedDate = 'Invalid date';
      }
    }

    return Card(
      color: const Color(0xFF3e3e3e),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isPending ? Colors.orangeAccent : Colors.greenAccent,
          child: Icon(
            isPending ? Icons.help_outline : Icons.check_circle_outline,
            color: Colors.black,
          ),
        ),
        title: Text(
          subject,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'From: $userName ($userEmail)',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            isPending ? 'Pending' : 'Resolved',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          backgroundColor: isPending ? Colors.orangeAccent : Colors.greenAccent,
          labelStyle: const TextStyle(color: Colors.black),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final newStatus = isPending ? 'resolved' : 'pending';
                  try {
                    await helpService.updateRequestStatus(requestId, newStatus);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Marked as ${isPending ? "resolved" : "pending"}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Icon(isPending ? Icons.check : Icons.refresh, size: 16),
                label: Text(isPending ? 'Mark Resolved' : 'Mark Pending'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending ? Colors.greenAccent : Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
