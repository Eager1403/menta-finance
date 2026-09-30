import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/utils/money_fmt.dart';
import '../models/report_models.dart';
import '../models/service_performance_month_model.dart';

class _Logo {
  final pw.MemoryImage image;
  final double aspect; // upana / urefu
  _Logo(this.image, this.aspect);
}

class _Kpi {
  final String label;
  final String value;
  final PdfColor color;
  _Kpi(this.label, this.value, this.color);
}

/// Inatengeneza ripoti za PDF (kwa kutumia data iliyokusanywa na
/// ReportDataService). Muundo na rangi vinafuata invoice ya Menta Studio:
/// logo juu kushoto, kichwa cha ripoti kijani kulia, mstari wa kijani,
/// jedwali zenye kichwa cha kijani, na footer yenye namba ya ukurasa.
///
/// NB: tunatumia herufi za ASCII/Latin-1 pekee (fonti ya kawaida ya PDF
/// haina baadhi ya alama maalum kama bullet).
class ReportPdfBuilder {
  ReportPdfBuilder._();

  static final PdfColor _green = PdfColor.fromInt(0xFF16A34A);
  static final PdfColor _greenTint = PdfColor.fromInt(0xFFDCFCE7);
  static final PdfColor _navy = PdfColor.fromInt(0xFF0F172A);
  static final PdfColor _gray = PdfColor.fromInt(0xFF64748B);
  static final PdfColor _line = PdfColor.fromInt(0xFFE2E8F0);
  static final PdfColor _bg = PdfColor.fromInt(0xFFF8FAFC);
  static final PdfColor _red = PdfColor.fromInt(0xFFDC2626);

  static final DateFormat _dateFmt = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFmt = DateFormat('dd/MM/yyyy HH:mm');

  // ===================================================================
  //  MISINGI: logo, header, footer, vifaa vya kujenga ukurasa
  // ===================================================================

  static Future<_Logo?> _loadLogo() async {
    try {
      final data = await rootBundle.load('assets/images/menta-logo.png');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      // Upana/urefu vipo kwenye PNG header (byte 16-23)
      final w = data.getUint32(16);
      final h = data.getUint32(20);
      final aspect = h == 0 ? 3.0 : w / h;
      return _Logo(pw.MemoryImage(bytes), aspect);
    } catch (_) {
      return null; // logo ikikosekana, tunatumia maandishi
    }
  }

  static pw.TextStyle _ts(double size, {bool bold = false, PdfColor? color}) {
    return pw.TextStyle(
      fontSize: size,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      color: color ?? _navy,
    );
  }

  static Future<Uint8List> _build({
    required String title,
    required String subtitle,
    required List<pw.Widget> Function() body,
    bool landscape = false,
  }) async {
    final logo = await _loadLogo();
    final doc = pw.Document();
    final format = landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    doc.addPage(pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
      header: (ctx) => _header(logo, title, subtitle, ctx.pageNumber == 1),
      footer: (ctx) => _footer(ctx),
      build: (ctx) => body(),
    ));

    return doc.save();
  }

  static pw.Widget _header(_Logo? logo, String title, String subtitle, bool first) {
    final h = first ? 46.0 : 30.0;
    final pw.Widget left = logo != null
        ? pw.SizedBox(
            height: h,
            width: h * logo.aspect,
            child: pw.Image(logo.image, fit: pw.BoxFit.contain),
          )
        : pw.Text('Menta Studio', style: _ts(18, bold: true));

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            left,
            pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(title, style: _ts(first ? 18 : 12, bold: true, color: _green)),
                pw.SizedBox(height: 2),
                pw.Text(subtitle, style: _ts(9, color: _gray)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(height: first ? 2.5 : 1.5, color: _green),
        pw.SizedBox(height: 12),
      ],
    );
  }

  static pw.Widget _footer(pw.Context ctx) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(height: 0.8, color: _navy),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Menta Studio - Menta Finance', style: _ts(8, color: _gray)),
            pw.Text('Ukurasa ${ctx.pageNumber} / ${ctx.pagesCount}', style: _ts(8, color: _gray)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _kpiRow(List<_Kpi> items) {
    final children = <pw.Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i != 0) children.add(pw.SizedBox(width: 8));
      children.add(
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: _bg,
              border: pw.Border.all(color: _line, width: 0.8),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(items[i].label, style: _ts(8, color: _gray)),
                pw.SizedBox(height: 4),
                pw.Text(items[i].value, style: _ts(12, bold: true, color: items[i].color)),
              ],
            ),
          ),
        ),
      );
    }
    return pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  static pw.Widget _section(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 16, bottom: 6),
      child: pw.Row(
        children: [
          pw.Container(width: 3, height: 12, color: _green),
          pw.SizedBox(width: 6),
          pw.Text(text, style: _ts(11.5, bold: true)),
        ],
      ),
    );
  }

  static pw.Widget _note(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(top: 2, bottom: 4),
      child: pw.Text(text, style: _ts(9, color: _gray)),
    );
  }

  /// Jedwali lenye kichwa cha kijani (maandishi meupe), safu za kupishana
  /// rangi, na (hiari) safu ya jumla mwishoni.
  static pw.Widget _table({
    required List<String> headers,
    required List<List<String>> rows,
    required List<double> flex,
    Set<int> right = const {},
    List<String>? totalRow,
  }) {
    pw.Widget cell(String text, {bool header = false, bool bold = false, bool isRight = false}) {
      return pw.Container(
        alignment: isRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4.5),
        child: pw.Text(
          text,
          textAlign: isRight ? pw.TextAlign.right : pw.TextAlign.left,
          style: _ts(
            header ? 8 : 8.5,
            bold: header || bold,
            color: header ? PdfColors.white : _navy,
          ),
        ),
      );
    }

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _green),
        children: [
          for (var i = 0; i < headers.length; i++) cell(headers[i], header: true, isRight: right.contains(i)),
        ],
      ),
    ];

    for (var r = 0; r < rows.length; r++) {
      tableRows.add(
        pw.TableRow(
          decoration: r.isOdd ? pw.BoxDecoration(color: _bg) : null,
          children: [
            for (var i = 0; i < rows[r].length; i++) cell(rows[r][i], isRight: right.contains(i)),
          ],
        ),
      );
    }

    if (totalRow != null) {
      tableRows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _greenTint),
          children: [
            for (var i = 0; i < totalRow.length; i++) cell(totalRow[i], bold: true, isRight: right.contains(i)),
          ],
        ),
      );
    }

    return pw.Table(
      columnWidths: {
        for (var i = 0; i < flex.length; i++) i: pw.FlexColumnWidth(flex[i]),
      },
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: tableRows,
    );
  }

  static String _d(DateTime? d) => d == null ? '-' : _dateFmt.format(d);

  static PdfColor _netColor(double v) => v >= 0 ? _navy : _red;

  // ===================================================================
  //  1) RIPOTI YA FEDHA
  // ===================================================================
  static Future<Uint8List> financial(FinancialReportData d) {
    final totalCount = d.incomes.length + d.expenses.length;

    return _build(
      title: 'RIPOTI YA FEDHA',
      subtitle: '${d.period.label}  |  Imetolewa ${_dateTimeFmt.format(d.generatedAt)}',
      body: () => [
        _kpiRow([
          _Kpi('JUMLA YA MAPATO (INCOME)', formatTZS(d.totalIncome), _green),
          _Kpi('JUMLA YA GHARAMA (EXPENSES)', formatTZS(d.totalExpense), _red),
          _Kpi('FAIDA HALISI (NET PROFIT)', formatTZS(d.netProfit), _netColor(d.netProfit)),
          _Kpi('IDADI YA MIAMALA', '$totalCount', _navy),
        ]),
        _section('Utendaji kwa Service'),
        if (d.byService.isEmpty)
          _note('Hakuna miamala katika kipindi hiki.')
        else
          _table(
            headers: const ['Service', 'Projects', 'Mapato (TZS)', 'Gharama (TZS)', 'Faida (TZS)'],
            flex: const [3, 1, 2, 2, 2],
            right: const {1, 2, 3, 4},
            rows: d.byService
                .map((s) => [
                      s.serviceName,
                      '${s.projectCount}',
                      formatNumber(s.income),
                      formatNumber(s.expense),
                      formatNumber(s.net),
                    ])
                .toList(),
            totalRow: [
              'JUMLA',
              '',
              formatNumber(d.totalIncome),
              formatNumber(d.totalExpense),
              formatNumber(d.netProfit),
            ],
          ),
        _section('Utendaji kwa Project'),
        if (d.byProject.isEmpty)
          _note('Hakuna miamala katika kipindi hiki.')
        else
          _table(
            headers: const ['Project', 'Client', 'Service', 'Mapato (TZS)', 'Gharama (TZS)', 'Faida (TZS)'],
            flex: const [3, 2.4, 2.2, 1.8, 1.8, 1.8],
            right: const {3, 4, 5},
            rows: d.byProject
                .map((p) => [
                      p.projectName,
                      p.clientName,
                      p.serviceName,
                      formatNumber(p.income),
                      formatNumber(p.expense),
                      formatNumber(p.net),
                    ])
                .toList(),
          ),
        _section('Gharama kwa Category'),
        if (d.expenseByCategory.isEmpty)
          _note('Hakuna gharama katika kipindi hiki.')
        else
          _table(
            headers: const ['Category', 'Kiasi (TZS)', 'Asilimia'],
            flex: const [4, 2, 1.4],
            right: const {1, 2},
            rows: d.expenseByCategory
                .map((c) => [
                      c.category,
                      formatNumber(c.amount),
                      d.totalExpense == 0 ? '0%' : '${(c.amount / d.totalExpense * 100).toStringAsFixed(1)}%',
                    ])
                .toList(),
          ),
        _section('Orodha ya Mapato (Income)'),
        if (d.incomes.isEmpty)
          _note('Hakuna mapato katika kipindi hiki.')
        else
          _table(
            headers: const ['Tarehe', 'Project', 'Maelezo', 'Njia ya Malipo', 'Kiasi (TZS)'],
            flex: const [1.5, 2.6, 3, 2, 1.8],
            right: const {4},
            rows: d.incomes
                .map((t) => [_d(t.date), t.projectName, t.description, t.extra, formatNumber(t.amount)])
                .toList(),
          ),
        _section('Orodha ya Gharama (Expenses)'),
        if (d.expenses.isEmpty)
          _note('Hakuna gharama katika kipindi hiki.')
        else
          _table(
            headers: const ['Tarehe', 'Project', 'Maelezo', 'Category', 'Kiasi (TZS)'],
            flex: const [1.5, 2.6, 3, 2, 1.8],
            right: const {4},
            rows: d.expenses
                .map((t) => [_d(t.date), t.projectName, t.description, t.extra, formatNumber(t.amount)])
                .toList(),
          ),
      ],
    );
  }

  // ===================================================================
  //  2) UTENDAJI WA PROJECTS
  // ===================================================================
  static Future<Uint8List> projects(ProjectPerformanceData d) {
    return _build(
      title: 'UTENDAJI WA PROJECTS',
      subtitle: 'Muda wote  |  Imetolewa ${_dateTimeFmt.format(d.generatedAt)}',
      landscape: true,
      body: () => [
        _kpiRow([
          _Kpi('JUMLA YA THAMANI YA PROJECTS', formatTZS(d.totalValue), _navy),
          _Kpi('KILICHOLIPWA (INCOME)', formatTZS(d.totalPaid), _green),
          _Kpi('DENI (OUTSTANDING)', formatTZS(d.totalOutstanding), _red),
          _Kpi('GHARAMA (EXPENSES)', formatTZS(d.totalExpenses), _navy),
          _Kpi('FAIDA HALISI', formatTZS(d.totalNet), _netColor(d.totalNet)),
        ]),
        _section('Projects Zote (${d.rows.length})'),
        if (d.rows.isEmpty)
          _note('Hakuna project bado.')
        else
          _table(
            headers: const [
              'Project',
              'Client',
              'Service',
              'Aina',
              'Hali',
              'Thamani (TZS)',
              'Kilicholipwa (TZS)',
              'Deni (TZS)',
              'Gharama (TZS)',
              'Faida (TZS)',
            ],
            flex: const [2.8, 2.2, 1.9, 1.2, 1.4, 1.6, 1.7, 1.5, 1.6, 1.6],
            right: const {5, 6, 7, 8, 9},
            rows: d.rows
                .map((r) => [
                      r.projectName,
                      r.clientName,
                      r.serviceName,
                      r.typeLabel,
                      r.statusLabel,
                      formatNumber(r.value),
                      formatNumber(r.paid),
                      formatNumber(r.outstanding),
                      formatNumber(r.expenses),
                      formatNumber(r.net),
                    ])
                .toList(),
            totalRow: [
              'JUMLA',
              '',
              '',
              '',
              '',
              formatNumber(d.totalValue),
              formatNumber(d.totalPaid),
              formatNumber(d.totalOutstanding),
              formatNumber(d.totalExpenses),
              formatNumber(d.totalNet),
            ],
          ),
      ],
    );
  }

  // ===================================================================
  //  3) CLIENTS NA MADENI
  // ===================================================================
  static Future<Uint8List> clients(ClientsReportData d) {
    return _build(
      title: 'CLIENTS NA MADENI',
      subtitle: 'Hadi leo  |  Imetolewa ${_dateTimeFmt.format(d.generatedAt)}',
      body: () => [
        _kpiRow([
          _Kpi('IDADI YA CLIENTS', '${d.rows.length}', _navy),
          _Kpi('THAMANI YA PROJECTS', formatTZS(d.totalValue), _navy),
          _Kpi('KILICHOLIPWA', formatTZS(d.totalPaid), _green),
          _Kpi('DENI (OUTSTANDING)', formatTZS(d.totalOutstanding), _red),
        ]),
        _section('Hali ya Kila Client'),
        if (d.rows.isEmpty)
          _note('Hakuna client bado.')
        else
          _table(
            headers: const ['Client', 'Simu', 'Projects', 'Thamani (TZS)', 'Kilicholipwa (TZS)', 'Deni (TZS)'],
            flex: const [3, 2, 1, 2, 2.2, 2],
            right: const {2, 3, 4, 5},
            rows: d.rows
                .map((r) => [
                      r.name,
                      r.phone,
                      '${r.projectCount}',
                      formatNumber(r.projectsValue),
                      formatNumber(r.paid),
                      formatNumber(r.outstanding),
                    ])
                .toList(),
            totalRow: [
              'JUMLA',
              '',
              '',
              formatNumber(d.totalValue),
              formatNumber(d.totalPaid),
              formatNumber(d.totalOutstanding),
            ],
          ),
        _section('Invoices Zisizolipwa Kikamilifu (${d.unpaidInvoices.length})'),
        if (d.unpaidInvoices.isEmpty)
          _note('Hakuna invoice yenye deni. Hongera!')
        else
          _table(
            headers: const [
              'Invoice',
              'Client',
              'Project',
              'Due',
              'Total (TZS)',
              'Kilicholipwa (TZS)',
              'Deni (TZS)',
              'Hali',
            ],
            flex: const [1.9, 2.2, 2.2, 1.5, 1.7, 1.9, 1.7, 1.6],
            right: const {4, 5, 6},
            rows: d.unpaidInvoices
                .map((r) => [
                      r.number,
                      r.clientName,
                      r.projectName,
                      _d(r.dueDate),
                      formatNumber(r.total),
                      formatNumber(r.paid),
                      formatNumber(r.balance),
                      r.statusLabel,
                    ])
                .toList(),
            totalRow: [
              'JUMLA',
              '',
              '',
              '',
              '',
              '',
              formatNumber(d.totalInvoiceBalance),
              '',
            ],
          ),
      ],
    );
  }

  // ===================================================================
  //  4) HISTORIA YA UTENDAJI WA SERVICES (snapshots za kila mwezi)
  // ===================================================================
  static Future<Uint8List> serviceHistory(List<ServicePerformanceMonthModel> rows, int monthsBack) {
    final groups = <DateTime, List<ServicePerformanceMonthModel>>{};
    for (final r in rows) {
      final ym = r.yearMonth;
      if (ym == null) continue;
      groups.putIfAbsent(DateTime(ym.year, ym.month), () => []).add(r);
    }
    final months = groups.keys.toList()..sort();

    final totalIncome = rows.fold(0.0, (s, r) => s + r.totalIncome);
    final totalExpense = rows.fold(0.0, (s, r) => s + r.totalExpense);
    final totalNet = totalIncome - totalExpense;

    List<pw.Widget> monthBlock(DateTime month) {
      final list = groups[month] ?? <ServicePerformanceMonthModel>[];
      final live = list.any((r) => r.isLive);
      final inc = list.fold(0.0, (s, r) => s + r.totalIncome);
      final exp = list.fold(0.0, (s, r) => s + r.totalExpense);
      final net = list.fold(0.0, (s, r) => s + r.netProfit);
      final projects = list.fold(0, (s, r) => s + r.projectCount);

      return [
        _section('${monthLabelSw(month)}${live ? '  (mwezi wa sasa - bado haujafungwa)' : ''}'),
        _table(
          headers: const [
            'Service',
            'Mapato (TZS)',
            'Gharama (TZS)',
            'Faida (TZS)',
            'Projects',
            'Clients',
            'Wastani wa Project (TZS)',
          ],
          flex: const [3, 2, 2, 2, 1.1, 1.1, 2.4],
          right: const {1, 2, 3, 4, 5, 6},
          rows: list
              .map((r) => [
                    r.serviceName,
                    formatNumber(r.totalIncome),
                    formatNumber(r.totalExpense),
                    formatNumber(r.netProfit),
                    '${r.projectCount}',
                    '${r.clientCount}',
                    formatNumber(r.avgProjectValue),
                  ])
              .toList(),
          totalRow: [
            'JUMLA YA MWEZI',
            formatNumber(inc),
            formatNumber(exp),
            formatNumber(net),
            '$projects',
            '',
            '',
          ],
        ),
      ];
    }

    return _build(
      title: 'UTENDAJI WA SERVICES',
      subtitle: 'Miezi $monthsBack iliyopita  |  Imetolewa ${_dateTimeFmt.format(DateTime.now())}',
      body: () => [
        _kpiRow([
          _Kpi('JUMLA YA MAPATO', formatTZS(totalIncome), _green),
          _Kpi('JUMLA YA GHARAMA', formatTZS(totalExpense), _red),
          _Kpi('FAIDA HALISI', formatTZS(totalNet), _netColor(totalNet)),
        ]),
        if (months.isEmpty) _note('Hakuna data ya kumbukumbu bado.'),
        for (final m in months) ...monthBlock(m),
      ],
    );
  }
}
