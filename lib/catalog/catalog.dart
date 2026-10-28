import 'package:widget_lab/catalog/animation/animated_builder.dart';
import 'package:widget_lab/catalog/animation/animated_list.dart';
import 'package:widget_lab/catalog/animation/animated_list_state.dart';
import 'package:widget_lab/catalog/animation/animated_widget.dart';
import 'package:widget_lab/catalog/animation/hero.dart';
import 'package:widget_lab/catalog/animation/repeating_animation_builder.dart';
import 'package:widget_lab/catalog/async/stream_builder.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/material/common_buttons.dart';
import 'package:widget_lab/catalog/material/app_bar.dart';
import 'package:widget_lab/catalog/material/navigation_bar.dart';
import 'package:widget_lab/catalog/material/date_picker.dart';
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
  animatedBuilderEntry,
  animatedListEntry,
  animatedListStateEntry,
  animatedWidgetEntry,
  heroEntry,
  repeatingAnimationBuilderEntry,
];
