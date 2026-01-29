import 'package:flutter/material.dart';
import '../event/event_view_screen.dart';
import '../profile/profile_screen.dart';
import 'package:figma_to_flutter_app/search_screen.dart';
import '../create_note_screen.dart';
import 'all_notes_view.dart';
import 'favourites_view.dart';
import 'hidden_view.dart';
import 'trash_view.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/page_transitions.dart';

class HomeNotesScreen extends StatefulWidget {
  const HomeNotesScreen({Key? key}) : super(key: key);

  @override
  State<HomeNotesScreen> createState() => _HomeNotesScreenState();
}

enum NotesTab { all, favourites, hidden, trash }

class _HomeNotesScreenState extends State<HomeNotesScreen> {
  NotesTab? _selectedTab;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _getActiveView() {
    switch (_selectedTab) {
      case NotesTab.favourites:
        return FavouritesView(searchQuery: _searchQuery);
      case NotesTab.hidden:
        return HiddenView(searchQuery: _searchQuery);
      case NotesTab.trash:
        return TrashView(searchQuery: _searchQuery);
      case NotesTab.all:
      default:
        return AllNotesView(searchQuery: _searchQuery);
    }
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM(context),
            vertical: AppSizes.paddingS(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatCurrentDate(),
                        style: TextStyle(
                          fontSize: AppSizes.fontXS(context),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: AppSizes.spaceXS(context)),
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: AppSizes.fontXXL(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      size: AppSizes.iconL(context),
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        FadeSlidePageRoute(page: const ProfileScreen()),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: AppSizes.spaceM(context)),

              // Search Field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(fontSize: AppSizes.fontM(context)),
                  prefixIcon: Icon(Icons.search, size: AppSizes.iconM(context)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM(context),
                    vertical: AppSizes.paddingS(context),
                  ),
                ),
              ),

              SizedBox(height: AppSizes.spaceM(context)),

              // Tabs - Responsive
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab("All Notes", NotesTab.all, context),
                    SizedBox(width: AppSizes.spaceS(context)),
                    _buildTab("Favourites", NotesTab.favourites, context),
                    SizedBox(width: AppSizes.spaceS(context)),
                    _buildTab("Hidden", NotesTab.hidden, context),
                    SizedBox(width: AppSizes.spaceS(context)),
                    _buildTab("Trash", NotesTab.trash, context),
                  ],
                ),
              ),

              SizedBox(height: AppSizes.spaceL(context)),

              Expanded(child: _getActiveView()),
            ],
          ),
        ),
      ),

      // Bottom Navigation with responsive sizing
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: selectedColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: AppSizes.fontXS(context),
        unselectedFontSize: AppSizes.fontXS(context),
        iconSize: AppSizes.iconM(context),
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              FadeSlidePageRoute(page: const EventViewScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              FadeSlidePageRoute(page: const SearchScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              FadeSlidePageRoute(page: const CreateNoteScreen()),
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

  Widget _buildTab(String label, NotesTab tab, BuildContext context) {
    final bool isSelected = _selectedTab == tab;
    const Color selectedColor = Color(0xFF007AFF);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM(context),
          vertical: AppSizes.paddingS(context),
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(AppSizes.radiusL(context)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: AppSizes.fontS(context),
          ),
        ),
      ),
    );
  }
}
