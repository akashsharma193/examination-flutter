import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:offline_test_app/app_models/app_user_model.dart';

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
      return UserModel.toEmpty(); // Return an empty or default UserModel
    }
  }

  void setUserData(UserModel user) {
    _prefs.setString('user-data', jsonEncode(user.toJson()));
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
    // Retrieve the stored exams
    final String? storedExams = _prefs.getString('pending_exams');
    List<Map<String, dynamic>> pendingExams = [];

    if (storedExams != null) {
      List<dynamic> decodedList = jsonDecode(storedExams);
      pendingExams =
          decodedList.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    // Add the new exam data
    pendingExams.add(examData);

    // Remove duplicates (if any) and store back
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
