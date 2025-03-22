import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/user_list_controller.dart';
import 'package:offline_test_app/core/constants/color_constants.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                child: Text(controller.errorMessage.value,
                    style: TextStyle(color: AppColors.error)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              final user = controller.users[index];
              return Card(
                color: AppColors.cardBackground,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
                  title: Text(user.name,
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${user.email}',
                          style: TextStyle(color: AppColors.textPrimary)),
                      Text('Batch: ${user.batch}',
                          style: TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit),
                      Icon(
                        Icons.info_outline,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
