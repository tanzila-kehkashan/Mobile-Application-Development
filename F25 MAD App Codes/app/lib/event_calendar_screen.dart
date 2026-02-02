import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexus/services/firestore_service.dart';
import 'package:nexus/models/event_model.dart';
import 'package:nexus/utils/page_transitions.dart';
import 'notification_screen.dart';
import 'event_details_screen.dart';
import 'create_event_screen.dart';

// Custom colors derived from the Figma design
const Color _backgroundColor = Color(0xFFEBE3E3);
const Color _cardColor = Color(0xFFDCDCDC);
const Color _foregroundColor = Colors.black87;
const Color _highlightColor = Color(0xFFF9D87E);
const Color _orangeHighlightColor = Color(0xFFF09A51);
const Color _upcomingEventsColor = Color(0xFF8B77AA);

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _getMonthName(int month) {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  void _onLeftArrowTap() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
    });
  }

  void _onRightArrowTap() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
    });
  }

  Widget _buildDateCell(int? date, {bool isToday = false, bool isSelected = false, bool hasEvent = false}) {
    if (date == null) return const SizedBox();

    Color? bgColor;
    if (isSelected) {
      bgColor = _highlightColor;
    } else if (isToday) {
      bgColor = _orangeHighlightColor;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = DateTime(_focusedDay.year, _focusedDay.month, date);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$date',
              style: const TextStyle(
                color: _foregroundColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasEvent)
              Positioned(
                bottom: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: _upcomingEventsColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int year = _focusedDay.year;
    final int month = _focusedDay.month;
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int firstWeekday = DateTime(year, month, 1).weekday;
    final int offset = firstWeekday - 1;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _foregroundColor, size: 30),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Event Calendar',
          style: TextStyle(
            color: _foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: _foregroundColor, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const NotificationScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _firestoreService.eventsForMonthStream(year, month),
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];
          
          // Get dates that have events
          final eventDates = events.map((e) => e.eventDate.day).toSet();
          
          // Filter events for selected day
          final selectedDayEvents = _selectedDay != null
              ? events.where((e) => e.isOnDate(_selectedDay!)).toList()
              : <EventModel>[];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(28, 8, 28, 20),
                  child: Text(
                    'Organised by Department',
                    style: TextStyle(
                      color: _foregroundColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Calendar Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: _foregroundColor, size: 30),
                        onPressed: _onLeftArrowTap,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.70,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              spreadRadius: 0,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_getMonthName(month)} $year',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _foregroundColor,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Mo', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Tu', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('We', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Th', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Fr', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Sa', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text('Su', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 15),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: offset + daysInMonth,
                              itemBuilder: (context, index) {
                                if (index < offset) return _buildDateCell(null);
                                final int date = index - offset + 1;

                                final bool isSelected = _selectedDay != null &&
                                    _selectedDay!.day == date &&
                                    _selectedDay!.month == month &&
                                    _selectedDay!.year == year;

                                final DateTime now = DateTime.now();
                                final bool isToday = now.day == date &&
                                    now.month == month &&
                                    now.year == year;
                                
                                final bool hasEvent = eventDates.contains(date);

                                return _buildDateCell(
                                  date,
                                  isToday: isToday,
                                  isSelected: isSelected,
                                  hasEvent: hasEvent,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: _foregroundColor, size: 30),
                        onPressed: _onRightArrowTap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Upcoming Events Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 200,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _upcomingEventsColor,
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Upcoming Events',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _upcomingEventsColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      if (_selectedDay == null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            'Select a date to view events.',
                            style: TextStyle(
                              color: _foregroundColor,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else if (selectedDayEvents.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'No events on ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                            style: const TextStyle(
                              color: _foregroundColor,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        ...selectedDayEvents.map((event) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              SlidePageRoute(page: EventDetailsScreen(event: event)),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _cardColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  spreadRadius: 0,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: const TextStyle(
                                          color: _foregroundColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (event.department != null)
                                        Text(
                                          event.department!,
                                          style: TextStyle(
                                            color: _foregroundColor.withValues(alpha: 0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16, color: _foregroundColor),
                              ],
                            ),
                          ),
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            Navigator.push(
              context,
              SlideUpPageRoute(
                page: CreateEventScreen(
                  initialDate: _selectedDay ?? DateTime.now(),
                ),
              ),
            );
          }
        },
        backgroundColor: _upcomingEventsColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
