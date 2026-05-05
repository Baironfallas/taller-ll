import '../models/user_model.dart';

class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  UserModel? currentUser;

  int? get currentUserId => currentUser?.id;

  void setUser(UserModel user) {
    currentUser = user;
  }

  void clear() {
    currentUser = null;
  }
}
