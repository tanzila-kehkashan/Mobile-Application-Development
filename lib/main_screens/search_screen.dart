import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import 'events_subscreens/event_details_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final popularSearchesAsync = ref.watch(popularSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode:  _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search events.. .',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF5B4EFF)),
            onPressed: () => _showFiltersDialog(),
          ),
        ],
      ),
      body: searchQuery.isEmpty
          ? _buildEmptySearchState(popularSearchesAsync)
          : _buildSearchResults(searchResultsAsync),
    );
  }

  Widget _buildEmptySearchState(AsyncValue<List<Map<String, dynamic>>> popularSearchesAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height:  16),
          popularSearchesAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    'No popular events',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return Column(
                children: events.map((event) => _buildEventCard(event)).toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF5B4EFF)),
            ),
            error:  (_, __) => const SizedBox. shrink(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight. bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRecentSearchChip('Music'),
              _buildRecentSearchChip('Food Festival'),
              _buildRecentSearchChip('Art Gallery'),
              _buildRecentSearchChip('Sports'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<Map<String, dynamic>>> searchResultsAsync) {
    return searchResultsAsync.when(
      data: (events) {
        if (events. isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  'No events found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with different keywords',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: events.length,
          itemBuilder: (context, index) {
            return _buildEventCard(events[index]);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5B4EFF)),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error loading results',
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final backgroundColor = _getColorForCategory(event['category'] ?? 'Music');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(eventId: event['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow:  [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Event Image
            Container(
              width:  80,
              height: 100,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  size: 40,
                  color:  Colors.white. withOpacity(0.5),
                ),
              ),
            ),
            // Event Details
            Expanded(
              child:  Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event['day']} ${event['month']}, ${event['startTime'] ?? ''}',
                      style: const TextStyle(
                        fontSize:  12,
                        color: Color(0xFF5B4EFF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['title'] ?? 'Event Title',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height:  8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width:  4),
                        Expanded(
                          child: Text(
                            event['location'] ?? 'Location',
                            style: const TextStyle(fontSize: 12, color: Colors. grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearchChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _onSearchChanged(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize:  14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context:  context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: ['All', 'Music', 'Sports', 'Food', 'Art']. map((cat) {
                return ChoiceChip(
                  label: Text(cat),
                  selected: false,
                  onSelected: (selected) {
                    ref.read(searchFiltersProvider.notifier).setCategory(cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B4EFF),
                minimumSize: const Size(double.infinity, 48),
              ),
              child:  const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category. toLowerCase()) {
      case 'sports':
        return const Color(0xFFFF6B6B);
      case 'music':
        return const Color(0xFFFF9B57);
      case 'food':
        return const Color(0xFF4CAF50);
      case 'art':
        return const Color(0xFF9C27B0);
      case 'clubbing':
        return const Color(0xFF00D9A5);
      case 'theater':
        return const Color(0xFF5B4EFF);
      default:
        return Colors.pink[100]!;
    }
  }
}