class shops {
  final id;
  final name;
  final number;

  shops({
    required this.id,
    required this.name,
    required this.number,
  });

  factory shops.fromJson(Map<String, dynamic> json) {
    return shops(
      id: json['id'].toString(),
      name: json['shop_name'].toString(),
      number: "${json['unitmovement'].length}",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'number': number,
    };
  }
}
