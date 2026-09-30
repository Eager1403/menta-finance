import 'package:get/get.dart';

/// Menta Finance ni Kiswahili TU (hakuna lugha nyingine kwa sasa). Maandishi
/// mengi ya app yameandikwa moja kwa moja kwenye views (siyo kupitia hii),
/// kwa hiyo faili hii inabaki rahisi - inahitajika tu kwa sababu
/// GetMaterialApp inahitaji 'translations' na 'locale' isiwe null.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'sw_TZ': const {},
      };
}
