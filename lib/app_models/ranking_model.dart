class RankingModel {
  final String userId;
  final String name;
  final String email;
  final int marks;
  final int totalMarks;
  final int ranking;
  final double percentage;

  RankingModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.marks,
    required this.totalMarks,
    required this.ranking,
    required this.percentage,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    final marks = json['marks'] ?? 0;
    final totalMarks = json['totalMarks'] ?? 0;
    final percentage = totalMarks > 0 ? (marks / totalMarks) * 100 : 0.0;

    return RankingModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      marks: marks,
      totalMarks: totalMarks,
      ranking: json['ranking'] ?? 0,
      percentage: percentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'marks': marks,
      'totalMarks': totalMarks,
      'ranking': ranking,
      'percentage': percentage,
    };
  }

  RankingModel copyWith({
    String? userId,
    String? name,
    String? email,
    int? marks,
    int? totalMarks,
    int? ranking,
    double? percentage,
  }) {
    return RankingModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      marks: marks ?? this.marks,
      totalMarks: totalMarks ?? this.totalMarks,
      ranking: ranking ?? this.ranking,
      percentage: percentage ?? this.percentage,
    );
  }
}
