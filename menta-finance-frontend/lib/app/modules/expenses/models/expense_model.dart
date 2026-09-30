/// Sawa na ExpenseResponse ya backend
class ExpenseModel {
  final int id;
  final int projectId;
  final String? projectName;
  final String? description;
  final double amount;
  final DateTime? expenseDate;
  final String? category;

  ExpenseModel({
    required this.id,
    required this.projectId,
    this.projectName,
    this.description,
    required this.amount,
    this.expenseDate,
    this.category,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> j) => ExpenseModel(
        id: j['id'] as int,
        projectId: j['projectId'] as int,
        projectName: j['projectName'] as String?,
        description: j['description'] as String?,
        amount: double.tryParse(j['amount'].toString()) ?? 0,
        expenseDate: j['expenseDate'] != null ? DateTime.tryParse(j['expenseDate'] as String) : null,
        category: j['category'] as String?,
      );
}
