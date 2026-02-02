import 'package:flutter/material.dart';
import 'package:momentum/features/home/presentation/screens/home_screen.dart';
import 'package:momentum/features/home/presentation/screens/progress_screen.dart';
import 'package:momentum/features/profile/presentation/screens/profile_screen.dart';
import 'package:momentum/features/workouts/presentation/screens/workouts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    WorkoutsScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51), // 0.2 * 255 = 51
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
            _buildNavItem(Icons.fitness_center_outlined, Icons.fitness_center, 'Workouts', 1),
            _buildNavItem(Icons.show_chart_outlined, Icons.show_chart, 'Progress', 2),
            _buildNavItem(Icons.person_outline, Icons.person, 'Profile', 3),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFE8FF78),
          unselectedItemColor: Colors.white54,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFF4A3D7E),
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 8 : 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8FF78).withAlpha(51) : Colors.transparent, // 0.2 * 255 = 51
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(isSelected ? selectedIcon : unselectedIcon),
      ),
      label: label,
    );
  }
}
