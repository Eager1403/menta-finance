import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../invoices/invoice_service.dart';
import '../../invoices/models/invoice_model.dart';
import '../client_service.dart';
import '../models/client_model.dart';

class ClientDetailController extends GetxController {
  final ClientService _clientService;
  final InvoiceService _invoiceService;
  final int clientId;

  ClientDetailController(this._clientService, this._invoiceService, {required this.clientId});

  final isLoading = true.obs;
  final errorMessage = RxnString();
  final detail = Rxn<ClientDetailModel>();

  final isLoadingInvoices = true.obs;
  final invoices = <InvoiceModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDetail();
    loadInvoices();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      detail.value = await _clientService.getDetail(clientId);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia taarifa za client.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInvoices() async {
    isLoadingInvoices.value = true;
    try {
      invoices.assignAll(await _invoiceService.getByClient(clientId));
    } catch (_) {
      // si hatari kubwa - Invoices zinaweza kupakiwa upya baadaye
    } finally {
      isLoadingInvoices.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([loadDetail(), loadInvoices()]);
  }
}
