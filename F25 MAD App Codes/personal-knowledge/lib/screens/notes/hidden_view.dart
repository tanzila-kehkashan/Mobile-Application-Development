import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/pin_manager_service.dart';
import '../edit_note_screen.dart';
import '../view_note_screen.dart';

class HiddenView extends StatefulWidget {
  final String searchQuery;
  
  const HiddenView({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  State<HiddenView> createState() => _HiddenViewState();
}

class _HiddenViewState extends State<HiddenView> {
  final UserProfileService _profileService = UserProfileService();
  final PinManagerService _pinManager = PinManagerService();
  
  bool _isUnlocked = false;
  bool _isLoading = true;
  String? _savedHashedPin;
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    try {
      // Migrate old PIN from SharedPreferences if exists
      await _migrateOldPin();
      
      // Load PIN from Firestore
      final hashedPin = await _profileService.getHiddenNotesPin();
      
      if (mounted) {
        setState(() {
          _savedHashedPin = hashedPin;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Migrate old PIN from SharedPreferences to Firestore
  Future<void> _migrateOldPin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldPin = prefs.getString('hidden_notes_pin');
      
      if (oldPin != null && oldPin.isNotEmpty) {
        // Hash the old PIN and save to Firestore
        final hashedPin = _pinManager.hashPin(oldPin);
        await _profileService.setHiddenNotesPin(hashedPin: hashedPin);
        
        // Clear old PIN from SharedPreferences
        await prefs.remove('hidden_notes_pin');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your PIN has been migrated to your profile'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Migration failed, but continue
    }
  }

  Future<void> _setPin(String pin) async {
    try {
      final hashedPin = _pinManager.hashPin(pin);
      await _profileService.setHiddenNotesPin(hashedPin: hashedPin);
      
      setState(() {
        _savedHashedPin = hashedPin;
        _isUnlocked = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error setting PIN: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isLockedOut() {
    if (_lockoutEndTime == null) return false;
    return DateTime.now().isBefore(_lockoutEndTime!);
  }

  int _getRemainingLockoutSeconds() {
    if (!_isLockedOut()) return 0;
    return _lockoutEndTime!.difference(DateTime.now()).inSeconds;
  }

  Future<void> _showPinDialog() async {
    if (_isLockedOut()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Too many failed attempts. Please wait ${_getRemainingLockoutSeconds()} seconds.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pinController = TextEditingController();
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(_savedHashedPin == null ? 'Set PIN for Hidden Notes' : 'Enter PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter 4-6 digit PIN',
                counterText: '',
              ),
            ),
            if (_savedHashedPin == null) ...[
              const SizedBox(height: 8),
              const Text(
                'Choose a secure PIN to protect your hidden notes',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
            if (_failedAttempts > 0 && _savedHashedPin != null) ...[
              const SizedBox(height: 8),
              Text(
                'Failed attempts: $_failedAttempts/3',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final pin = pinController.text;
              
              // Validate PIN
              final errorMessage = _pinManager.getPinErrorMessage(pin);
              if (errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                );
                return;
              }

              if (_savedHashedPin == null) {
                // Setting new PIN
                final strength = _pinManager.getPinStrength(pin);
                if (strength == 'weak') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Weak PIN'),
                      content: const Text(
                        'This PIN is weak and easy to guess. Do you want to use it anyway?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Choose Different PIN'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Use Anyway'),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm != true) return;
                }
                
                await _setPin(pin);
                Navigator.pop(context);
              } else {
                // Verifying PIN
                final hashedPin = _pinManager.hashPin(pin);
                if (hashedPin == _savedHashedPin) {
                  // Correct PIN
                  setState(() {
                    _isUnlocked = true;
                    _failedAttempts = 0;
                  });
                  Navigator.pop(context);
                } else {
                  // Wrong PIN
                  setState(() {
                    _failedAttempts++;
                    if (_failedAttempts >= 3) {
                      _lockoutEndTime = DateTime.now().add(const Duration(seconds: 30));
                      _failedAttempts = 0;
                    }
                  });
                  
                  if (_isLockedOut()) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Too many failed attempts. Locked for 30 seconds.'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Incorrect PIN (${3 - _failedAttempts} attempts left)'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text(_savedHashedPin == null ? 'Set PIN' : 'Unlock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isUnlocked) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Hidden Notes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _savedHashedPin == null 
                ? 'Set a PIN to protect your hidden notes'
                : 'Enter your PIN to view hidden notes',
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showPinDialog,
              icon: Icon(_savedHashedPin == null ? Icons.lock_open : Icons.vpn_key),
              label: Text(_savedHashedPin == null ? 'Set PIN' : 'Unlock'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007AFF),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      );
    }

    // Show hidden notes
    final FirestoreService firestoreService = FirestoreService();
    final FirebaseAuthService authService = FirebaseAuthService();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Please login to view notes'));
    }

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: firestoreService.streamCollection(
        collectionPath: 'notes',
        orderByField: 'createdAt',
        descending: true,
        whereConditions: {'userId': userId},
      ).map((notes) {
        // Filter for hidden, not deleted, and search query
        return notes.where((note) {
          final isHidden = note['isHidden'] == true;
          final isNotDeleted = note['isDeleted'] == false || note['isDeleted'] == null;
          
          // Search filter
          bool matchesSearch = true;
          if (widget.searchQuery.isNotEmpty) {
            final title = (note['title'] ?? '').toString().toLowerCase();
            final content = (note['content'] ?? '').toString().toLowerCase();
            matchesSearch = title.contains(widget.searchQuery) || content.contains(widget.searchQuery);
          }
          
          return isHidden && isNotDeleted && matchesSearch;
        }).toList();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hiddenNotes = snapshot.data ?? [];

        if (hiddenNotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.visibility_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No hidden notes',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isUnlocked = false),
                  icon: const Icon(Icons.lock),
                  label: const Text('Lock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hidden Notes',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _isUnlocked = false),
                    icon: const Icon(Icons.lock, size: 18),
                    label: const Text('Lock'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: hiddenNotes.length,
                itemBuilder: (context, index) {
                  final note = hiddenNotes[index];
                  final createdAt = DateTime.tryParse(note['createdAt'] ?? '');
                  final formattedDate = createdAt != null
                      ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                      : 'Unknown date';

                  return _HiddenNoteCard(
                    note: note,
                    title: note['title'] ?? 'Untitled',
                    description: formattedDate,
                    onTap: () {
                      // Tap to VIEW note
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ViewNoteScreen(note: note)),
                      );
                    },
                    onEdit: () {
                      // Edit button to EDIT note
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EditNoteScreen(note: note)),
                      );
                    },
                    onUnhide: () async {
                      await firestoreService.updateDocument(
                        collectionPath: 'notes',
                        documentId: note['id'],
                        data: {'isHidden': false},
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Note unhidden')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HiddenNoteCard extends StatelessWidget {
  final Map<String, dynamic> note;
  final String title;
  final String description;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onUnhide;

  const _HiddenNoteCard({
    required this.note,
    required this.title,
    required this.description,
    required this.onTap,
    required this.onEdit,
    required this.onUnhide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,  // Tap to open note
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const Icon(Icons.visibility_off, color: Colors.grey, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(description, style: const TextStyle(color: Colors.black54)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit note',
            ),
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: onUnhide,
              tooltip: 'Unhide note',
            ),
          ],
        ),
      ),
    );
  }
}
