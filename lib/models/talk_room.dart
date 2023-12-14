class TalkRoom {
  const TalkRoom({
    this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
  });

  final String? id;
  final String name;
  final String userId;
  final DateTime createdAt;

  // fromJsonメソッド
  factory TalkRoom.fromJson(dynamic json) {
    return TalkRoom(
      id: json['room_id'] as String,
      name: json['room_name'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // toJsonメソッド
  Map<String, dynamic> toJson() {
    return {
      'room_id': id,
      'room_name': name,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}