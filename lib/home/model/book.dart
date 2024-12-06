class Book {
  final int id;
  final String title;
  final String pdfPath;
  final String image;
  final String categoryName;
  final int categoryId;

  Book({
    required this.id,
    required this.title,
    required this.pdfPath,
    required this.image,
    required this.categoryName,
    required this.categoryId,
  });

  // Factory method to create a Book instance from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['book_name'],
      pdfPath: json['pdf'] ?? "",
      image: json['main_image'] ?? "",
      categoryName: json['category']['category_name'] ?? "Unknown",
      categoryId : json['category_id'],
    );
  }
}

