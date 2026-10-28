import 'package:widget_lab/catalog/async/stream_builder.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/material/common_buttons.dart';
import 'package:widget_lab/catalog/material/app_bar.dart';
import 'package:widget_lab/catalog/material/navigation_bar.dart';
import 'package:widget_lab/catalog/material/date_picker.dart';
import 'package:widget_lab/catalog/material/floating_action_button.dart';
import 'package:widget_lab/catalog/material/extended_floating_action_button.dart';
import 'package:widget_lab/catalog/material/icon_button.dart';
import 'package:widget_lab/catalog/material/segmented_button.dart';
import 'package:widget_lab/catalog/material/badge.dart';
import 'package:widget_lab/catalog/material/linear_progress_indicator.dart';
import 'package:widget_lab/catalog/material/snack_bar.dart';
import 'package:widget_lab/catalog/material/alert_dialog.dart';
import 'package:widget_lab/catalog/material/bottom_sheet.dart';
import 'package:widget_lab/catalog/material/card.dart';
import 'package:widget_lab/catalog/material/divider.dart';
import 'package:widget_lab/catalog/material/list_tile.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/catalog/scrolling/notification_listener.dart';
import 'package:widget_lab/catalog/styling/media_query.dart';

/// 収録する全 Widget。ファイルは最初のジャンルのディレクトリに置く。
///
/// 公式の API ドキュメントの URL（`Uri`）が const にできないため `final`。
final allEntries = <WidgetEntry>[
  containerEntry,
  rowEntry,
  textEntry,
  paddingEntry,
  mediaQueryEntry,
  streamBuilderEntry,
  notificationListenerEntry,
  commonButtonsEntry,
  appBarEntry,
  navigationBarEntry,
  datePickerEntry,
  floatingActionButtonEntry,
  extendedFloatingActionButtonEntry,
  iconButtonEntry,
  segmentedButtonEntry,
  badgeEntry,
  linearProgressIndicatorEntry,
  snackBarEntry,
  alertDialogEntry,
  bottomSheetEntry,
  cardEntry,
  dividerEntry,
  listTileEntry,
];
