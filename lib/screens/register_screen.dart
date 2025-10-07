import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:crackitx/controllers/auth_controller.dart';
import 'package:crackitx/widgets/app_text_field.dart';
import 'package:crackitx/widgets/app_back_button.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _orgFocusNode = FocusNode();
  final FocusNode _batchFocusNode = FocusNode();

  void _submitForm(AppAuthController authController) {
    if (_formKey.currentState!.validate()) {
      authController.register();
    }
  }

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AppAuthController>();
    authController.fetchOrganizations();

    _orgFocusNode.addListener(() {
      authController.showOrgDropdown.value = _orgFocusNode.hasFocus;
    });

    _batchFocusNode.addListener(() {
      authController.showBatchDropdown.value = _batchFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _orgFocusNode.dispose();
    _batchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AppAuthController>();

    const purple = Color(0xFF7460F1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          authController.showOrgDropdown.value = false;
          authController.showBatchDropdown.value = false;
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/splash_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.topLeft,
                            child: AppBackButton(onTap: () {
                              Get.back();
                            }),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Card(
                                color: Colors.white,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0, vertical: 24),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "REGISTER",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 26,
                                            color: Colors.black,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 24),
                                        AppTextField(
                                          controller:
                                              authController.nameController,
                                          hintText: 'Name',
                                          prefixIcon: const Icon(Icons.person,
                                              color: purple),
                                          type: TextFieldType.text,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Name is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        AppTextField(
                                          controller:
                                              authController.mobileController,
                                          hintText: 'Number',
                                          prefixIcon: const Icon(Icons.phone,
                                              color: purple),
                                          type: TextFieldType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Number is required';
                                            }
                                            if (value.length < 10) {
                                              return 'Enter a valid phone number';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        AppTextField(
                                          controller: authController
                                              .registerEmailController,
                                          hintText: 'Email',
                                          prefixIcon: const Icon(Icons.email,
                                              color: purple),
                                          type: TextFieldType.email,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Email is required';
                                            }
                                            if (!value.isEmail) {
                                              return 'Enter a valid email';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        _buildOrganizationDropdown(
                                            authController, purple),
                                        const SizedBox(height: 16),
                                        _buildBatchDropdown(
                                            authController, purple),
                                        const SizedBox(height: 16),
                                        AppTextField(
                                          controller: authController
                                              .registerPassController,
                                          hintText: 'Password',
                                          prefixIcon: const Icon(Icons.lock,
                                              color: purple),
                                          type: TextFieldType.password,
                                          validator: (value) => authController
                                              .validatePassword(value ?? ''),
                                        ),
                                        const SizedBox(height: 16),
                                        AppTextField(
                                          controller: authController
                                              .confirmPassController,
                                          hintText: 'Confirm Password',
                                          prefixIcon: const Icon(Icons.lock,
                                              color: purple),
                                          type: TextFieldType.password,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Confirm password is required';
                                            }
                                            if (value !=
                                                authController
                                                    .registerPassController
                                                    .text) {
                                              return 'Passwords do not match';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 28),
                                        Obx(() => Material(
                                              elevation: 2,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                onTap: authController
                                                        .isRegisterLoading.value
                                                    ? null
                                                    : () => _submitForm(
                                                        authController),
                                                child: Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 16),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        purple,
                                                        purple.withOpacity(0.7)
                                                      ],
                                                      begin:
                                                          Alignment.centerLeft,
                                                      end:
                                                          Alignment.centerRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  child: Center(
                                                    child: authController
                                                            .isRegisterLoading
                                                            .value
                                                        ? const CircularProgressIndicator
                                                            .adaptive(
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Colors
                                                                        .white))
                                                        : const Text(
                                                            'Submit',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationDropdown(
      AppAuthController authController, Color purple) {
    return Column(
      children: [
        Obx(() => AppTextField(
              controller: authController.orgSearchController,
              hintText: 'Search Organization',
              prefixIcon: Icon(Icons.apartment_outlined, color: purple),
              suffixIcon: authController.isLoadingOrgs.value
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: purple),
                      ),
                    )
                  : Icon(Icons.arrow_drop_down, color: purple),
              type: TextFieldType.text,
              focusNode: _orgFocusNode,
              readOnly: false,
              onChanged: (value) {
                authController.filterOrganizations(value);
                authController.showOrgDropdown.value = true;
              },
              onTap: () {
                authController.showOrgDropdown.value = true;
                authController.showBatchDropdown.value = false;
              },
              validator: (value) {
                if (authController.selectedOrgCode.value.isEmpty) {
                  return 'Organization is required';
                }
                return null;
              },
            )),
        Obx(() {
          if (authController.showOrgDropdown.value &&
              authController.filteredOrganizations.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: authController.filteredOrganizations.length,
                itemBuilder: (context, index) {
                  final org = authController.filteredOrganizations[index];
                  return InkWell(
                    onTap: () {
                      authController.selectOrganization(org);
                      authController.showOrgDropdown.value = false;
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            org['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            org['description'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildBatchDropdown(AppAuthController authController, Color purple) {
    return Column(
      children: [
        Obx(() => AppTextField(
              controller: authController.batchSearchController,
              hintText: 'Search Batch',
              prefixIcon: Icon(Icons.people, color: purple),
              suffixIcon: authController.isLoadingBatches.value
                  ? Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: purple),
                      ),
                    )
                  : Icon(Icons.arrow_drop_down, color: purple),
              type: TextFieldType.text,
              focusNode: _batchFocusNode,
              readOnly: false,
              enabled: authController.selectedOrgCode.value.isNotEmpty,
              onChanged: (value) {
                authController.filterBatches(value);
                authController.showBatchDropdown.value = true;
              },
              onTap: () {
                if (authController.selectedOrgCode.value.isNotEmpty) {
                  authController.showBatchDropdown.value = true;
                  authController.showOrgDropdown.value = false;
                }
              },
              validator: (value) {
                if (authController.selectedBatchCode.value.isEmpty) {
                  return 'Batch is required';
                }
                return null;
              },
            )),
        Obx(() {
          if (authController.showBatchDropdown.value &&
              authController.filteredBatches.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: authController.filteredBatches.length,
                itemBuilder: (context, index) {
                  final batch = authController.filteredBatches[index];
                  return InkWell(
                    onTap: () {
                      authController.selectBatch(batch);
                      authController.showBatchDropdown.value = false;
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            batch['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            batch['description'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}
