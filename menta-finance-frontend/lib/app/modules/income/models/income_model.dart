/// Sawa na entity.enums.IncomeSource
enum IncomeSourceX { manual, invoicePayment }

IncomeSourceX incomeSourceFromString(String? s) =>
    s == 'INVOICE_PAYMENT' ? IncomeSourceX.invoicePayment : IncomeSourceX.manual;

String incomeSourceLabel(IncomeSourceX s) =>
    s == IncomeSourceX.invoicePayment ? 'Malipo ya Invoice' : 'Imeongezwa Mkono';

/// Sawa na IncomeResponse ya backend
class IncomeModel {
  final int id;
  final int projectId;
  final String? projectName;
  final String? description;
  final double amount;
  final DateTime? incomeDate;
  final String? paymentMethod;
  final IncomeSourceX sourceType;

  IncomeModel({
    required this.id,
    required this.projectId,
    this.projectName,
    this.description,
    required this.amount,
    this.incomeDate,
    this.paymentMethod,
    required this.sourceType,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> j) => IncomeModel(
        id: j['id'] as int,
        projectId: j['projectId'] as int,
        projectName: j['projectName'] as String?,
        description: j['description'] as String?,
        amount: double.tryParse(j['amount'].toString()) ?? 0,
        incomeDate: j['incomeDate'] != null ? DateTime.tryParse(j['incomeDate'] as String) : null,
        paymentMethod: j['paymentMethod'] as String?,
        sourceType: incomeSourceFromString(j['sourceType'] as String?),
      );

  /// Income inayotoka kwenye malipo ya Invoice HAIWEZI kuhaririwa moja
  /// kwa moja kwenye ukurasa huu (angalia backend - IncomeSource).
  bool get isEditable => sourceType == IncomeSourceX.manual;
}
