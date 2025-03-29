import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String mobile;
  final String email;
  final String batch;
  final String password;
  final String orgCode;
  final String userId;
  final String fcmToken;
  final bool isActive;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.batch,
    required this.password,
    required this.orgCode,
    required this.userId,
    required this.fcmToken,
    required this.isActive,
    required this.isAdmin,
  });

  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        mobile: json["mobile"] ?? "",
        email: json["email"] ?? "",
        batch: json["batch"] ?? "",
        password: json["password"] ?? "",
        orgCode: json["orgCode"] ?? "",
        userId: json["userId"] ?? "",
        fcmToken: json["fcmToken"] ?? "",
        isActive: json["isActive"] ?? false,
        isAdmin: json["isAdmin"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? "",
        "name": name ?? "",
        "mobile": mobile ?? "",
        "email": email ?? "",
        "batch": batch ?? "",
        "password": password ?? "",
        "orgCode": orgCode ?? "",
        "userId": userId ?? "",
        "fcmToken": fcmToken ?? "",
        "isActive": isActive ?? false,
        "isAdmin": isAdmin ?? false,
      };

  factory UserModel.toEmpty() => UserModel(
        id: "",
        name: "",
        mobile: "",
        email: "",
        batch: "",
        password: "",
        orgCode: "",
        userId: "",
        fcmToken: "",
        isActive: false,
        isAdmin: false,
      );

  bool get isEmpty =>
      id == "" &&
      name == "" &&
      mobile == "" &&
      email == "" &&
      batch == "" &&
      password == "" &&
      orgCode == "" &&
      userId == "" &&
      fcmToken == "" &&
      isActive == false &&
      isAdmin == false;

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, mobile: $mobile, email: $email, batch: $batch, '
        'password: $password, orgCode: $orgCode, userId: $userId, fcmToken: $fcmToken, isActive: $isActive, isAdmin: $isAdmin)';
  }
}
