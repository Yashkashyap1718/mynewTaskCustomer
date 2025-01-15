bool isNumeric(String s) => s.isNotEmpty && double.tryParse(s) != null;

String? validateMobile(String? value, String? countryCode, String? type) {
  if (value == null || value.isEmpty) {
    return 'Please enter mobile number';
  }

  countryCode = countryCode?.replaceAll("+", "");
  const List<Country> countries = [
    Country(
      name: "India",
      flag: "🇮🇳",
      code: "IN",
      dialCode: "91",
      minLength: 10,
      maxLength: 10,
    ),
  ];

  final Country selectedCountry = countries.firstWhere(
    (element) => element.dialCode == countryCode,
  );

  if (value.length < selectedCountry.minLength ||
      value.length > selectedCountry.maxLength) {
    return 'Please enter a valid mobile number';
  }

  return null;
}

class Country {
  final String name;
  final String flag;
  final String code;
  final String dialCode;
  final int minLength;
  final int maxLength;

  const Country({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
    required this.minLength,
    required this.maxLength,
  });
}
