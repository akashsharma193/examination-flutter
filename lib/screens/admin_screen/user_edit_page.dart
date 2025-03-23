import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:offline_test_app/controllers/edit_user_detail_controller.dart';
import 'package:offline_test_app/core/constants/color_constants.dart'; // Import the color constants

class EditUserScreen extends StatelessWidget {
  final EditUserDetailController controller =
      Get.put(EditUserDetailController());

  EditUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User Details',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.appBar, // Dark Brown
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildMobileForm(controller);
              } else {
                return Center(
                  child: SizedBox(
                    width: 600,
                    child: _buildWebForm(controller),
                  ),
                );
              }
            },
          ),
        );
      }),
    );
  }

  // Mobile Form
  Widget _buildMobileForm(EditUserDetailController controller) {
    return Column(
      children: [
        _buildTextField('Name', controller.nameController),
        _buildTextField('Mobile', controller.mobileController),
        _buildTextField('Email', controller.emailController),
        _buildTextField('Batch', controller.batchController),
        _buildTextField('Password', controller.passwordController,
            isPassword: true),
        _buildTextField('Org Code', controller.orgCodeController),
        _buildSwitch('Is Active', controller.isActive),
        _buildSwitch('Is Admin', controller.isAdmin),
        const SizedBox(height: 20),
        _buildSaveButton(controller),
      ],
    );
  }

  // Web Form
  Widget _buildWebForm(EditUserDetailController controller) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Name', controller.nameController)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Mobile', controller.mobileController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField('Email', controller.emailController)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildTextField('Batch', controller.batchController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildTextField(
                    'Password', controller.passwordController,
                    isPassword: true)),
            const SizedBox(width: 16),
            Expanded(
                child:
                    _buildTextField('Org Code', controller.orgCodeController)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSwitch('Is Active', controller.isActive)),
            const SizedBox(width: 16),
            Expanded(child: _buildSwitch('Is Admin', controller.isAdmin)),
          ],
        ),
        const SizedBox(height: 20),
        _buildSaveButton(controller),
      ],
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textPrimary), // Deep Brown
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border), // Grey border
          ),
          filled: true,
          fillColor: AppColors.inputBackground, // Light Grey
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.primary), // Brown border
          ),
        ),
      ),
    );
  }

  // Reusable Switch Widget
  Widget _buildSwitch(String label, RxBool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary, // Deep Brown
            ),
          ),
          const Spacer(),
          Obx(
            () => Switch(
              value: value.value,
              onChanged: (newValue) {
                value.value = newValue;
              },
              activeColor: AppColors.primary, // Brown
              activeTrackColor: AppColors.secondary, // Light Beige
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Save Button Widget
  Widget _buildSaveButton(EditUserDetailController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.updateUserDetails,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.button, // Warm Tan
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary, // Deep Brown
          ),
        ),
      ),
    );
  }
}
