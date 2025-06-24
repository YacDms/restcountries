class Country {
  final String name;
  final String capital;
  final String flag;

  Country({
    required this.name,
    required this.capital,
    required this.flag,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']?['common'] ?? 'Inconnu',
      capital: (json['capital'] != null &&
              json['capital'] is List &&
              json['capital'].isNotEmpty)
          ? json['capital'][0]
          : 'N/A',
      flag: json['flags']?['png'] ?? '',
    );
  }
}