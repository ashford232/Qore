import 'dart:convert';

class QoreModel {
  final String id;
  final String title;
  final List<TextModel> texts;
  final List<AudioModel> audios;
  final List<ImageModel> images;
  final String description;
  final DateTime createdAt;

  QoreModel({
    required this.id,
    required this.title,
    required this.texts,
    required this.audios,
    required this.images,
    required this.description,
    required this.createdAt,
  });

  QoreModel copyWith({
    String? id,
    String? title,
    List<TextModel>? texts,
    List<AudioModel>? audios,
    List<ImageModel>? images,
    String? description,
    DateTime? createdAt,
  }) {
    return QoreModel(
      id: id ?? this.id,
      title: title ?? this.title,
      texts: texts ?? this.texts,
      audios: audios ?? this.audios,
      images: images ?? this.images,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ================= JSON =================

  factory QoreModel.fromJson(Map<String, dynamic> json) {
    return QoreModel(
      id: json['id'],
      title: json['title'],
      texts: (json['texts'] as List).map((e) => TextModel.fromJson(e)).toList(),
      audios: (json['audios'] as List)
          .map((e) => AudioModel.fromJson(e))
          .toList(),
      images: (json['images'] as List)
          .map((e) => ImageModel.fromJson(e))
          .toList(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'texts': texts.map((e) => e.toJson()).toList(),
      'audios': audios.map((e) => e.toJson()).toList(),
      'images': images.map((e) => e.toJson()).toList(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ================= SQLITE =================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'texts': jsonEncode(texts.map((e) => e.toMap()).toList()),
      'audios': jsonEncode(audios.map((e) => e.toMap()).toList()),
      'images': jsonEncode(images.map((e) => e.toMap()).toList()),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QoreModel.fromMap(Map<String, dynamic> map) {
    return QoreModel(
      id: map['id'],
      title: map['title'],
      texts: (jsonDecode(map['texts']) as List)
          .map((e) => TextModel.fromMap(e))
          .toList(),
      audios: (jsonDecode(map['audios']) as List)
          .map((e) => AudioModel.fromMap(e))
          .toList(),
      images: (jsonDecode(map['images']) as List)
          .map((e) => ImageModel.fromMap(e))
          .toList(),
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class QoreDbModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  QoreDbModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  QoreDbModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return QoreDbModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ================= JSON =================

  factory QoreDbModel.fromJson(Map<String, dynamic> json) {
    return QoreDbModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ================= SQLITE =================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QoreDbModel.fromMap(Map<String, dynamic> map) {
    return QoreDbModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

// ======================================================
// TEXT MODEL
// ======================================================

class TextModel {
  final String text;
  final DateTime createdAt;
  final String id;
  final List<String> tags;
  final String qoreId;

  TextModel({
    required this.text,
    required this.createdAt,
    required this.id,
    required this.tags,
    required this.qoreId,
  });

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      id: json['id'],
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      qoreId: json['qoreId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'tags': tags,
      'qoreId': qoreId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'tags': jsonEncode(tags),
      'qoreId': qoreId,
    };
  }

  factory TextModel.fromMap(Map<String, dynamic> map) {
    return TextModel(
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
      id: map['id'],
      tags: List<String>.from(jsonDecode(map['tags'])),
      qoreId: map['qoreId'],
    );
  }
}

// ======================================================
// AUDIO MODEL
// ======================================================

class AudioModel {
  final String filePath;
  final String text;
  final DateTime createdAt;
  final String id;
  final List<String> tags;
  final String qoreId;

  AudioModel({
    required this.filePath,
    required this.text,
    required this.createdAt,
    required this.id,
    required this.tags,
    required this.qoreId,
  });

  factory AudioModel.fromJson(Map<String, dynamic> json) {
    return AudioModel(
      filePath: json['filePath'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      id: json['id'],
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      qoreId: json['qoreId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'tags': tags,
      'qoreId': qoreId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'tags': jsonEncode(tags),
    };
  }

  factory AudioModel.fromMap(Map<String, dynamic> map) {
    return AudioModel(
      filePath: map['filePath'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
      id: map['id'],
      tags: List<String>.from(jsonDecode(map['tags'])),
      qoreId: map['qoreId'],
    );
  }
}

// ======================================================
// IMAGE MODEL
// ======================================================

class ImageModel {
  final String filePath;
  final String text;
  final DateTime createdAt;
  final String id;
  final List<String> tags;
  final String qoreId;

  ImageModel({
    required this.filePath,
    required this.text,
    required this.createdAt,
    required this.id,
    required this.tags,
    required this.qoreId,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      filePath: json['filePath'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      id: json['id'],
      tags: (json['tags'] as List).map((e) => e.toString()).toList(),
      qoreId: json['qoreId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'tags': tags,
      'qoreId': qoreId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'filePath': filePath,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'tags': jsonEncode(tags),
      'qoreId': qoreId,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      filePath: map['filePath'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
      id: map['id'],
      tags: List<String>.from(jsonDecode(map['tags'])),
      qoreId: map['qoreId'],
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String avater;
  final String streak;

  UserModel({
    required this.id,
    required this.name,
    required this.avater,
    required this.streak,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      avater: json['avater'],
      streak: json['streak'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avater': avater, 'streak': streak};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      avater: map['avater'],
      streak: map['streak'],
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? avater,
    String? streak,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avater: avater ?? this.avater,
      streak: streak ?? this.streak,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'avater': avater, 'streak': streak};
  }
}
