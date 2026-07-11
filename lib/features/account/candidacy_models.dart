class CandidacyItem {
  const CandidacyItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.adminNotes,
    required this.createdAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String status;
  final String? adminNotes;
  final String? createdAt;

  factory CandidacyItem.fromJson(Map<String, dynamic> json) {
    return CandidacyItem(
      id: json['id'].toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      adminNotes: json['admin_notes']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
