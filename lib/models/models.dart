class User {
  final String id;
  final String name;
  final String avatarUrl;
  final String role;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl = '',
    this.role = 'Anggota',
  });

  User copyWith({
    String? name,
    String? avatarUrl,
    String? role,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        avatarUrl: json['avatarUrl'] as String? ?? '',
        role: json['role'] as String? ?? 'Anggota',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'role': role,
      };
}

class Community {
  final String id;
  final String name;
  final String description;
  final String category;
  final String adminId;
  final String logo;
  final List<User> members;

  const Community({
    required this.id,
    required this.name,
    required this.description,
    this.category = 'Hobi & Komunitas',
    this.adminId = '',
    this.logo = '',
    this.members = const [],
  });

  factory Community.fromJson(Map<String, dynamic> json) => Community(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        category: json['category'] as String? ?? 'Hobi & Komunitas',
        adminId: json['adminId'] as String? ?? '',
        logo: json['logo'] as String? ?? '',
        members: (json['members'] as List<dynamic>? ?? [])
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'adminId': adminId,
        'logo': logo,
        'members': members.map((e) => e.toJson()).toList(),
      };
}

class Event {
  final String id;
  final String communityId;
  final String title;
  final String description;
  final DateTime dateTime;
  final String location;
  final String creatorId;
  final Map<String, String> rsvps;
  final bool reminderSet;

  Event({
    required this.id,
    required this.communityId,
    required this.title,
    required this.description,
    required this.dateTime,
    this.location = '',
    required this.creatorId,
    Map<String, String>? rsvps,
    this.reminderSet = false,
  }) : rsvps = rsvps != null ? Map.from(rsvps) : {};

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'] as String,
        communityId: json['communityId'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        dateTime: DateTime.fromMillisecondsSinceEpoch(json['dateTime'] as int),
        location: json['location'] as String? ?? '',
        creatorId: json['creatorId'] as String,
        rsvps: (json['rsvps'] as Map<String, dynamic>?)
            ?.map((k, v) => MapEntry(k, v as String)),
        reminderSet: json['reminderSet'] as bool? ?? false,
      );

  int get joinedCount => rsvps.values.where((v) => v == 'joined').length;
  int get maybeCount => rsvps.values.where((v) => v == 'maybe').length;
  int get declinedCount => rsvps.values.where((v) => v == 'declined').length;

  Event copyWith({
    String? id,
    String? communityId,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    String? creatorId,
    Map<String, String>? rsvps,
    bool? reminderSet,
  }) {
    return Event(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      creatorId: creatorId ?? this.creatorId,
      rsvps: rsvps ?? this.rsvps,
      reminderSet: reminderSet ?? this.reminderSet,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'communityId': communityId,
        'title': title,
        'description': description,
        'dateTime': dateTime.millisecondsSinceEpoch,
        'location': location,
        'creatorId': creatorId,
        'rsvps': rsvps,
        'reminderSet': reminderSet,
      };
}

class Announcement {
  final String id;
  final String communityId;
  final String title;
  final String body;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final bool pinned;
  final String category;

  const Announcement({
    required this.id,
    required this.communityId,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.pinned = false,
    this.category = 'Umum',
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json['id'] as String,
        communityId: json['communityId'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
        pinned: json['pinned'] as bool? ?? false,
        category: json['category'] as String? ?? 'Umum',
      );

  Announcement copyWith({
    String? id,
    String? communityId,
    String? title,
    String? body,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    bool? pinned,
    String? category,
  }) {
    return Announcement(
      id: id ?? this.id,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      body: body ?? this.body,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      pinned: pinned ?? this.pinned,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'communityId': communityId,
        'title': title,
        'body': body,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'pinned': pinned,
        'category': category,
      };
}

class Task {
  final String id;
  final String eventId;
  final String communityId;
  final String title;
  final String description;
  final List<String> assigneeIds;
  final bool isCompleted;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.eventId,
    required this.title,
    this.communityId = '',
    this.description = '',
    this.assigneeIds = const [],
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        title: json['title'] as String,
        communityId: json['communityId'] as String? ?? '',
        description: json['description'] as String? ?? '',
        assigneeIds: (json['assigneeIds'] as List<dynamic>? ?? []).cast<String>(),
        isCompleted: json['isCompleted'] as bool? ?? false,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );

  Task copyWith({
    String? id,
    String? eventId,
    String? communityId,
    String? title,
    String? description,
    List<String>? assigneeIds,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      communityId: communityId ?? this.communityId,
      title: title ?? this.title,
      description: description ?? this.description,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'communityId': communityId,
        'title': title,
        'description': description,
        'assigneeIds': assigneeIds,
        'isCompleted': isCompleted,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}
