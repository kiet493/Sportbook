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
  final String creatorName;
  final String venueId;
  final String fieldId;
  final String courtName;
  final String bookingId;
  final int dailyStartMinutes;
  final int dailyEndMinutes;
  final DateTime deadline;
  final int minPlayers;
  final String playerLevel;
  final String playStyle;
  final String teamPreference;
  final String status;
  final int estimatedPrice;
  final int hourlyRate;
  final int totalDurationMinutes;
  final String paymentStatus;

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
    this.creatorName = '',
    this.venueId = '',
    this.fieldId = '',
    this.courtName = '',
    this.bookingId = '',
    this.dailyStartMinutes = 0,
    this.dailyEndMinutes = 0,
    DateTime? deadline,
    this.minPlayers = 1,
    this.playerLevel = '',
    this.playStyle = '',
    this.teamPreference = '',
    this.status = 'open',
    this.estimatedPrice = 0,
    this.hourlyRate = 50000,
    this.totalDurationMinutes = 0,
    this.paymentStatus = 'unpaid',
  }) : deadline = deadline ?? startAt;

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
    creatorName: creatorName,
    venueId: venueId,
    fieldId: fieldId,
    courtName: courtName,
    bookingId: bookingId,
    dailyStartMinutes: dailyStartMinutes,
    dailyEndMinutes: dailyEndMinutes,
    deadline: deadline,
    minPlayers: minPlayers,
    playerLevel: playerLevel,
    playStyle: playStyle,
    teamPreference: teamPreference,
    status: status,
    estimatedPrice: estimatedPrice,
    hourlyRate: hourlyRate,
    totalDurationMinutes: totalDurationMinutes,
    paymentStatus: paymentStatus,
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
    'creatorName': creatorName,
    'venueId': venueId,
    'fieldId': fieldId,
    'courtName': courtName,
    'bookingId': bookingId,
    'dailyStartMinutes': dailyStartMinutes,
    'dailyEndMinutes': dailyEndMinutes,
    'deadline': deadline,
    'minPlayers': minPlayers,
    'maxPlayers': capacity,
    'availableSlots': (capacity - registeredCount).clamp(0, capacity),
    'playerLevel': playerLevel,
    'playStyle': playStyle,
    'teamPreference': teamPreference,
    'status': status,
    'estimatedPrice': estimatedPrice,
    'hourlyRate': hourlyRate,
    'totalDurationMinutes': totalDurationMinutes,
    'paymentStatus': paymentStatus,
  };

  factory SportEvent.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) {
    final now = DateTime.now();
    return SportEvent(
      id: _string(json['_id'], fallbackId),
      title: _string(json['title'] ?? json['name'], 'Sự kiện thể thao'),
      description: _string(json['description'], ''),
      sport: _string(
        json['sport'] ?? json['sportType'] ?? json['type'],
        'Cầu lông',
      ),
      location: _string(json['location'], ''),
      imageUrl: _string(json['imageUrl'], ''),
      startAt: _date(json['startAt'] ?? json['startTime']) ?? now,
      endAt:
          _date(json['endAt'] ?? json['endTime']) ??
          now.add(const Duration(hours: 2)),
      capacity: _integer(
        json['capacity'] ?? json['maxParticipants'] ?? json['maxPlayers'],
        1,
      ),
      registeredCount: _integer(
        json['registeredCount'] ??
            json['participantCount'] ??
            json['participants'],
        _registeredFromAvailableSlots(json),
      ),
      active: _eventIsActive(json),
      createdBy: _string(json['createdBy'], ''),
      creatorName: _string(
        json['creatorName'] ??
            json['createdByName'] ??
            json['organizerName'] ??
            json['ownerName'],
        '',
      ),
      venueId: _string(json['venueId'], ''),
      fieldId: _string(json['fieldId'], ''),
      courtName: _string(json['courtName'], ''),
      bookingId: _string(json['bookingId'], ''),
      dailyStartMinutes: _integer(json['dailyStartMinutes'], 0),
      dailyEndMinutes: _integer(json['dailyEndMinutes'], 0),
      deadline: _date(json['deadline']) ?? now,
      minPlayers: _integer(json['minPlayers'], 1),
      playerLevel: _string(json['playerLevel'], ''),
      playStyle: _string(json['playStyle'], ''),
      teamPreference: _string(json['teamPreference'], ''),
      status: _string(json['status'], 'open'),
      estimatedPrice: _integer(json['estimatedPrice'], 0),
      hourlyRate: _integer(json['hourlyRate'], 50000),
      totalDurationMinutes: _integer(json['totalDurationMinutes'], 0),
      paymentStatus: _string(json['paymentStatus'], 'unpaid'),
    );
  }
}

bool _eventIsActive(Map<String, dynamic> json) {
  if (json['isActive'] is bool) return json['isActive'] as bool;
  final status = json['status']?.toString().trim().toLowerCase();
  return status != 'cancelled' &&
      status != 'canceled' &&
      status != 'closed' &&
      status != 'completed';
}

int _registeredFromAvailableSlots(Map<String, dynamic> json) {
  final capacity = _integer(
    json['capacity'] ?? json['maxParticipants'] ?? json['maxPlayers'],
    1,
  );
  final available = _integer(json['availableSlots'], capacity);
  return (capacity - available).clamp(0, capacity).toInt();
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
  final String bookingId;
  final String venueId;
  final String courtId;
  final String courtName;
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
    this.bookingId = '',
    this.venueId = '',
    this.courtId = '',
    this.courtName = '',
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
    bookingId: bookingId,
    venueId: venueId,
    courtId: courtId,
    courtName: courtName,
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
    'bookingId': bookingId,
    'venueId': venueId,
    'fieldId': courtId,
    'courtId': courtId,
    'courtName': courtName,
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
    bookingId: _string(json['bookingId'], ''),
    venueId: _string(json['venueId'], ''),
    courtId: _string(json['fieldId'] ?? json['courtId'], ''),
    courtName: _string(json['courtName'], ''),
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
  final String status;

  const MatchmakingMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.phone,
    required this.joinedAt,
    this.status = 'approved',
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'roomId': roomId,
    'userId': userId,
    'userName': userName,
    'phone': phone,
    'joinedAt': joinedAt,
    'status': status,
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
    status: _string(json['status'], 'approved'),
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
