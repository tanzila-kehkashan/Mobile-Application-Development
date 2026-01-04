import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/search_service.dart';

// Search service provider
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

// ✅ CONVERTED:  Search query state using NotifierProvider
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier. new,
);

// Search results provider
final searchResultsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final searchService = ref.watch(searchServiceProvider);

  if (query.trim().isEmpty) {
    return Stream.value([]);
  }

  return searchService.searchEventsByTitle(query);
});

// Search suggestions provider
final searchSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final searchService = ref.watch(searchServiceProvider);

  if (query.trim().isEmpty) {
    return [];
  }

  return searchService.getSearchSuggestions(query);
});

// Popular searches provider
final popularSearchesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final searchService = ref. watch(searchServiceProvider);
  return searchService.getPopularSearches();
});

// Search filters state
class SearchFilters {
  final String?  category;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minPrice;
  final double? maxPrice;

  SearchFilters({
    this.category,
    this.startDate,
    this. endDate,
    this.minPrice,
    this.maxPrice,
  });

  SearchFilters copyWith({
    String?  category,
    DateTime? startDate,
    DateTime? endDate,
    double? minPrice,
    double? maxPrice,
  }) {
    return SearchFilters(
      category: category ??  this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minPrice: minPrice ?? this. minPrice,
      maxPrice:  maxPrice ?? this.maxPrice,
    );
  }
}

// Search filters notifier
class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() => SearchFilters();

  void setCategory(String?  category) {
    state = state.copyWith(category: category);
  }

  void setDateRange(DateTime? start, DateTime?  end) {
    state = SearchFilters(
      category: state.category,
      startDate: start,
      endDate: end,
      minPrice: state. minPrice,
      maxPrice:  state.maxPrice,
    );
  }

  void setPriceRange(double? min, double? max) {
    state = SearchFilters(
      category:  state.category,
      startDate: state.startDate,
      endDate: state.endDate,
      minPrice: min,
      maxPrice: max,
    );
  }

  void reset() {
    state = SearchFilters();
  }
}

final searchFiltersProvider = NotifierProvider<SearchFiltersNotifier, SearchFilters>(
  SearchFiltersNotifier. new,
);

// Filtered search results provider
final filteredSearchResultsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final filters = ref.watch(searchFiltersProvider);
  final searchService = ref.watch(searchServiceProvider);

  if (query.trim().isEmpty) {
    return Stream.value([]);
  }

  return searchService. searchEventsWithFilters(
    query: query,
    category: filters.category,
    startDate: filters.startDate,
    endDate: filters.endDate,
    minPrice: filters. minPrice,
    maxPrice:  filters.maxPrice,
  );
});