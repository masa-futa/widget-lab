import 'package:widget_lab/catalog/async/stream_builder.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/layout/align.dart';
import 'package:widget_lab/catalog/layout/aspect_ratio.dart';
import 'package:widget_lab/catalog/layout/baseline.dart';
import 'package:widget_lab/catalog/layout/center.dart';
import 'package:widget_lab/catalog/layout/constrained_box.dart';
import 'package:widget_lab/catalog/layout/custom_single_child_layout.dart';
import 'package:widget_lab/catalog/layout/expanded.dart';
import 'package:widget_lab/catalog/layout/fitted_box.dart';
import 'package:widget_lab/catalog/layout/fractionally_sized_box.dart';
import 'package:widget_lab/catalog/layout/intrinsic_height.dart';
import 'package:widget_lab/catalog/layout/intrinsic_width.dart';
import 'package:widget_lab/catalog/layout/limited_box.dart';
import 'package:widget_lab/catalog/layout/offstage.dart';
import 'package:widget_lab/catalog/layout/overflow_box.dart';
import 'package:widget_lab/catalog/layout/sized_box.dart';
import 'package:widget_lab/catalog/layout/sized_overflow_box.dart';
import 'package:widget_lab/catalog/layout/transform.dart';
import 'package:widget_lab/catalog/layout/custom_multi_child_layout.dart';
import 'package:widget_lab/catalog/layout/carousel_view.dart';
import 'package:widget_lab/catalog/layout/flow.dart';
import 'package:widget_lab/catalog/layout/grid_view.dart';
import 'package:widget_lab/catalog/layout/indexed_stack.dart';
import 'package:widget_lab/catalog/layout/layout_builder.dart';
import 'package:widget_lab/catalog/layout/list_body.dart';
import 'package:widget_lab/catalog/layout/list_view.dart';
import 'package:widget_lab/catalog/layout/overflow_bar.dart';
import 'package:widget_lab/catalog/layout/stack.dart';
import 'package:widget_lab/catalog/layout/table.dart';
import 'package:widget_lab/catalog/layout/wrap.dart';
import 'package:widget_lab/catalog/layout/custom_scroll_view.dart';
import 'package:widget_lab/catalog/layout/sliver_app_bar.dart';
import 'package:widget_lab/catalog/layout/sliver_child_builder_delegate.dart';
import 'package:widget_lab/catalog/layout/sliver_child_list_delegate.dart';
import 'package:widget_lab/catalog/layout/sliver_fill_remaining.dart';
import 'package:widget_lab/catalog/layout/sliver_fixed_extent_list.dart';
import 'package:widget_lab/catalog/layout/sliver_grid.dart';
import 'package:widget_lab/catalog/layout/sliver_list.dart';
import 'package:widget_lab/catalog/layout/sliver_padding.dart';
import 'package:widget_lab/catalog/layout/sliver_persistent_header.dart';
import 'package:widget_lab/catalog/layout/sliver_to_box_adapter.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
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
  alignEntry,
  aspectRatioEntry,
  baselineEntry,
  centerEntry,
  constrainedBoxEntry,
  customSingleChildLayoutEntry,
  expandedEntry,
  fittedBoxEntry,
  fractionallySizedBoxEntry,
  intrinsicHeightEntry,
  intrinsicWidthEntry,
  limitedBoxEntry,
  offstageEntry,
  overflowBoxEntry,
  sizedBoxEntry,
  sizedOverflowBoxEntry,
  transformEntry,
  customMultiChildLayoutEntry,
  carouselViewEntry,
  flowEntry,
  gridViewEntry,
  indexedStackEntry,
  layoutBuilderEntry,
  listBodyEntry,
  listViewEntry,
  overflowBarEntry,
  stackEntry,
  tableEntry,
  wrapEntry,
  customScrollViewEntry,
  sliverAppBarEntry,
  sliverChildBuilderDelegateEntry,
  sliverChildListDelegateEntry,
  sliverFillRemainingEntry,
  sliverFixedExtentListEntry,
  sliverGridEntry,
  sliverListEntry,
  sliverPaddingEntry,
  sliverPersistentHeaderEntry,
  sliverToBoxAdapterEntry,
  mediaQueryEntry,
  streamBuilderEntry,
  notificationListenerEntry,
];
