class UserModel {
  String name;
  String mobile;
  String email;
  String batch;
  String? password;
  String orgCode;
  String userId;
  bool isActive;
  bool isAdmin; // New field

  UserModel({
    required this.name,
    required this.mobile,
    required this.email,
    required this.batch,
    this.password,
    required this.orgCode,
    required this.userId,
    required this.isActive,
    required this.isAdmin, // Required in constructor
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
      isAdmin: json['isAdmin'] ?? false, // Default to false if missing
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
      'isAdmin': isAdmin, // Added to JSON output
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
      isAdmin: false, // Default empty user is not an admin
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, mobile: $mobile, email: $email, batch: $batch, password: $password, orgCode: $orgCode, userId: $userId, isActive: $isActive, isAdmin: $isAdmin)';
  }
}
