import '../models/category.dart';
import 'note_service.dart';

class CategoryService {
  final NoteService _noteService;

  CategoryService(this._noteService);

  Future<List<Category>> getCategories() async {
    final notes = await _noteService.getNotes().first;
    final Map<String, int> categoryCounts = {};

    for (var note in notes) {
      categoryCounts[note.tag] = (categoryCounts[note.tag] ?? 0) + 1;
    }

    return categoryCounts.entries.map((entry) {
      return Category(
        id: entry.key.toLowerCase(),
        name: entry.key,
        noteCount: entry.value,
      );
    }).toList();
  }

  Future<void> addCategory(String name) async {
    // Categories are auto-generated from notes
    // In a real app, you might want to manage categories separately
  }
}

