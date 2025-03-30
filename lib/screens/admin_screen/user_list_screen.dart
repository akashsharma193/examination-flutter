import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/user_list_controller.dart';
import 'package:offline_test_app/core/constants/app_route_name_constants.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('User List', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.appBar,
      ),
      body: GetBuilder<UserListController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(color: AppColors.error),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Check screen width to determine layout
                if (constraints.maxWidth < 600) {
                  // Mobile layout
                  return _buildMobileUserList(controller);
                } else {
                  // Web layout
                  return _buildWebUserList(controller);
                }
              },
            ),
          );
        },
      ),
    );
  }

  // Mobile Layout
  Widget _buildMobileUserList(UserListController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: List.generate(
            controller.users.length,
            (index) {
              final user = controller.users[index];
              return Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        user.isAdmin ? AppColors.success : AppColors.secondary,
                    child: Icon(
                      user.isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color:
                          user.isAdmin ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email: ${user.email}',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      if (user.batch != null && user.batch!.isNotEmpty)
                        Text(
                          'Batch: ${user.batch}',
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                    ],
                  ),
                  trailing: Icon(Icons.edit, color: AppColors.textPrimary),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Web Layout
  Widget _buildWebUserList(UserListController controller) {
    return SingleChildScrollView(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400, // Maximum card width
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.8, // Card aspect ratio
        ),
        itemCount: controller.users.length,
        itemBuilder: (context, index) {
          final user = controller.users[index];
          return InkWell(
            onTap: () {
              Get.toNamed(AppRoutesNames.examHistory, arguments: {
                'userId': user.userId,
                'title': "${user.name}'s Exam History "
              });
            },
            child: Card(
              color: AppColors.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: user.isAdmin
                              ? AppColors.success
                              : AppColors.secondary,
                          child: Icon(
                            user.isAdmin
                                ? Icons.admin_panel_settings
                                : Icons.person,
                            color: user.isAdmin
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          user.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Email: ${user.email}',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    if (user.batch != null && user.batch!.isNotEmpty)
                      Text(
                        'Batch: ${user.batch}',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    // const Spacer(),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                          onPressed: () {
                            Get.toNamed(AppRoutesNames.editUserScreen,
                                arguments: {"user": user});
                          },
                          icon: Icon(Icons.edit, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
