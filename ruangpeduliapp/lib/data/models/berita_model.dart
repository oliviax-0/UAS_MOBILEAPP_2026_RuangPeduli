class BeritaModel {
  final int? id;
  final String title;
  final String content;
  final String thumbnail;
  final String authorName;
  final String pantiName;
  final int panti;
  final String? pantiProfilePicture;
  final String createdAt;
  final int upvoteCount;
  final int downvoteCount;

  BeritaModel({
    this.id,
    required this.title,
    required this.content,
    required this.thumbnail,
    required this.authorName,
    required this.pantiName,
    required this.panti,
    this.pantiProfilePicture,
    required this.createdAt,
    required this.upvoteCount,
    required this.downvoteCount,
  });

  /// Create BeritaModel from JSON
  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      content: json['content'] as String,
      thumbnail: json['thumbnail'] as String,
      authorName: json['author_name'] as String,
      pantiName: json['panti_name'] as String,
      panti: json['panti'] as int,
      pantiProfilePicture: json['panti_profile_picture'] as String?,
      createdAt: json['created_at'] as String,
      upvoteCount: json['upvote_count'] as int,
      downvoteCount: json['downvote_count'] as int,
    );
  }

  /// Convert BeritaModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'thumbnail': thumbnail,
      'author_name': authorName,
      'panti_name': pantiName,
      'panti': panti,
      'panti_profile_picture': pantiProfilePicture,
      'created_at': createdAt,
      'upvote_count': upvoteCount,
      'downvote_count': downvoteCount,
    };
  }
}
