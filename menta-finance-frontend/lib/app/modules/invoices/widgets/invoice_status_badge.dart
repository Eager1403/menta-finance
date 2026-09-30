import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/invoice_model.dart';

class InvoiceStatusBadge extends StatelessWidget {
  final InvoiceStatusX status;
  const InvoiceStatusBadge(this.status, {super.key});

  Color get _color {
    switch (status) {
      case InvoiceStatusX.draft:
        return AppColors.neutralGray;
      case InvoiceStatusX.sent:
        return AppColors.info;
      case InvoiceStatusX.partial:
        return AppColors.warning;
      case InvoiceStatusX.paid:
        return AppColors.success;
      case InvoiceStatusX.overdue:
        return AppColors.danger;
      case InvoiceStatusX.cancelled:
        return AppColors.neutralGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatusBadge(invoiceStatusLabel(status), color: _color);
  }
}
