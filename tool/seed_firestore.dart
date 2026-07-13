import 'dart:convert';
import 'dart:io';

const firebaseApiKey = String.fromEnvironment(
  'FIREBASE_API_KEY',
  defaultValue: 'AIzaSyBAnbTZGX4MnsHx-7nSUY-pTqz0Jon7GjU',
);
const firebaseProjectId = String.fromEnvironment(
  'FIREBASE_PROJECT_ID',
  defaultValue: 'sportbook-e74c7',
);

Future<void> main(List<String> args) async {
  final options = _SeedOptions.parse(args);
  if (options.help) {
    _printUsage();
    return;
  }

  if (options.email.isEmpty || options.password.isEmpty) {
    stderr.writeln('Missing admin email/password.');
    _printUsage();
    exitCode = 64;
    return;
  }

  _validateBadmintonSeed();

  final client = HttpClient();
  try {
    final auth = await _signInAdmin(
      client,
      email: options.email,
      password: options.password,
    );
    stdout.writeln('Signed in as ${auth.email} (${auth.localId})');
    await _assertCanSeed(client, auth);

    final now = DateTime.now().toUtc();
    final writes = <Map<String, Object?>>[
      for (final doc in _legacyNonBadmintonDocsToDelete)
        _delete(doc.collection, doc.id),
      for (final complex in _fieldComplexes)
        _write('fieldComplexes', complex.id, complex.data),
      for (final field in _sportFields)
        _write('sportFields', field.id, field.data),
      for (final schedule in _schedules(now))
        _write('schedules', schedule.id, schedule.data),
    ];

    try {
      var written = 0;
      for (final chunk in _chunks(writes, 8)) {
        await _commit(client, idToken: auth.idToken, writes: chunk);
        written += chunk.length;
        stdout.writeln('Seeded $written/${writes.length} documents...');
      }
    } on StateError catch (error) {
      final message = error.message;
      if (message.contains('Missing or insufficient permissions')) {
        throw StateError(
          'Firestore Rules chua cho admin ghi fieldComplexes/sportFields/schedules. '
          'Hay copy firestore.rules len Firebase Console > Firestore > Rules va bam Publish.',
        );
      }
      rethrow;
    }
    stdout.writeln(
      'Seeded badminton-only data into Firebase project $firebaseProjectId.',
    );
  } finally {
    client.close(force: true);
  }
}

Iterable<List<T>> _chunks<T>(List<T> items, int size) sync* {
  for (var start = 0; start < items.length; start += size) {
    final end = start + size > items.length ? items.length : start + size;
    yield items.sublist(start, end);
  }
}

Future<_AuthSession> _signInAdmin(
  HttpClient client, {
  required String email,
  required String password,
}) async {
  final uri = Uri.https(
    'identitytoolkit.googleapis.com',
    '/v1/accounts:signInWithPassword',
    {'key': firebaseApiKey},
  );
  final response = await _postJson(client, uri, {
    'email': email,
    'password': password,
    'returnSecureToken': true,
  });

  return _AuthSession(
    idToken: response['idToken'] as String,
    localId: response['localId'] as String,
    email: response['email'] as String,
  );
}

Future<void> _assertCanSeed(HttpClient client, _AuthSession auth) async {
  Map<String, Object?> userDoc;
  try {
    userDoc = await _getJson(
      client,
      Uri.https(
        'firestore.googleapis.com',
        '/v1/projects/$firebaseProjectId/databases/(default)/documents/users/${auth.localId}',
      ),
      bearerToken: auth.idToken,
    );
  } on StateError catch (error) {
    final message = error.message;
    if (message.contains('Missing or insufficient permissions')) {
      throw StateError(
        'Tai khoan da dang nhap Auth nhung Firestore Rules khong cho doc users/${auth.localId}. '
        'Hay publish firestore.rules len Firebase Console truoc khi seed.',
      );
    }
    rethrow;
  }

  final fields = userDoc['fields'];
  if (fields is! Map<String, Object?>) {
    throw StateError('Khong doc duoc fields cua users/${auth.localId}.');
  }

  final role = _decodeString(fields['role']);
  final isBanned = _decodeBool(fields['isBanned']) ?? false;
  if (role != 'admin' || isBanned) {
    throw StateError(
      'Tai khoan ${auth.email} phai co role="admin" va isBanned=false trong users/${auth.localId}. '
      'Hien tai role="$role", isBanned=$isBanned.',
    );
  }
}

Future<void> _commit(
  HttpClient client, {
  required String idToken,
  required List<Map<String, Object?>> writes,
}) async {
  final uri = Uri.https(
    'firestore.googleapis.com',
    '/v1/projects/$firebaseProjectId/databases/(default)/documents:commit',
  );
  await _postJson(
    client,
    uri,
    {'writes': writes},
    bearerToken: idToken,
  );
}

Future<Map<String, Object?>> _getJson(
  HttpClient client,
  Uri uri, {
  required String bearerToken,
}) async {
  final request = await client.getUrl(uri);
  request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');

  final response = await request.close();
  final payload = await utf8.decodeStream(response);
  final decoded = payload.isEmpty
      ? <String, Object?>{}
      : jsonDecode(payload) as Map<String, Object?>;

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final error = decoded['error'];
    if (error is Map<String, Object?>) {
      throw StateError(error['message']?.toString() ?? payload);
    }
    throw StateError(payload);
  }

  return decoded;
}

Map<String, Object?> _write(
  String collection,
  String documentId,
  Map<String, Object?> data,
) {
  return {
    'update': {
      'name':
          'projects/$firebaseProjectId/databases/(default)/documents/$collection/$documentId',
      'fields': _encodeFields(data),
    },
  };
}

Map<String, Object?> _delete(String collection, String documentId) {
  return {
    'delete':
        'projects/$firebaseProjectId/databases/(default)/documents/$collection/$documentId',
  };
}

Future<Map<String, Object?>> _postJson(
  HttpClient client,
  Uri uri,
  Map<String, Object?> body, {
  String? bearerToken,
}) async {
  final request = await client.postUrl(uri);
  request.headers.contentType = ContentType.json;
  if (bearerToken != null) {
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearerToken');
  }
  request.write(jsonEncode(body));

  final response = await request.close();
  final payload = await utf8.decodeStream(response);
  final decoded = payload.isEmpty
      ? <String, Object?>{}
      : jsonDecode(payload) as Map<String, Object?>;

  if (response.statusCode < 200 || response.statusCode >= 300) {
    final error = decoded['error'];
    if (error is Map<String, Object?>) {
      throw StateError(error['message']?.toString() ?? payload);
    }
    throw StateError(payload);
  }

  return decoded;
}

Map<String, Object?> _encodeFields(Map<String, Object?> data) {
  return data.map((key, value) => MapEntry(key, _encodeValue(value)));
}

Map<String, Object?> _encodeValue(Object? value) {
  if (value == null) return {'nullValue': null};
  if (value is bool) return {'booleanValue': value};
  if (value is int) return {'integerValue': value.toString()};
  if (value is double) return {'doubleValue': value};
  if (value is DateTime) {
    return {'timestampValue': value.toUtc().toIso8601String()};
  }
  if (value is String) return {'stringValue': value};
  if (value is List) {
    return {
      'arrayValue': {
        if (value.isNotEmpty)
          'values': [for (final item in value) _encodeValue(item)],
      },
    };
  }
  if (value is Map<String, Object?>) {
    return {'mapValue': {'fields': _encodeFields(value)}};
  }
  throw ArgumentError('Unsupported Firestore value: $value');
}

String? _decodeString(Object? raw) {
  if (raw is! Map<String, Object?>) return null;
  final value = raw['stringValue'];
  return value is String ? value : null;
}

bool? _decodeBool(Object? raw) {
  if (raw is! Map<String, Object?>) return null;
  final value = raw['booleanValue'];
  return value is bool ? value : null;
}

// These legacy IDs are deleted only; they are never written back to Firestore.
const _legacyNonBadmintonDocsToDelete = [
  _SeedRef('fieldComplexes', 'fc_q7_arena'),
  _SeedRef('fieldComplexes', 'fc_thao_dien_tennis'),
  _SeedRef('sportFields', 'sf_q7_football_1'),
  _SeedRef('sportFields', 'sf_q7_football_2'),
  _SeedRef('sportFields', 'sf_q7_football_3'),
  _SeedRef('sportFields', 'sf_tennis_1'),
  _SeedRef('sportFields', 'sf_tennis_2'),
  _SeedRef('schedules', 'sch_sf_q7_football_1_today'),
  _SeedRef('schedules', 'sch_sf_q7_football_2_today'),
  _SeedRef('schedules', 'sch_sf_q7_football_3_today'),
  _SeedRef('schedules', 'sch_sf_tennis_1_today'),
  _SeedRef('schedules', 'sch_sf_tennis_2_today'),
];

const _fieldComplexes = [
  _SeedDoc('fc_galaxy_badminton', {
    '_id': 'fc_galaxy_badminton',
    'name': 'Galaxy Badminton Club',
    'location': '99 Hoang Van Thu, Phu Nhuan, TP.HCM',
    'coordinates': '10.7992,106.6741',
    'description':
        'Cụm sân cầu lông trong nhà với sàn gỗ, điều hòa và khu nghỉ chờ.',
    'ownerId': 'owner_admin_01',
    'sports': ['Cầu lông'],
    'hours': '06:00 - 23:00',
    'pricePerHour': 100000,
    'images': [
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&h=500&fit=crop&auto=format',
    ],
    'isActive': true,
  }),
  _SeedDoc('fc_phu_nhuan_badminton', {
    '_id': 'fc_phu_nhuan_badminton',
    'name': 'Phu Nhuan Badminton Center',
    'location': '21 Nguyen Van Troi, Phu Nhuan, TP.HCM',
    'coordinates': '10.7979,106.6745',
    'description':
        'Trung tâm cầu lông gần sân bay, có thảm chuẩn, đèn LED và bãi xe.',
    'ownerId': 'owner_admin_01',
    'sports': ['Cầu lông'],
    'hours': '05:30 - 22:30',
    'pricePerHour': 150000,
    'images': [
      'https://images.unsplash.com/photo-1613918108466-292b78a8ef95?w=800&h=500&fit=crop&auto=format',
    ],
    'isActive': true,
  }),
  _SeedDoc('fc_q7_badminton', {
    '_id': 'fc_q7_badminton',
    'name': 'Q7 Badminton House',
    'location': '268 Nguyen Van Linh, Quan 7, TP.HCM',
    'coordinates': '10.7298,106.7217',
    'description':
        'Cụm sân cầu lông Quận 7, phù hợp đặt sân theo nhóm sau giờ làm.',
    'ownerId': 'owner_admin_01',
    'sports': ['Cầu lông'],
    'hours': '06:00 - 22:00',
    'pricePerHour': 130000,
    'images': [
      'https://images.unsplash.com/photo-1600679472829-3044539ce8ed?w=800&h=500&fit=crop&auto=format',
    ],
    'isActive': true,
  }),
];

const _sportFields = [
  _SeedDoc('sf_badminton_1', {
    '_id': 'sf_badminton_1',
    'complexId': 'fc_galaxy_badminton',
    'name': 'Sân cầu lông 1',
    'type': 'Cầu lông',
    'location': '99 Hoang Van Thu, Phu Nhuan, TP.HCM',
    'capacity': 4,
    'images': [],
    'status': 'active',
    'pricePerHour': 120000,
    'amenities': ['Sàn gỗ', 'Điều hòa', 'Cho thuê vợt'],
  }),
  _SeedDoc('sf_badminton_2', {
    '_id': 'sf_badminton_2',
    'complexId': 'fc_galaxy_badminton',
    'name': 'Sân cầu lông 2',
    'type': 'Cầu lông',
    'location': '99 Hoang Van Thu, Phu Nhuan, TP.HCM',
    'capacity': 4,
    'images': [],
    'status': 'active',
    'pricePerHour': 120000,
    'amenities': ['Sàn gỗ', 'Điều hòa', 'Nước uống'],
  }),
  _SeedDoc('sf_badminton_3', {
    '_id': 'sf_badminton_3',
    'complexId': 'fc_galaxy_badminton',
    'name': 'Sân cầu lông 3',
    'type': 'Cầu lông',
    'location': '99 Hoang Van Thu, Phu Nhuan, TP.HCM',
    'capacity': 4,
    'images': [],
    'status': 'active',
    'pricePerHour': 100000,
    'amenities': ['Sàn gỗ', 'Điều hòa'],
  }),
  _SeedDoc('sf_phu_nhuan_1', {
    '_id': 'sf_phu_nhuan_1',
    'complexId': 'fc_phu_nhuan_badminton',
    'name': 'Sân VIP 1',
    'type': 'Cầu lông',
    'location': '21 Nguyen Van Troi, Phu Nhuan, TP.HCM',
    'capacity': 4,
    'images': [],
    'status': 'active',
    'pricePerHour': 150000,
    'amenities': ['Thảm chuẩn', 'Đèn LED', 'Bãi đỗ xe'],
  }),
  _SeedDoc('sf_phu_nhuan_2', {
    '_id': 'sf_phu_nhuan_2',
    'complexId': 'fc_phu_nhuan_badminton',
    'name': 'Sân VIP 2',
    'type': 'Cầu lông',
    'location': '21 Nguyen Van Troi, Phu Nhuan, TP.HCM',
    'capacity': 4,
    'images': [],
    'status': 'active',
    'pricePerHour': 150000,
    'amenities': ['Thảm chuẩn', 'Đèn LED', 'Cho thuê vợt'],
  }),
  _SeedDoc('sf_q7_badminton_1', {
    '_id': 'sf_q7_badminton_1',
    'complexId': 'fc_q7_badminton',
    'name': 'Sân Q7 A',
    'type': 'Cầu lông',
    'location': '268 Nguyen Van Linh, Quan 7, TP.HCM',
    'capacity': 4,
    'images': [],
    'status': 'active',
    'pricePerHour': 130000,
    'amenities': ['Sân trong nhà', 'Đèn LED', 'Nước uống'],
  }),
  _SeedDoc('sf_q7_badminton_2', {
    '_id': 'sf_q7_badminton_2',
    'complexId': 'fc_q7_badminton',
    'name': 'Sân Q7 B',
    'type': 'Cầu lông',
    'location': '268 Nguyen Van Linh, Quan 7, TP.HCM',
    'capacity': 4,
    'images': [],
    'status': 'active',
    'pricePerHour': 130000,
    'amenities': ['Sân trong nhà', 'Đèn LED', 'Tủ đồ'],
  }),
];

void _validateBadmintonSeed() {
  final complexIds = _fieldComplexes.map((complex) => complex.id).toSet();

  for (final complex in _fieldComplexes) {
    final sports = complex.data['sports'];
    if (sports is! List ||
        sports.length != 1 ||
        sports.single != 'Cầu lông') {
      throw StateError(
        'Field complex ${complex.id} must contain only the Cầu lông sport.',
      );
    }
  }

  for (final field in _sportFields) {
    if (field.data['type'] != 'Cầu lông') {
      throw StateError('Sport field ${field.id} is not a badminton court.');
    }

    final complexId = field.data['complexId'];
    if (complexId is! String || !complexIds.contains(complexId)) {
      throw StateError(
        'Sport field ${field.id} references an unknown field complex.',
      );
    }
  }
}

List<_SeedDoc> _schedules(DateTime now) {
  return [
    for (final field in _sportFields)
      _SeedDoc('sch_${field.id}_today', {
        '_id': 'sch_${field.id}_today',
        'fieldId': field.id,
        'date': DateTime.utc(now.year, now.month, now.day),
        'timeSlots': [
          for (var hour = 6; hour <= 22; hour++)
            '${hour.toString().padLeft(2, '0')}:00',
        ],
      }),
  ];
}

class _SeedDoc {
  final String id;
  final Map<String, Object?> data;

  const _SeedDoc(this.id, this.data);
}

class _SeedRef {
  final String collection;
  final String id;

  const _SeedRef(this.collection, this.id);
}

class _AuthSession {
  final String idToken;
  final String localId;
  final String email;

  const _AuthSession({
    required this.idToken,
    required this.localId,
    required this.email,
  });
}

class _SeedOptions {
  final String email;
  final String password;
  final bool help;

  const _SeedOptions({
    required this.email,
    required this.password,
    required this.help,
  });

  factory _SeedOptions.parse(List<String> args) {
    String valueOf(String name, String envName) {
      final index = args.indexOf(name);
      if (index >= 0 && index + 1 < args.length) return args[index + 1];
      return Platform.environment[envName] ?? '';
    }

    return _SeedOptions(
      email: valueOf('--email', 'SEED_ADMIN_EMAIL'),
      password: valueOf('--password', 'SEED_ADMIN_PASSWORD'),
      help: args.contains('--help') || args.contains('-h'),
    );
  }
}

void _printUsage() {
  stdout.writeln('''
Seed badminton-only SportBook Firestore data for the ERD tables:
  - FieldComplex  -> fieldComplexes
  - SportField    -> sportFields
  - Schedule      -> schedules

Usage:
  dart run tool/seed_firestore.dart --email <admin-email> --password <admin-password>

Or set:
  SEED_ADMIN_EMAIL=<admin-email>
  SEED_ADMIN_PASSWORD=<admin-password>

The account must exist in Firebase Authentication and have role "admin" in
Firestore users/{uid}.
''');
}
