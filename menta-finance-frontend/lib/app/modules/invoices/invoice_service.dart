import '../../core/network/api_client.dart';
import 'models/invoice_model.dart';

/// Sawa moja kwa moja na com.mentafinance.controller.InvoiceController
class InvoiceService {
  final ApiClient _api;
  InvoiceService(this._api);

  Future<List<InvoiceModel>> getAll() async {
    final data = await _api.get('/api/invoices') as List;
    return data.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InvoiceModel> getById(int id) async {
    final data = await _api.get('/api/invoices/$id');
    return InvoiceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<InvoiceModel>> getByClient(int clientId) async {
    final data = await _api.get('/api/invoices/client/$clientId') as List;
    return data.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  String _isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<InvoiceModel> create({
    required int clientId,
    int? projectId,
    DateTime? issueDate,
    DateTime? dueDate,
    required List<InvoiceItemModel> items,
    double discount = 0,
    double taxPercent = 0,
    String? notes,
    double initialAmountPaid = 0,
    String? initialPaymentMethod,
  }) async {
    final data = await _api.post('/api/invoices', body: {
      'clientId': clientId,
      if (projectId != null) 'projectId': projectId,
      if (issueDate != null) 'issueDate': _isoDate(issueDate),
      if (dueDate != null) 'dueDate': _isoDate(dueDate),
      'items': items.map((i) => i.toRequestJson()).toList(),
      'discount': discount,
      'taxPercent': taxPercent,
      if (notes != null) 'notes': notes,
      'initialAmountPaid': initialAmountPaid,
      if (initialPaymentMethod != null) 'initialPaymentMethod': initialPaymentMethod,
    });
    return InvoiceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<InvoiceModel> recordPayment(
    int invoiceId, {
    required double amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? referenceNo,
    String? notes,
  }) async {
    final data = await _api.post('/api/invoices/$invoiceId/payments', body: {
      'amount': amount,
      if (paymentDate != null) 'paymentDate': _isoDate(paymentDate),
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (referenceNo != null) 'referenceNo': referenceNo,
      if (notes != null) 'notes': notes,
    });
    return InvoiceModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/api/invoices/$id');

  /// Bytes za PDF halisi (imezalishwa na Backend - InvoicePdfService) -
  /// tumia na core/utils/web_download.dart (downloadBytesAsFile /
  /// openPdfBytesInNewTab) kuipakua au kuiona.
  Future<List<int>> getPdfBytes(int id) => _api.getBytes('/api/invoices/$id/pdf');
}
