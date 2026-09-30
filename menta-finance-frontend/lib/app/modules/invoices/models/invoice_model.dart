/// Sawa na InvoiceItemResponse/InvoiceItemRequest ya backend
class InvoiceItemModel {
  final int? id;
  final String description;
  final double qty;
  final double unitPrice;
  final double amount;

  InvoiceItemModel({
    this.id,
    required this.description,
    required this.qty,
    required this.unitPrice,
    this.amount = 0,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> j) => InvoiceItemModel(
        id: j['id'] as int?,
        description: j['description'] as String? ?? '',
        qty: double.tryParse(j['qty'].toString()) ?? 0,
        unitPrice: double.tryParse(j['unitPrice'].toString()) ?? 0,
        amount: double.tryParse(j['amount'].toString()) ?? 0,
      );

  /// Kwa InvoiceItemRequest - id/amount HAVITUMWI (backend inahesabu amount)
  Map<String, dynamic> toRequestJson() => {
        'description': description,
        'qty': qty,
        'unitPrice': unitPrice,
      };
}

/// Sawa na InvoicePaymentResponse
class InvoicePaymentModel {
  final int id;
  final double amount;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? referenceNo;

  InvoicePaymentModel({
    required this.id,
    required this.amount,
    this.paymentDate,
    this.paymentMethod,
    this.referenceNo,
  });

  factory InvoicePaymentModel.fromJson(Map<String, dynamic> j) => InvoicePaymentModel(
        id: j['id'] as int,
        amount: double.tryParse(j['amount'].toString()) ?? 0,
        paymentDate: j['paymentDate'] != null ? DateTime.tryParse(j['paymentDate'] as String) : null,
        paymentMethod: j['paymentMethod'] as String?,
        referenceNo: j['referenceNo'] as String?,
      );
}

/// Sawa na InvoiceStatus enum ya backend
enum InvoiceStatusX { draft, sent, partial, paid, overdue, cancelled }

InvoiceStatusX invoiceStatusFromString(String? s) {
  switch (s) {
    case 'DRAFT':
      return InvoiceStatusX.draft;
    case 'SENT':
      return InvoiceStatusX.sent;
    case 'PARTIAL':
      return InvoiceStatusX.partial;
    case 'PAID':
      return InvoiceStatusX.paid;
    case 'OVERDUE':
      return InvoiceStatusX.overdue;
    case 'CANCELLED':
      return InvoiceStatusX.cancelled;
    default:
      return InvoiceStatusX.draft;
  }
}

String invoiceStatusLabel(InvoiceStatusX s) {
  switch (s) {
    case InvoiceStatusX.draft:
      return 'Draft';
    case InvoiceStatusX.sent:
      return 'Imetumwa';
    case InvoiceStatusX.partial:
      return 'Malipo Kiasi';
    case InvoiceStatusX.paid:
      return 'Imelipwa';
    case InvoiceStatusX.overdue:
      return 'Imechelewa';
    case InvoiceStatusX.cancelled:
      return 'Imeghairiwa';
  }
}

/// Sawa na InvoiceResponse ya backend
class InvoiceModel {
  final int id;
  final String invoiceNumber;
  final int clientId;
  final String? clientName;
  final int? projectId;
  final String? projectName;
  final DateTime? issueDate;
  final DateTime? dueDate;
  final double subtotal;
  final double discount;
  final double taxPercent;
  final double taxAmount;
  final double total;
  final double amountPaid;
  final double balanceDue;
  final InvoiceStatusX status;
  final String? notes;
  final List<InvoiceItemModel> items;
  final List<InvoicePaymentModel> payments;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    this.clientName,
    this.projectId,
    this.projectName,
    this.issueDate,
    this.dueDate,
    required this.subtotal,
    required this.discount,
    required this.taxPercent,
    required this.taxAmount,
    required this.total,
    required this.amountPaid,
    required this.balanceDue,
    required this.status,
    this.notes,
    required this.items,
    required this.payments,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> j) => InvoiceModel(
        id: j['id'] as int,
        invoiceNumber: j['invoiceNumber'] as String? ?? '',
        clientId: j['clientId'] as int,
        clientName: j['clientName'] as String?,
        projectId: j['projectId'] as int?,
        projectName: j['projectName'] as String?,
        issueDate: j['issueDate'] != null ? DateTime.tryParse(j['issueDate'] as String) : null,
        dueDate: j['dueDate'] != null ? DateTime.tryParse(j['dueDate'] as String) : null,
        subtotal: double.tryParse(j['subtotal'].toString()) ?? 0,
        discount: double.tryParse(j['discount'].toString()) ?? 0,
        taxPercent: double.tryParse(j['taxPercent'].toString()) ?? 0,
        taxAmount: double.tryParse(j['taxAmount'].toString()) ?? 0,
        total: double.tryParse(j['total'].toString()) ?? 0,
        amountPaid: double.tryParse(j['amountPaid'].toString()) ?? 0,
        balanceDue: double.tryParse(j['balanceDue'].toString()) ?? 0,
        status: invoiceStatusFromString(j['status'] as String?),
        notes: j['notes'] as String?,
        items: (j['items'] as List? ?? [])
            .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        payments: (j['payments'] as List? ?? [])
            .map((e) => InvoicePaymentModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
