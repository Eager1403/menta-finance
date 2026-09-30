import 'dart:typed_data';

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/web_download.dart';
import '../models/report_models.dart';
import '../models/service_performance_month_model.dart';
import '../report_data_service.dart';
import '../reports_service.dart';
import '../widgets/report_pdf_builder.dart';

class ReportsController extends GetxController {
  final ReportsService _service;
  final ReportDataService _data;
  ReportsController(this._service, this._data);

  // ---- Ripoti za PDF ----
  /// Ripoti inayotengenezwa kwa sasa (null = hakuna)
  final generating = Rxn<ReportKind>();
  final periodChoice = PeriodChoice.thisMonth.obs;
  final customRange = Rxn<DateTimeRange>();

  // ---- Kumbukumbu za mfumo (snapshots) ----
  final isLoading = true.obs;
  final errorMessage = RxnString();
  final rows = <ServicePerformanceMonthModel>[].obs;
  final monthsBack = 6.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // -------------------------------------------------------------------
  //  Kipindi cha Ripoti ya Fedha
  // -------------------------------------------------------------------
  ReportPeriod resolvePeriod() {
    final now = DateTime.now();
    final fmt = DateFormat('dd/MM/yyyy');

    switch (periodChoice.value) {
      case PeriodChoice.thisMonth:
        return ReportPeriod(
          label: monthLabelSw(now),
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0),
        );
      case PeriodChoice.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        return ReportPeriod(
          label: monthLabelSw(lastMonthStart),
          start: lastMonthStart,
          end: DateTime(now.year, now.month, 0),
        );
      case PeriodChoice.last3Months:
        final threeMonthsStart = DateTime(now.year, now.month - 2, 1);
        return ReportPeriod(
          label: '${monthLabelSw(threeMonthsStart)} - ${monthLabelSw(now)}',
          start: threeMonthsStart,
          end: DateTime(now.year, now.month + 1, 0),
        );
      case PeriodChoice.thisYear:
        return ReportPeriod(
          label: 'Mwaka ${now.year}',
          start: DateTime(now.year, 1, 1),
          end: DateTime(now.year, 12, 31),
        );
      case PeriodChoice.allTime:
        return const ReportPeriod(label: 'Muda wote');
      case PeriodChoice.custom:
        final range = customRange.value;
        if (range == null) return const ReportPeriod(label: 'Muda wote');
        return ReportPeriod(
          label: '${fmt.format(range.start)} - ${fmt.format(range.end)}',
          start: range.start,
          end: range.end,
        );
    }
  }

  // -------------------------------------------------------------------
  //  Kutengeneza PDF (preview au download)
  // -------------------------------------------------------------------
  Future<void> generate(ReportKind kind, {required bool download}) async {
    if (generating.value != null) return;
    generating.value = kind;

    try {
      final stamp = DateFormat('yyyyMMdd').format(DateTime.now());
      Uint8List bytes = Uint8List(0);
      String fileName = 'ripoti-$stamp.pdf';

      switch (kind) {
        case ReportKind.financial:
          final financialData = await _data.buildFinancial(resolvePeriod());
          bytes = await ReportPdfBuilder.financial(financialData);
          fileName = 'ripoti-ya-fedha-$stamp.pdf';
          break;
        case ReportKind.projects:
          final projectsData = await _data.buildProjectPerformance();
          bytes = await ReportPdfBuilder.projects(projectsData);
          fileName = 'utendaji-wa-projects-$stamp.pdf';
          break;
        case ReportKind.clients:
          final clientsData = await _data.buildClients();
          bytes = await ReportPdfBuilder.clients(clientsData);
          fileName = 'clients-na-madeni-$stamp.pdf';
          break;
        case ReportKind.serviceHistory:
          final historyData = await _data.buildServiceHistory(monthsBack.value);
          bytes = await ReportPdfBuilder.serviceHistory(historyData, monthsBack.value);
          fileName = 'utendaji-wa-services-$stamp.pdf';
          break;
      }

      if (download) {
        downloadBytesAsFile(bytes, fileName);
        Get.snackbar('Imefanikiwa', 'Ripoti imepakuliwa: $fileName', snackPosition: SnackPosition.BOTTOM);
      } else {
        openPdfBytesInNewTab(bytes);
      }
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Hitilafu', 'Imeshindikana kutengeneza ripoti: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      generating.value = null;
    }
  }

  // -------------------------------------------------------------------
  //  Kumbukumbu za mfumo (snapshots)
  // -------------------------------------------------------------------
  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      rows.assignAll(await _service.getServicePerformance(monthsBack: monthsBack.value));
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Imeshindikana kupakia kumbukumbu.';
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonthsBack(int value) {
    monthsBack.value = value;
    load();
  }

  Future<void> regenerate(String month) async {
    try {
      await _service.regenerateSnapshot(month);
      Get.snackbar('Imefanikiwa', 'Snapshot ya $month imetengenezwa upya.', snackPosition: SnackPosition.BOTTOM);
      load();
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
