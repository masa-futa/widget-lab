import 'package:widget_lab/catalog/async/stream_builder.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/material/common_buttons.dart';
import 'package:widget_lab/catalog/material/app_bar.dart';
import 'package:widget_lab/catalog/material/navigation_bar.dart';
import 'package:widget_lab/catalog/material/date_picker.dart';
import 'package:widget_lab/catalog/material/bottom_app_bar.dart';
import 'package:widget_lab/catalog/material/navigation_drawer.dart';
import 'package:widget_lab/catalog/material/navigation_rail.dart';
import 'package:widget_lab/catalog/material/tab_bar.dart';
import 'package:widget_lab/catalog/material/checkbox.dart';
import 'package:widget_lab/catalog/material/chip.dart';
import 'package:widget_lab/catalog/material/menu.dart';
import 'package:widget_lab/catalog/material/radio.dart';
import 'package:widget_lab/catalog/material/slider.dart';
import 'package:widget_lab/catalog/material/switch.dart';
import 'package:widget_lab/catalog/material/time_picker.dart';
import 'package:widget_lab/catalog/material/text_field.dart';
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
  bottomAppBarEntry,
  navigationDrawerEntry,
  navigationRailEntry,
  tabBarEntry,
  checkboxEntry,
  chipEntry,
  menuEntry,
  radioEntry,
  sliderEntry,
  switchEntry,
  timePickerEntry,
  textFieldEntry,
];
