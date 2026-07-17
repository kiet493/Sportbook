import 'package:flutter/material.dart';

import 'venue.dart';

class CourtSlotStatus {
  static const String booked = 'booked';
  static const String blocked = 'blocked';
  static const String event = 'event';
  static const String cancelled = 'cancelled';

  static const List<String> activeStatuses = [booked, blocked, event];

  static String label(String status) {
    switch (status) {
      case blocked:
        return 'Khoa';
      case event:
        return 'Su kien';
      case cancelled:
        return 'Da huy';
      case booked:
      default:
        return 'Da dat';
    }
  }

  static Color color(String status) {
    switch (status) {
      case blocked:
        return const Color(0xFF9CA3AF);
      case event:
        return const Color(0xFFC084FC);
      case cancelled:
        return const Color(0xFFE5E7EB);
      case booked:
      default:
        return const Color(0xFFEF4444);
    }
  }
}

class ManagedVenue {
  final String id;
  final String name;
  final List<String> sports;
  final String address;
  final String hours;
  final int pricePerHour;
  final bool active;
  final String image;
  final List<String> images;
  final String description;
  final String coordinates;
  final String ownerId;

  const ManagedVenue({
    required this.id,
    required this.name,
    required this.sports,
    required this.address,
    required this.hours,
    required this.pricePerHour,
    required this.active,
    required this.image,
    required this.images,
    required this.description,
    required this.coordinates,
    required this.ownerId,
  });

  factory ManagedVenue.fromLegacy(Venue venue) {
    return ManagedVenue(
      id: venue.firestoreId,
      name: venue.name,
      sports: venue.sport,
      address: venue.address,
      hours: venue.hours,
      pricePerHour: venue.priceNum,
      active: venue.available,
      image: venue.image,
      images: venue.images,
      description: venue.description,
      coordinates: '',
      ownerId: '',
    );
  }

  factory ManagedVenue.empty() => const ManagedVenue(
    id: '',
    name: '',
    sports: ['Cầu lông'],
    address: '',
    hours: '06:00 - 22:00',
    pricePerHour: 180000,
    active: true,
    image: '',
    images: [],
    description: '',
    coordinates: '',
    ownerId: '',
  );

  ManagedVenue copyWith({
    String? id,
    String? name,
    List<String>? sports,
    String? address,
    String? hours,
    int? pricePerHour,
    bool? active,
    String? image,
    List<String>? images,
    String? description,
    String? coordinates,
    String? ownerId,
  }) {
    return ManagedVenue(
      id: id ?? this.id,
      name: name ?? this.name,
      sports: sports ?? this.sports,
      address: address ?? this.address,
      hours: hours ?? this.hours,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      active: active ?? this.active,
      image: image ?? this.image,
      images: images ?? this.images,
      description: description ?? this.description,
      coordinates: coordinates ?? this.coordinates,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'id': id,
    'ownerId': ownerId,
    'name': name,
    'location': address,
    'coordinates': coordinates,
    'images': images.isNotEmpty
        ? images
        : (image.isEmpty ? <String>[] : <String>[image]),
    'isActive': active,
    'sports': sports,
    'address': address,
    'hours': hours,
    'pricePerHour': pricePerHour,
    'active': active,
    'image': image,
    'description': description,
  };

  factory ManagedVenue.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return ManagedVenue(
      id:
          _readString(json['_id']) ??
          _readString(json['id']) ??
          fallbackId ??
          '',
      name: _readString(json['name']) ?? '',
      sports: _readStringList(json['sports']).isNotEmpty
          ? _readStringList(json['sports'])
          : [_readString(json['type']) ?? 'The thao'],
      address:
          _readString(json['address']) ?? _readString(json['location']) ?? '',
      hours: _readString(json['hours']) ?? '06:00 - 22:00',
      pricePerHour:
          _readInt(json['pricePerHour']) ?? _readInt(json['price']) ?? 0,
      active: json['isActive'] is bool
          ? json['isActive'] as bool
          : (json['active'] is bool ? json['active'] as bool : true),
      image:
          _readString(json['image']) ??
          _readStringList(json['images']).firstOrNull ??
          '',
      images: _readStringList(json['images']),
      description: _readString(json['description']) ?? '',
      coordinates: _readString(json['coordinates']) ?? '',
      ownerId: _readString(json['ownerId']) ?? '',
    );
  }
}

class SportCourt {
  final String id;
  final String venueId;
  final String name;
  final String sport;
  final String location;
  final int capacity;
  final List<String> images;
  final int pricePerHour;
  final List<String> amenities;
  final bool active;
  final int sortOrder;

  const SportCourt({
    required this.id,
    required this.venueId,
    required this.name,
    required this.sport,
    required this.location,
    required this.capacity,
    required this.images,
    required this.pricePerHour,
    required this.amenities,
    required this.active,
    required this.sortOrder,
  });

  SportCourt copyWith({
    String? id,
    String? venueId,
    String? name,
    String? sport,
    String? location,
    int? capacity,
    List<String>? images,
    int? pricePerHour,
    List<String>? amenities,
    bool? active,
    int? sortOrder,
  }) {
    return SportCourt(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      images: images ?? this.images,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      amenities: amenities ?? this.amenities,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'id': id,
    'complexId': venueId,
    'venueId': venueId,
    'name': name,
    'type': sport,
    'sport': sport,
    'location': location,
    'capacity': capacity,
    'images': images,
    'status': active ? 'active' : 'inactive',
    'pricePerHour': pricePerHour,
    'amenities': amenities,
    'active': active,
    'sortOrder': sortOrder,
  };

  factory SportCourt.fromJson(Map<String, dynamic> json, {String? fallbackId}) {
    return SportCourt(
      id:
          _readString(json['_id']) ??
          _readString(json['id']) ??
          fallbackId ??
          '',
      venueId:
          _readString(json['complexId']) ?? _readString(json['venueId']) ?? '',
      name: _readString(json['name']) ?? '',
      sport: _readString(json['type']) ?? _readString(json['sport']) ?? '',
      location: _readString(json['location']) ?? '',
      capacity: _readInt(json['capacity']) ?? 0,
      images: _readStringList(json['images']),
      pricePerHour: _readInt(json['pricePerHour']) ?? 0,
      amenities: _readStringList(json['amenities']),
      active: _readString(json['status']) == 'inactive'
          ? false
          : (json['active'] is bool ? json['active'] as bool : true),
      sortOrder: _readInt(json['sortOrder']) ?? 0,
    );
  }
}

class CourtBooking {
  final String id;
  final String venueId;
  final String venueName;
  final String courtId;
  final String courtName;
  final String userId;
  final String userName;
  final String userPhone;
  final String dateKey;
  final int startMinutes;
  final int endMinutes;
  final int totalPrice;
  final int participants;
  final String status;
  final String paymentMethod;
  final String notes;
  final DateTime createdAt;

  const CourtBooking({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.courtId,
    required this.courtName,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.dateKey,
    required this.startMinutes,
    required this.endMinutes,
    required this.totalPrice,
    required this.participants,
    required this.status,
    required this.paymentMethod,
    required this.notes,
    required this.createdAt,
  });

  int get durationMinutes => endMinutes - startMinutes;

  String get timeRange =>
      '${formatMinutes(startMinutes)} - ${formatMinutes(endMinutes)}';

  DateTime? get scheduledStart => _dateTimeForMinutes(dateKey, startMinutes);

  DateTime? get scheduledEnd => _dateTimeForMinutes(dateKey, endMinutes);

  CourtBooking copyWith({
    String? id,
    String? venueId,
    String? venueName,
    String? courtId,
    String? courtName,
    String? userId,
    String? userName,
    String? userPhone,
    String? dateKey,
    int? startMinutes,
    int? endMinutes,
    int? totalPrice,
    int? participants,
    String? status,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
  }) {
    return CourtBooking(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      dateKey: dateKey ?? this.dateKey,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      totalPrice: totalPrice ?? this.totalPrice,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'id': id,
    'fieldId': courtId,
    'venueId': venueId,
    'venueName': venueName,
    'courtId': courtId,
    'courtName': courtName,
    'userId': userId,
    'userName': userName,
    'userPhone': userPhone,
    'dateKey': dateKey,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'startTime': _dateTimeForMinutes(dateKey, startMinutes)?.toIso8601String(),
    'endTime': _dateTimeForMinutes(dateKey, endMinutes)?.toIso8601String(),
    'totalPrice': totalPrice,
    'participants': participants,
    'status': status,
    'paymentMethod': paymentMethod,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CourtBooking.fromJson(
    Map<String, dynamic> json, {
    String? fallbackId,
  }) {
    return CourtBooking(
      id:
          _readString(json['_id']) ??
          _readString(json['id']) ??
          fallbackId ??
          '',
      venueId: _readString(json['venueId']) ?? '',
      venueName: _readString(json['venueName']) ?? '',
      courtId:
          _readString(json['fieldId']) ?? _readString(json['courtId']) ?? '',
      courtName: _readString(json['courtName']) ?? '',
      userId: _readString(json['userId']) ?? '',
      userName: _readString(json['userName']) ?? '',
      userPhone: _readString(json['userPhone']) ?? '',
      dateKey: _readString(json['dateKey']) ?? '',
      startMinutes:
          _readInt(json['startMinutes']) ??
          _minutesFromDate(json['startTime']) ??
          0,
      endMinutes:
          _readInt(json['endMinutes']) ??
          _minutesFromDate(json['endTime']) ??
          0,
      totalPrice: _readInt(json['totalPrice']) ?? 0,
      participants: _readInt(json['participants']) ?? 0,
      status: _readString(json['status']) ?? CourtSlotStatus.booked,
      paymentMethod: _readString(json['paymentMethod']) ?? '',
      notes: _readString(json['notes']) ?? '',
      createdAt: _readDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}

/// Maps the persisted booking state to the three statuses used by the UI.
/// A booked slot becomes completed automatically after its end time.
String bookingDisplayStatus(CourtBooking booking, {DateTime? now}) {
  if (booking.status == CourtSlotStatus.cancelled) return 'cancelled';

  final end = booking.scheduledEnd;
  if (end != null && !end.isAfter(now ?? DateTime.now())) {
    return 'completed';
  }
  return 'upcoming';
}

class CourtSlotSelection {
  final SportCourt court;
  final int startMinutes;

  const CourtSlotSelection({required this.court, required this.startMinutes});

  String get label => '${court.name} - ${formatMinutes(startMinutes)}';
}

String dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String formatMinutes(int minutes) {
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

bool rangesOverlap(int aStart, int aEnd, int bStart, int bEnd) {
  return aStart < bEnd && bStart < aEnd;
}

String? _readString(Object? raw) {
  if (raw is! String) return null;
  final value = raw.trim();
  return value.isEmpty ? null : value;
}

List<String> _readStringList(Object? raw) {
  if (raw is List) {
    return raw
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  final value = _readString(raw);
  if (value == null) return const [];
  return value
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

int? _readInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.round();
  if (raw is String) return int.tryParse(raw.replaceAll('.', '').trim());
  return null;
}

DateTime? _readDate(Object? raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  if (raw is String) return DateTime.tryParse(raw);
  try {
    final dyn = raw as dynamic;
    final date = dyn.toDate();
    if (date is DateTime) return date;
  } catch (_) {
    return null;
  }
  return null;
}

DateTime? _dateTimeForMinutes(String rawDateKey, int minutes) {
  final date = DateTime.tryParse(rawDateKey);
  if (date == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).add(Duration(minutes: minutes));
}

int? _minutesFromDate(Object? raw) {
  final date = _readDate(raw);
  if (date == null) return null;
  return date.hour * 60 + date.minute;
}
