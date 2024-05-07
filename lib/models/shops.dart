class shops {
  final int id;
  final String name;

  shops({
    required this.id,
    required this.name,
  });

  factory shops.fromJson(Map<String, dynamic> json) {
    return shops(
      id: json['id'],
      name: json['name'],
    );
  }
}
