class shops {
  final String id;
  final String name;
  final String number;

  shops({
    required this.id,
    required this.name,
    required this.number,
  });

  factory shops.fromJson(Map<String, dynamic> json) {
    return shops(
      id: json['id'].toString(),
      name: json['shop_name'],
      number: "${json['unitmovement'].length}",
    );
  }
}
