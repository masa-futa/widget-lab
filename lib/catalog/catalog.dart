import 'package:widget_lab/catalog/animation/align_transition.dart';
import 'package:widget_lab/catalog/animation/decorated_box_transition.dart';
import 'package:widget_lab/catalog/animation/default_text_style_transition.dart';
import 'package:widget_lab/catalog/animation/fade_transition.dart';
import 'package:widget_lab/catalog/animation/matrix_transition.dart';
import 'package:widget_lab/catalog/animation/positioned_transition.dart';
import 'package:widget_lab/catalog/animation/relative_positioned_transition.dart';
import 'package:widget_lab/catalog/animation/rotation_transition.dart';
import 'package:widget_lab/catalog/animation/scale_transition.dart';
import 'package:widget_lab/catalog/animation/size_transition.dart';
import 'package:widget_lab/catalog/animation/slide_transition.dart';
import 'package:widget_lab/catalog/animation/sliver_fade_transition.dart';
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
  alignTransitionEntry,
  decoratedBoxTransitionEntry,
  defaultTextStyleTransitionEntry,
  fadeTransitionEntry,
  matrixTransitionEntry,
  positionedTransitionEntry,
  relativePositionedTransitionEntry,
  rotationTransitionEntry,
  scaleTransitionEntry,
  sizeTransitionEntry,
  slideTransitionEntry,
  sliverFadeTransitionEntry,
];
