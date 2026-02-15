import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_graveyard/features/auth/domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.role,
    super.lastSignInTime,
    super.creationTime,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user', // Default to user if not set
      lastSignInTime: (data['lastSignInTime'] as Timestamp?)?.toDate(),
      creationTime: (data['creationTime'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'lastSignInTime': lastSignInTime != null ? Timestamp.fromDate(lastSignInTime!) : null,
      'creationTime': creationTime != null ? Timestamp.fromDate(creationTime!) : null,
    };
  }
}
