class SportEvent {
  final String id;
  final String title;
  final String description;
  final String sport;
  final String location;
  final String imageUrl;
  final DateTime startAt;
  final DateTime endAt;
  final int capacity;
  final int registeredCount;
  final bool active;
  final String createdBy;

  const SportEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.sport,
    required this.location,
    required this.imageUrl,
    required this.startAt,
    required this.endAt,
    required this.capacity,
    required this.registeredCount,
    required this.active,
    required this.createdBy,
  });

  bool get isFull => registeredCount >= capacity;

  SportEvent copyWith({String? id, int? registeredCount}) => SportEvent(
    id: id ?? this.id,
    title: title,
    description: description,
    sport: sport,
    location: location,
    imageUrl: imageUrl,
    startAt: startAt,
    endAt: endAt,
    capacity: capacity,
    registeredCount: registeredCount ?? this.registeredCount,
    active: active,
    createdBy: createdBy,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'description': description,
    'sport': sport,
    'location': location,
    'imageUrl': imageUrl,
    'startAt': startAt,
    'endAt': endAt,
    'capacity': capacity,
    'registeredCount': registeredCount,
    'isActive': active,
    'createdBy': createdBy,
  };

  factory SportEvent.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) {
    final now = DateTime.now();
    return SportEvent(
      id: _string(json['_id'], fallbackId),
      title: _string(json['title'], 'Sự kiện thể thao'),
      description: _string(json['description'], ''),
      sport: _string(json['sport'], 'Cầu lông'),
      location: _string(json['location'], ''),
      imageUrl: _string(json['imageUrl'], ''),
      startAt: _date(json['startAt']) ?? now,
      endAt: _date(json['endAt']) ?? now.add(const Duration(hours: 2)),
      capacity: _integer(json['capacity'], 1),
      registeredCount: _integer(json['registeredCount'], 0),
      active: json['isActive'] != false,
      createdBy: _string(json['createdBy'], ''),
    );
  }
}

class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String phone;
  final String status;
  final DateTime registeredAt;

  const EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.phone,
    required this.status,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'eventId': eventId,
    'userId': userId,
    'userName': userName,
    'phone': phone,
    'status': status,
    'registeredAt': registeredAt,
  };
}

class MatchmakingRoom {
  final String id;
  final String title;
  final String sport;
  final String venueName;
  final DateTime playAt;
  final String skillLevel;
  final int maxMembers;
  final int memberCount;
  final String createdBy;
  final String creatorName;
  final String description;
  final String status;

  const MatchmakingRoom({
    required this.id,
    required this.title,
    required this.sport,
    required this.venueName,
    required this.playAt,
    required this.skillLevel,
    required this.maxMembers,
    required this.memberCount,
    required this.createdBy,
    required this.creatorName,
    required this.description,
    required this.status,
  });

  bool get isFull => memberCount >= maxMembers;
  bool get isOpen => status == 'open' && playAt.isAfter(DateTime.now());

  MatchmakingRoom copyWith({String? id, int? memberCount}) => MatchmakingRoom(
    id: id ?? this.id,
    title: title,
    sport: sport,
    venueName: venueName,
    playAt: playAt,
    skillLevel: skillLevel,
    maxMembers: maxMembers,
    memberCount: memberCount ?? this.memberCount,
    createdBy: createdBy,
    creatorName: creatorName,
    description: description,
    status: status,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'sport': sport,
    'venueName': venueName,
    'playAt': playAt,
    'skillLevel': skillLevel,
    'maxMembers': maxMembers,
    'memberCount': memberCount,
    'createdBy': createdBy,
    'creatorName': creatorName,
    'description': description,
    'status': status,
  };

  factory MatchmakingRoom.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) => MatchmakingRoom(
    id: _string(json['_id'], fallbackId),
    title: _string(json['title'], 'Phòng ghép cầu lông'),
    sport: _string(json['sport'], 'Cầu lông'),
    venueName: _string(json['venueName'], ''),
    playAt: _date(json['playAt']) ?? DateTime.now(),
    skillLevel: _string(json['skillLevel'], 'Mọi trình độ'),
    maxMembers: _integer(json['maxMembers'], 4),
    memberCount: _integer(json['memberCount'], 1),
    createdBy: _string(json['createdBy'], ''),
    creatorName: _string(json['creatorName'], ''),
    description: _string(json['description'], ''),
    status: _string(json['status'], 'open'),
  );
}

class MatchmakingMember {
  final String id;
  final String roomId;
  final String userId;
  final String userName;
  final String phone;
  final DateTime joinedAt;

  const MatchmakingMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.phone,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'roomId': roomId,
    'userId': userId,
    'userName': userName,
    'phone': phone,
    'joinedAt': joinedAt,
  };

  factory MatchmakingMember.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) => MatchmakingMember(
    id: _string(json['_id'], fallbackId),
    roomId: _string(json['roomId'], ''),
    userId: _string(json['userId'], ''),
    userName: _string(json['userName'], 'Người chơi'),
    phone: _string(json['phone'], ''),
    joinedAt: _date(json['joinedAt']) ?? DateTime.now(),
  );
}

String _string(Object? value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _integer(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  try {
    final dynamic timestamp = value;
    final result = timestamp.toDate();
    return result is DateTime ? result : null;
  } catch (_) {
    return null;
  }
}
