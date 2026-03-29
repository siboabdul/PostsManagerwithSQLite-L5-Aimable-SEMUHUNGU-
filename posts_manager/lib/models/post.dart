class Post {
  int? id;
  String title;
  String body;
  String date;
  String? imagePath;

  Post({
    this.id,
    required this.title,
    required this.body,
    required this.date,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date,
      'imagePath': imagePath,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      date: map['date'],
      imagePath: map['imagePath'],
    );
  }
}
