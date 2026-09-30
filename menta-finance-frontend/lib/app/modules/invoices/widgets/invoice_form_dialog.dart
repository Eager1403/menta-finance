import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/money_fmt.dart';
import '../invoice_service.dart';
import '../models/invoice_model.dart';

/// Chaguo rahisi la Project - kwa dropdown ndani ya dialog hii (hiari,
/// kwa sababu InvoiceRequest.projectId si lazima - angalia backend).
class ProjectOption {
  final int id;
  final String name;
  const ProjectOption(this.id, this.name);
}

class _ItemRow {
  final descriptionCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final unitPriceCtrl = TextEditingController();

  double get qty => double.tryParse(qtyCtrl.text.trim()) ?? 0;
  double get unitPrice => double.tryParse(unitPriceCtrl.text.trim()) ?? 0;
  double get amount => qty * unitPrice;

  void dispose() {
    descriptionCtrl.dispose();
    qtyCtrl.dispose();
    unitPriceCtrl.dispose();
  }
}

/// Dialog ya kutengeneza Invoice mpya - POST /api/invoices. Inafunguliwa
/// kutoka kwenye Client Detail (na baadaye Project Detail), ikiwa na
/// clientId tayari imewekwa.
class InvoiceFormDialog extends StatefulWidget {
  final int clientId;
  final List<ProjectOption> projectOptions;
  final VoidCallback? onCreated;

  const InvoiceFormDialog({
    super.key,
    required this.clientId,
    this.projectOptions = const [],
    this.onCreated,
  });

  @override
  State<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends State<InvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _discountCtrl = TextEditingController(text: '0');
  final _taxPercentCtrl = TextEditingController(text: '0');
  final _notesCtrl = TextEditingController();
  final _initialPaidCtrl = TextEditingController(text: '0');
  final _dateFmt = DateFormat('dd/MM/yyyy');

  final List<_ItemRow> _items = [_ItemRow()];
  int? _projectId;
  DateTime _issueDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  bool _isSaving = false;

  @override
  void dispose() {
    _discountCtrl.dispose();
    _taxPercentCtrl.dispose();
    _notesCtrl.dispose();
    _initialPaidCtrl.dispose();
    for (final i in _items) {
      i.dispose();
    }
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, i) => sum + i.amount);
  double get _discount => double.tryParse(_discountCtrl.text.trim()) ?? 0;
  double get _taxPercent => double.tryParse(_taxPercentCtrl.text.trim()) ?? 0;
  double get _afterDiscount => (_subtotal - _discount).clamp(0, double.infinity);
  double get _taxAmount => _afterDiscount * (_taxPercent / 100);
  double get _total => _afterDiscount + _taxAmount;

  Future<void> _pickDate({required bool isDue}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDue ? _dueDate : _issueDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isDue) {
        _dueDate = picked;
      } else {
        _issueDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.every((i) => i.descriptionCtrl.text.trim().isEmpty)) {
      Get.snackbar('Kosa', 'Weka angalau item moja ya invoice.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final service = InvoiceService(Get.find());
      await service.create(
        clientId: widget.clientId,
        projectId: _projectId,
        issueDate: _issueDate,
        dueDate: _dueDate,
        items: _items
            .where((i) => i.descriptionCtrl.text.trim().isNotEmpty)
            .map((i) => InvoiceItemModel(description: i.descriptionCtrl.text.trim(), qty: i.qty, unitPrice: i.unitPrice))
            .toList(),
        discount: _discount,
        taxPercent: _taxPercent,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        initialAmountPaid: double.tryParse(_initialPaidCtrl.text.trim()) ?? 0,
      );
      widget.onCreated?.call();
      if (mounted) Get.back();
      Get.snackbar('Imefanikiwa', 'Invoice imetengenezwa.', snackPosition: SnackPosition.BOTTOM);
    } on ApiException catch (e) {
      Get.snackbar('Hitilafu', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Hitilafu', 'Imeshindikana kutengeneza invoice.', snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tengeneza Invoice'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.projectOptions.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    initialValue: _projectId,
                    decoration: const InputDecoration(labelText: 'Project (hiari)'),
                    items: widget.projectOptions
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _projectId = v),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isDue: false),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Tarehe ya Kutoa'),
                        child: Text(_dateFmt.format(_issueDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isDue: true),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Tarehe ya Mwisho (Due)'),
                        child: Text(_dateFmt.format(_dueDate)),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                const Text('Items za Invoice', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                for (int idx = 0; idx < _items.length; idx++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _items[idx].descriptionCtrl,
                            decoration: const InputDecoration(labelText: 'Maelezo'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _items[idx].qtyCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Qty'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _items[idx].unitPriceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Bei/Kimoja'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
                          onPressed: _items.length == 1
                              ? null
                              : () => setState(() {
                                    _items[idx].dispose();
                                    _items.removeAt(idx);
                                  }),
                        ),
                      ],
                    ),
                  ),
                TextButton.icon(
                  onPressed: () => setState(() => _items.add(_ItemRow())),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Ongeza Item'),
                ),
                const Divider(height: 24),
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _discountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Discount (TZS)'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _taxPercentCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Tax (%)'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _initialPaidCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Malipo ya Awali (hiari)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Notes (hiari)'),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.neutralGrayBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _summaryLine('Subtotal', formatTZS(_subtotal)),
                      _summaryLine('Discount', '- ${formatTZS(_discount)}'),
                      _summaryLine('Tax (${_taxPercent.toStringAsFixed(0)}%)', formatTZS(_taxAmount)),
                      const Divider(height: 14),
                      _summaryLine('TOTAL', formatTZS(_total), bold: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Ghairi')),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Tengeneza Invoice'),
        ),
      ],
    );
  }

  Widget _summaryLine(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 14 : 12.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: bold ? 14 : 12.5, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}
