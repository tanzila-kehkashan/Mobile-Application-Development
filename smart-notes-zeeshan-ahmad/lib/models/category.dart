class Category {
  final String id;
  final String name;
  final int noteCount;

  Category({
    required this.id,
    required this.name,
    required this.noteCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'noteCount': noteCount,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      noteCount: json['noteCount'],
    );
  }
}

