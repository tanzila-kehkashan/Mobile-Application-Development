import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../services/firebase_auth_service.dart';
import '../notes/home_notes_screen.dart';
import '../../search_screen.dart';
import '../create_note_screen.dart';
import '../edit_note_screen.dart';
import '../view_note_screen.dart';

class EventViewScreen extends StatefulWidget {
  const EventViewScreen({Key? key}) : super(key: key);

  @override
  State<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends State<EventViewScreen> {
  DateTime _selectedDate = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  // Start in the middle of the list (index 5000) to allow scrolling both ways
  // 68.0 is the estimated width of each item (60 width + 8 margin)
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 5000 * 68.0);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    const Color blue = Color(0xFF007AFF);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: blue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      // Scroll to the selected date
      // We use the same anchor (DateTime.now()) as the ListView builder
      final now = DateTime.now();
      
      // Calculate difference in days to find the index
      // Normalize to midnight to avoid time discrepancies
      final todayMidnight = DateTime(now.year, now.month, now.day);
      final pickedMidnight = DateTime(picked.year, picked.month, picked.day);
      final dayDiff = pickedMidnight.difference(todayMidnight).inDays;
      
      // Calculate target index (center is 5000)
      final targetIndex = 5000 + dayDiff;
      
      // Calculate offset to center the item
      // Item width is 60 + 8 margin = 68.0
      final screenWidth = MediaQuery.of(context).size.width;
      final itemWidth = 68.0;
      final offset = (targetIndex * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    const Color blue = Color(0xFF007AFF);
    final userId = _authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: const Center(child: Text('Please login to view events')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined, color: Colors.black87),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Date Selector (Horizontal Scroll) with Note Indicators
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firestoreService.streamCollection(
                collectionPath: 'notes',
                whereConditions: {'userId': userId},
              ),
              builder: (context, notesSnapshot) {
                final allNotes = notesSnapshot.data ?? [];
                
                // Get set of dates that have notes
                final datesWithNotes = <String>{};
                for (var note in allNotes) {
                  final noteDate = note['selectedDate'] as String?;
                  if (noteDate != null) {
                    final parsedDate = DateTime.tryParse(noteDate);
                    if (parsedDate != null &&
                        (note['isDeleted'] == false || note['isDeleted'] == null) &&
                        (note['isHidden'] == false || note['isHidden'] == null)) {
                      datesWithNotes.add(_formatDate(parsedDate));
                    }
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 100, // Increased height for month
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: 10000, // Large number to simulate infinite scroll
                      itemBuilder: (context, index) {
                        // index 5000 is "today"
                        final date = DateTime.now().add(Duration(days: index - 5000));
                        final bool isSelected =
                            date.year == _selectedDate.year &&
                                date.month == _selectedDate.month &&
                                date.day == _selectedDate.day;
                        final bool hasNotes = datesWithNotes.contains(_formatDate(date));

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          child: Container(
                            width: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? blue : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? blue : Colors.grey.shade300,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _monthAbbr(date.month),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white70 : Colors.black45,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _weekdayAbbr(date.weekday),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${date.day}',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasNotes)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: isSelected ? Colors.white : blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            // Notes for Selected Date
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.streamCollection(
                  collectionPath: 'notes',
                  orderByField: 'createdAt',
                  descending: true,
                  whereConditions: {'userId': userId},
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allNotes = snapshot.data ?? [];
                  
                  // Filter notes for selected date
                  final selectedDateStr = _formatDate(_selectedDate);
                  final dateNotes = allNotes.where((note) {
                    final noteDate = note['selectedDate'] as String?;
                    if (noteDate == null) return false;
                    
                    final parsedNoteDate = DateTime.tryParse(noteDate);
                    if (parsedNoteDate == null) return false;
                    
                    final noteDateStr = _formatDate(parsedNoteDate);
                    
                    return noteDateStr == selectedDateStr &&
                           (note['isDeleted'] == false || note['isDeleted'] == null) &&
                           (note['isHidden'] == false || note['isHidden'] == null);
                  }).toList();

                  if (dateNotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No notes for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Create a note with this date to see it here',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dateNotes.length,
                    itemBuilder: (context, index) {
                      final note = dateNotes[index];
                      final isFavourite = note['isFavourite'] == true;

                      return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: blue),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () {
                        // Tap to VIEW note
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewNoteScreen(note: note),
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.all(16),
                      leading: isFavourite
                          ? const Icon(Icons.star, color: Colors.amber, size: 28)
                          : const Icon(Icons.event_note, color: blue, size: 28),
                      title: Text(
                        note['title'] ?? 'Untitled',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Tap to view',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: blue, size: 20),
                            onPressed: () {
                              // Edit button to EDIT note
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditNoteScreen(note: note),
                                ),
                              );
                            },
                            tooltip: 'Edit note',
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeNotesScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note_outlined), label: 'Notes'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Create'),
        ],
      ),
    );
  }

  String _weekdayAbbr(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[weekday - 1];
  }

  String _monthAbbr(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}