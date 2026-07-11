class Territory {
  const Territory({required this.id, required this.name, this.parentId});

  final String id;
  final String name;
  final String? parentId;

  factory Territory.fromJson(Map<String, dynamic> json, {String? parentKey}) {
    return Territory(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      parentId: parentKey != null ? json[parentKey]?.toString() : null,
    );
  }
}
