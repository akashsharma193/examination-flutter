import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/controllers/user_list_controller.dart';
import 'package:offline_test_app/core/constants/app_result.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/admin_repo.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';
import 'package:offline_test_app/screens/active_exams_screen.dart';
import 'package:offline_test_app/screens/admin_screen/admin_exam_dashboard.dart';
import 'package:offline_test_app/screens/admin_screen/e_resource_screen.dart';
import 'package:offline_test_app/screens/admin_screen/user_list_screen.dart';
import 'package:offline_test_app/screens/admin_screen/view_exam_details.dart';
import 'package:offline_test_app/screens/exam_history_screen.dart';
import 'package:offline_test_app/screens/network_log_screen.dart';

T getController<T>(T Function() f) {
  if (Get.isRegistered<T>()) {
    return Get.find<T>();
  } else {
    return Get.put(f());
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final List<String> sidebarItems = [
    "Dashboard",
    "Students",
    "Past Exams",
    "Create Exam",
    "Network Log",
  ];

  final AuthRepo authRepo = AuthRepo();
  final userListController =
      getController<UserListController>(() => UserListController());
  final examHistoryController =
      getController<ExamHistoryController>(() => ExamHistoryController());
  RxMap<String, dynamic> basicData = RxMap();
  AdminRepo repo = AdminRepo();

  getHomeBasicData() {
    repo.getReportCount(AppLocalStorage.instance.user.orgCode).then((v) {
      switch (v) {
        case AppSuccess(value: Map<String, dynamic> v):
          basicData.value = v;
          break;
        case AppFailure():
          basicData.value = {};
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getHomeBasicData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: AppColors.appBar,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email :' + AppLocalStorage.instance.user.email,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              Text(
                'Name :' + AppLocalStorage.instance.user.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              Text(
                'Organization : ' + AppLocalStorage.instance.user.orgCode,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Divider(),
          ...List.generate(sidebarItems.length, (index) {
            return _buildSidebarItem(
              icon: _getIconForIndex(index),
              title: sidebarItems[index],
              selected: selectedIndex == index,
              onTap: () {
                if (index == 0) {
                  getHomeBasicData();
                }
                if (index == 1) {
                  userListController
                      .fetchUsers(AppLocalStorage.instance.user.orgCode);
                } else if (index == 2) {
                  examHistoryController.setup(
                      userId: null, showActiveExam: false);
                }
                setState(() {
                  selectedIndex = index;
                });
              },
            );
          }),
          SizedBox(
            height: 20,
          ),
          _buildSidebarItem(
            icon: Icons.logout,
            title: "Logout",
            onTap: () async {
              try {
                await authRepo.logOut(
                    userId: AppLocalStorage.instance.user.userId);
                AppLocalStorage.instance.clearStorage();
                Get.offAllNamed('/login');
              } catch (e) {
                debugPrint("Logout error: $e");
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.dashboard;
      case 1:
        return Icons.people;
      case 2:
        return Icons.assignment;
      case 3:
        return Icons.add_circle_outline;
      default:
        return Icons.bug_report;
    }
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: selected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBar,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        "Admin Panel",
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardView();
      case 1:
        return UserListScreen(); // Replace with actual widget
      case 2:
        return PastExamScreen(); // Replace with actual widget
      case 3:
        return AdminExamDashboard();
      case 4:
        return const NetworkLogScreen();
      case 5:
        return ActiveExamScreen();
      case 6:
        return EResourceScreen();
      default:
        return const Center(child: Text("Invalid selection"));
    }
  }

  Widget _buildDashboardView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Overview",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                return Obx(
                  () => GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildCard("All Students", "${basicData['userCount']}",
                          Icons.people, onTap: () {
                        setState(() => selectedIndex = 1);
                      }),
                      _buildCard("Past Exams", "${basicData['pastExamCount']}",
                          Icons.assignment, onTap: () {
                        setState(() => selectedIndex = 2);
                      }),
                      _buildCard(
                          "Active Exam",
                          "${basicData['activeExamCount']}",
                          Icons.timer, onTap: () {
                        setState(() => selectedIndex = 5);
                      }),
                      _buildCard("E Resource", "", Icons.timer, onTap: () {
                        setState(() => selectedIndex = 6);
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.dialogBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: AppColors.textPrimary),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 5),
            Text(count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                )),
          ],
        ),
      ),
    );
  }
}
