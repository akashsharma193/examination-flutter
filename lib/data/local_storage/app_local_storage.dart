import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crackitx/app_models/app_user_model.dart';

class AppLocalStorage {
  static final AppLocalStorage instance = AppLocalStorage._();
  AppLocalStorage._();

  late SharedPreferences _prefs;

  Future<void> initAppLocalStorage() async {
    _prefs = await SharedPreferences.getInstance();
    await Future.delayed(Durations.medium4);
  }

  UserModel get user {
    final String? userData = _prefs.getString('user-data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    } else {
      return UserModel.toEmpty();
    }
  }

  void setUserData(UserModel user) {
    _prefs.setString('user-data', jsonEncode(user.toJson()));
  }

  String? get accessToken {
    return _prefs.getString('access-token');
  }

  void setAccessToken(String token) {
    _prefs.setString('access-token', token);
  }

  String? get refreshToken {
    return _prefs.getString('refresh-token');
  }

  void setRefreshToken(String token) {
    _prefs.setString('refresh-token', token);
  }

  void setTokens(String accessToken, String refreshToken) {
    _prefs.setString('access-token', accessToken);
    _prefs.setString('refresh-token', refreshToken);
  }

  void clearTokens() {
    _prefs.remove('access-token');
    _prefs.remove('refresh-token');
  }

  bool get isLoggedIn {
    return _prefs.getBool('is-user-logged-in') ?? false;
  }

  void setIsUserLoggedIn(bool value) {
    _prefs.setBool('is-user-logged-in', value);
  }

  List<Map<String, dynamic>> getOfflineUnSubmittedExams() {
    final String? examsData = _prefs.getString('pending_exams');
    if (examsData != null) {
      List<dynamic> examList = jsonDecode(examsData);
      return examList.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      return [];
    }
  }

  Future<void> storeExamOffline(Map<String, dynamic> examData) async {
    final String? storedExams = _prefs.getString('pending_exams');
    List<Map<String, dynamic>> pendingExams = [];

    if (storedExams != null) {
      List<dynamic> decodedList = jsonDecode(storedExams);
      pendingExams =
          decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    pendingExams.add(examData);

    pendingExams = pendingExams.toSet().toList();
    await _prefs.setString('pending_exams', jsonEncode(pendingExams));
  }

  void removeSingleExamFromStorage(Map<String, dynamic> data) {
    List<Map<String, dynamic>> items = getOfflineUnSubmittedExams();
    items.removeWhere((e) => e['questionId'] == data['questionId']);
    _prefs.setString('pending_exams', jsonEncode(items));
  }

  void clearStorage() {
    _prefs.clear();
  }
}
