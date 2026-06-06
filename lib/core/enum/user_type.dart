enum UserType { client, provider }

extension UserTypeX on UserType {
  String get value => name; // 'client' or 'provider'

  static UserType fromString(String? s) {
    switch (s) {
      case 'provider':
        return UserType.provider;
      default:
        return UserType.client;
    }
  }
}
