import 'package:flutter/material.dart';

class UserModel {
  String name;
  String mobile;
  String email;
  String batch;
  String? password;
  String orgCode;
  String userId;
  bool isActive;

  UserModel({
    required this.name,
    required this.mobile,
    required this.email,
    required this.batch,
    this.password,
    required this.orgCode,
    required this.userId,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      batch: json['batch'] ?? '',
      password: json['password'],
      orgCode: json['orgCode'] ?? '',
      userId: json['userId'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email,
      'batch': batch,
      'password': password,
      'orgCode': orgCode,
      'userId': userId,
      'isActive': isActive,
    };
  }

  bool isEmpty() {
    return name.isEmpty &&
        mobile.isEmpty &&
        email.isEmpty &&
        batch.isEmpty &&
        orgCode.isEmpty &&
        userId.isEmpty;
  }

  static UserModel toEmpty() {
    return UserModel(
      name: '',
      mobile: '',
      email: '',
      batch: '',
      password: null,
      orgCode: '',
      userId: '',
      isActive: false,
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, mobile: $mobile, email: $email, batch: $batch, password: $password, orgCode: $orgCode, userId: $userId, isActive: $isActive)';
  }
}
