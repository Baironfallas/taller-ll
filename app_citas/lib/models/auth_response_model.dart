import 'user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.accessToken, required this.user});

  final String accessToken;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken']?.toString() ?? '',
      user: UserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'accessToken': accessToken, 'user': user.toJson()};
  }
}
