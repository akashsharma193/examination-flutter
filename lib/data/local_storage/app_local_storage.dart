import 'package:hive/hive.dart';
import 'package:offline_test_app/app_models/app_user_model.dart';
import 'package:path_provider/path_provider.dart';

class AppLocalStorage {
  static final AppLocalStorage instance = AppLocalStorage._();
  AppLocalStorage._();
  factory AppLocalStorage() {
    return instance;
  }
  late Box box;
  Future<void> initAppLocalStorage() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDirectory.path);
    openBox();
  }

  void openBox() async {
    box = await Hive.openBox('offline_test_app');
  }

  UserModel get user {
    return UserModel.fromJson(box.get('user-data') ?? {});
  }

  void setUserData(UserModel user) {
    box.put('user-data', user.toJson());
  }

  bool get isLoggedIn {
    return box.get('is-user-logged-in') ?? false;
  }

  void setIsUserLoggedIn(bool value) {
    box.put('is-user-logged-in', value);
  }
}
