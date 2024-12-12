class RideCancelResaons {
  final String? id;
  final String? reason;
  final String? slug;
  final String? status;
  final int? createdAt;
  final int? updatedAt;

  RideCancelResaons({
    this.id,
    this.reason,
    this.slug,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory RideCancelResaons.fromJson(Map<String, dynamic> json) {
    return RideCancelResaons(
      id: json['_id'],
      reason: json['reason'],
      slug: json['slug'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reason': reason,
      'slug': slug,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
