class SupportedLanguage {
  final String code;
  final String name;

  SupportedLanguage({required this.code, required this.name});

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }
} 