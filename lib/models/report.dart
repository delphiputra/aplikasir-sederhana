class Report {
  final int id;
  final double totalIncome;
  final String generatedAt;

  Report({required this.id, required this.totalIncome, required this.generatedAt});

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      totalIncome: json['total_income'],
      generatedAt: json['generated_at'],
    );
  }
}
