import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/app_localizations.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/settings_service.dart';
import '../widgets/custom_drawer.dart';

class MyNotesScreen extends StatefulWidget {
  const MyNotesScreen({super.key});

  @override
  State<MyNotesScreen> createState() => _MyNotesScreenState();
}

class _MyNotesScreenState extends State<MyNotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsService>(context);
    final localizations = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Determine header color based on mode
    final headerColor = settings.isColorBlindMode 
        ? AppColors.yellow 
        : AppColors.primaryBlue;
    final headerTextColor = settings.isColorBlindMode ? Colors.black : Colors.white;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.menu, color: headerTextColor),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.notifications_outlined,
                                  color: headerTextColor),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        localizations?.translate('my_notes') ?? 'My Notes',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: headerTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkGray : Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: settings.isColorBlindMode 
                            ? Border.all(color: Colors.black, width: 2) 
                            : null,
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: localizations?.translate('search_notes') ?? 'Search notes...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                          border: InputBorder.none,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: Icon(
                              Icons.clear, 
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Note>>(
                  stream: context.read<NoteService>().getNotes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          '${localizations?.translate('error') ?? 'Error'}: ${snapshot.error}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      );
                    }

                    final notes = snapshot.data ?? [];
                    final filteredNotes = _searchQuery.isEmpty
                        ? notes
                        : notes.where((note) {
                      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          note.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          note.tag.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    return _buildNotesList(filteredNotes, theme, settings, localizations);
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/new-note');
              },
              backgroundColor: settings.isColorBlindMode ? AppColors.yellow : AppColors.primaryBlue,
              child: Icon(
                Icons.add, 
                color: settings.isColorBlindMode ? Colors.black : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(
    List<Note> notes, 
    ThemeData theme, 
    SettingsService settings, 
    AppLocalizations? localizations
  ) {
    final isDark = theme.brightness == Brightness.dark;
    
    if (notes.isEmpty) {
      return Center(
        child: Text(
          localizations?.translate('no_notes_found') ?? 'No notes found',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(note, theme, settings);
      },
    );
  }

  Widget _buildNoteCard(Note note, ThemeData theme, SettingsService settings) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: settings.isColorBlindMode 
            ? const BorderSide(color: Colors.black, width: 2) 
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/note-details',
            arguments: note.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.note_outlined,
                color: settings.isColorBlindMode ? Colors.black : theme.colorScheme.primary,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.content.length > 50
                          ? '${note.content.substring(0, 50)}...'
                          : note.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: settings.isColorBlindMode 
                                ? AppColors.yellow.withOpacity(0.3) 
                                : (isDark ? theme.colorScheme.primary.withOpacity(0.2) : AppColors.lightBlue),
                            borderRadius: BorderRadius.circular(12),
                            border: settings.isColorBlindMode 
                                ? Border.all(color: Colors.black, width: 1) 
                                : null,
                          ),
                          child: Text(
                            note.tag,
                            style: TextStyle(
                              fontSize: 12,
                              color: settings.isColorBlindMode ? Colors.black : (isDark ? Colors.white : AppColors.primaryBlue),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _getTimeAgo(note.lastEdited ?? note.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}