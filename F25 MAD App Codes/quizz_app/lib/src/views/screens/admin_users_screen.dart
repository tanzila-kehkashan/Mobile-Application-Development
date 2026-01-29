import 'package:flutter/material.dart';
import 'package:quizz_app/services/auth_service.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2c2c2c),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF3a3a3a), elevation: 0),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("User Management"),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _authService.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No users found."));
            }

            final users = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final email = user['email'] ?? 'No Email';
                final role = user['role'] ?? 'user';
                final id = user['id'] ?? '';
                final displayName = user['displayName'] ?? 'User';

                return Card(
                  color: const Color(0xFF3e3e3e),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: role == 'admin' ? Colors.purpleAccent : Colors.tealAccent,
                      child: Icon(
                        role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                        color: Colors.black,
                      ),
                    ),
                    title: Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(email, style: const TextStyle(color: Colors.grey)),
                        Text("Role: $role", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        Text("ID: $id", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
