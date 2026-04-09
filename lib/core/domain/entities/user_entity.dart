class UserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String profileImageUrl;
  final String bio;
  final String city;
  final String country;
  final bool tocAccepted;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.profileImageUrl,
    required this.bio,
    required this.city,
    required this.country,
    required this.tocAccepted,
  });

  String get fullName => '$firstName $lastName'.trim();
}
