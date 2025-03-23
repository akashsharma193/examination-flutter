import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/exam_history_controller.dart';
import 'package:offline_test_app/core/constants/app_route_name_constants.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';
import 'package:offline_test_app/data/local_storage/app_local_storage.dart';
import 'package:offline_test_app/repositories/auth_repo.dart';
import 'package:offline_test_app/screens/network_log_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
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
            );
          } else {
            return Column(
              children: [
                _buildAppBar(),
                Expanded(child: _buildMainContent()),
              ],
            );
          }
        },
      ),
      drawer: MediaQuery.of(context).size.width <= 600
          ? Drawer(child: _buildSidebar())
          : null,
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: isSidebarExpanded ? 250 : 70,
      color: AppColors.appBar,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isSidebarExpanded = !isSidebarExpanded;
              });
            },
            child: Icon(
              isSidebarExpanded
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20),
          _buildSidebarItem(Icons.dashboard, "Dashboard"),
          _buildSidebarItem(Icons.people, "Students"),
          _buildSidebarItem(Icons.assignment, "Exams"),
          _buildSidebarItem(Icons.settings, "Settings"),
          _buildSidebarItem(Icons.settings, "Network Log", onTap: () {
            Get.to(() => const NetworkLogScreen());
          }),
          Spacer(),
          _buildSidebarItem(Icons.logout, "Logout", onTap: () {
            try {
              final AuthRepo repo = AuthRepo();
              repo.logOut(userId: AppLocalStorage.instance.user.userId);
              AppLocalStorage.instance.clearStorage();
              Get.offAllNamed('/login');
            } catch (e) {
              debugPrint("error in logout admin home : $e");
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            if (isSidebarExpanded) ...[
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.appBar,
      automaticallyImplyLeading: !AppLocalStorage.instance.user.isAdmin,
      title: Text("Dashboard",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      actions: [
        CircleAvatar(
          backgroundColor: AppColors.button,
          child: Icon(Icons.person, color: Colors.white),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Overview",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildCard("Total Students", "120", Icons.people,
                        onTap: () {
                      Get.toNamed(AppRoutesNames.userList);
                    }),
                    _buildCard("Total Exams", "15", Icons.assignment,
                        onTap: () {
                      Get.delete<ExamHistoryController>();
                      Get.toNamed(AppRoutesNames.examHistory);
                    }),
                    _buildCard("Active Exams", "5", Icons.timer, onTap: () {}),
                  ],
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
        padding: EdgeInsets.all(16),
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
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            SizedBox(height: 5),
            Text(count,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
