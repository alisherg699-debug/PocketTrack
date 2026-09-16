class User {
  final String id;
  final String firstName;
  final String email;
  final String password;
  final String? phone;
  final String? currency;
  final String? imagePath;

  User({
    required this.id,
    required this.firstName,
    required this.email,
    required this.password,
    this.phone,
    this.currency,
    this.imagePath,
  });
}
