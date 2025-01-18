class SupportTicketDataModel {
  String id;
  String supportTicketId;
  String title;
  String slug;
  String subject;
  String description;
  List<String> image;
  UserId userId;
  String? notes;
  String status;
  int createdAt;

  SupportTicketDataModel({
    this.id = "",
    this.supportTicketId = "",
    this.title = "",
    this.slug = "",
    this.subject = "",
    this.description = "",
    this.image = const [],
    required this.userId,
    this.notes,
    this.status = "",
    this.createdAt = 0,
  });

  factory SupportTicketDataModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketDataModel(
      id: json['_id'] ?? "",
      supportTicketId: json['support_ticket_id'] ?? "",
      title: json['title'] ?? "",
      slug: json['slug'] ?? "",
      subject: json['subject'] ?? "",
      description: json['description'] ?? "",
      image: List<String>.from(json['image'] ?? []),
      userId: UserId.fromJson(json['user_id']),
      notes: json['notes'],
      status: json['status'] ?? "",
      createdAt: json['createdAt'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'support_ticket_id': supportTicketId,
      'title': title,
      'slug': slug,
      'subject': subject,
      'description': description,
      'image': image,
      'user_id': userId.toJson(),
      'notes': notes,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

class UserId {
  String id;
  String name;
  String role;

  UserId({
    this.id = "",
    this.name = "",
    this.role = "",
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json['_id'] ?? "",
      name: json['name'] ?? "",
      role: json['role'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'role': role,
    };
  }
}
