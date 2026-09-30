import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/web_download.dart';
import '../invoice_service.dart';
import '../models/invoice_model.dart';

class InvoiceListController extends GetxController {
  final InvoiceService _service;
  InvoiceListController(this._service);

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final invoices = <InvoiceModel>[].obs;
  final searchText = ''.obs;

  List<InvoiceModel> get filtered {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return invoices;
    return invoices
        .where((i) =>
            i.invoiceNumber.toLowerCase().contains(q) || (i.clientName ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      invoices.assignAll(await _service.getAll());
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia Invoices.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadPdf(InvoiceModel invoice) async {
    try {
      final bytes = await _service.getPdfBytes(invoice.id);
      downloadBytesAsFile(bytes, 'invoice-${invoice.invoiceNumber}.pdf');
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Hitilafu', 'Imeshindikana kupakua PDF.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteInvoice(int id) async {
    try {
      await _service.delete(id);
      Get.snackbar('Imefanikiwa', 'Invoice imefutwa.', snackPosition: SnackPosition.BOTTOM);
      loadInvoices();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> recordPayment(
    int invoiceId, {
    required double amount,
    DateTime? paymentDate,
    String? paymentMethod,
    String? referenceNo,
  }) async {
    try {
      await _service.recordPayment(invoiceId,
          amount: amount, paymentDate: paymentDate, paymentMethod: paymentMethod, referenceNo: referenceNo);
      Get.snackbar('Imefanikiwa', 'Malipo yameongezwa.', snackPosition: SnackPosition.BOTTOM);
      loadInvoices();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
