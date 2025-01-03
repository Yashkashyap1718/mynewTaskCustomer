
class ServiceListModal {
  final String id;
  final String title;
  final String slug;
  final String subtitle;
  final String image;
  final String description;
  final String status;
  final int createdAt;
  final int updatedAt;
  final int v;

  ServiceListModal({
    required this.id,
    required this.title,
    required this.slug,
    required this.subtitle,
    required this.image,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ServiceListModal.fromJson(Map<String, dynamic> json) {
    return ServiceListModal(
      id: json['_id'],
      title: json['title'],
      slug: json['slug'],
      subtitle: json['subtitle'],
      image: json['image'],
      description: json['description'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'slug': slug,
      'subtitle': subtitle,
      'image': image,
      'description': description,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}