class InventoryItem {
  final String id;
  final String name;
  final String description;
  final int quantity;
  final String unit;
  final int price;
  final bool active;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.active,
  });

  InventoryItem copyWith({String? id}) => InventoryItem(
    id: id ?? this.id,
    name: name,
    description: description,
    quantity: quantity,
    unit: unit,
    price: price,
    active: active,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'quantity': quantity,
    'unit': unit,
    'price': price,
    'isActive': active,
  };

  factory InventoryItem.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) => InventoryItem(
    id: _text(json['_id'], fallbackId),
    name: _text(json['name'], 'Chưa đặt tên'),
    description: _text(json['description'], ''),
    quantity: _number(json['quantity']),
    unit: _text(json['unit'], 'cái'),
    price: _number(json['price']),
    active: json['isActive'] != false,
  );
}

class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final bool published;
  final DateTime createdAt;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.published,
    required this.createdAt,
  });

  NewsArticle copyWith({String? id}) => NewsArticle(
    id: id ?? this.id,
    title: title,
    summary: summary,
    content: content,
    imageUrl: imageUrl,
    published: published,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'summary': summary,
    'content': content,
    'imageUrl': imageUrl,
    'isPublished': published,
    'createdAt': createdAt,
  };

  factory NewsArticle.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) => NewsArticle(
    id: _text(json['_id'], fallbackId),
    title: _text(json['title'], 'Tin tức'),
    summary: _text(json['summary'], ''),
    content: _text(json['content'], ''),
    imageUrl: _text(json['imageUrl'], ''),
    published: json['isPublished'] == true,
    createdAt: _date(json['createdAt']) ?? DateTime.now(),
  );
}

class PolicyCategory {
  final String id;
  final String name;
  final String description;

  const PolicyCategory({
    required this.id,
    required this.name,
    required this.description,
  });

  PolicyCategory copyWith({String? id}) =>
      PolicyCategory(id: id ?? this.id, name: name, description: description);

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
  };

  factory PolicyCategory.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) => PolicyCategory(
    id: _text(json['_id'], fallbackId),
    name: _text(json['name'], 'Danh mục'),
    description: _text(json['description'], ''),
  );
}

class PolicyDocument {
  final String id;
  final String categoryId;
  final String title;
  final String content;
  final bool active;

  const PolicyDocument({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.content,
    required this.active,
  });

  PolicyDocument copyWith({String? id}) => PolicyDocument(
    id: id ?? this.id,
    categoryId: categoryId,
    title: title,
    content: content,
    active: active,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'categoryId': categoryId,
    'title': title,
    'content': content,
    'isActive': active,
  };

  factory PolicyDocument.fromJson(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) => PolicyDocument(
    id: _text(json['_id'], fallbackId),
    categoryId: _text(json['categoryId'], ''),
    title: _text(json['title'], 'Chính sách'),
    content: _text(json['content'], ''),
    active: json['isActive'] != false,
  );
}

String _text(Object? value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _number(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _date(Object? value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  try {
    final dynamic raw = value;
    final result = raw.toDate();
    return result is DateTime ? result : null;
  } catch (_) {
    return null;
  }
}
