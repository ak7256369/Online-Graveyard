class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String role;
  final DateTime? lastSignInTime;
  final DateTime? creationTime;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = 'user',
    this.lastSignInTime,
    this.creationTime,
  });
}
