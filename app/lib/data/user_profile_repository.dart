import '../domain/user_profile_snapshot.dart';

abstract class UserProfileRepository {
  Future<UserProfileSnapshot> getSnapshot();
}
