/// Namba yenye koma za maelfu (mfano 1,600,000) - bila "TZS". Inatumika
/// ndani ya majedwali (ambapo kichwa cha safu tayari kinasema TZS).
String formatNumber(num value) {
  final isNegative = value < 0;
  final raw = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    if (i != 0 && (raw.length - i) % 3 == 0) buffer.write(',');
    buffer.write(raw[i]);
  }
  return '${isNegative ? '-' : ''}$buffer';
}

/// Kiumbizi salama cha namba za fedha (mfano TZS 1,600,000) kinachotumika
/// mahali pote kwenye app (Dashboard, Income, Expenses, Invoices, n.k.)
/// ili namba zote za TZS zionekane kwa muundo mmoja.
String formatTZS(num value) {
  final isNegative = value < 0;
  return '${isNegative ? '-' : ''}TZS ${formatNumber(value.abs())}';
}
