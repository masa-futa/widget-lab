import 'package:widget_lab/catalog/async/stream_builder.dart';
import 'package:widget_lab/catalog/basics/container.dart';
import 'package:widget_lab/catalog/basics/row.dart';
import 'package:widget_lab/catalog/basics/text.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_action_sheet.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_action_sheet_action.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_activity_indicator.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_adaptive_text_selection_toolbar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_alert_dialog.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_app.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_button.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_check_box.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_colors.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_context_menu.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_context_menu_action.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_date_picker.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_desktop_text_selection_controls.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_desktop_text_selection_toolbar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_desktop_text_selection_toolbar_button.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_dialog_action.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_dialog_route.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_dynamic_color.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_form_row.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_form_section.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_fullscreen_dialog_transition.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_list_section.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_list_tile.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_list_tile_chevron.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_localizations.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_magnifier.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_modal_popup_route.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_navigation_bar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_navigation_bar_back_button.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page_route.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page_scaffold.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_page_transition.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_picker.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_picker_default_selection_overlay.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_popup_surface.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_radio.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_scroll_behavior.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_scrollbar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_search_text_field.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_slider.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_sliding_segmented_control.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_sliver_navigation_bar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_sliver_refresh_control.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_spell_check_suggestions_toolbar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_switch.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_bar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_controller.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_scaffold.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_tab_view.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_field.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_form_field_row.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_magnifier.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_selection_controls.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_selection_toolbar.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_selection_toolbar_button.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_text_theme_data.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_theme.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_theme_data.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_thumb_painter.dart';
import 'package:widget_lab/catalog/cupertino/cupertino_timer_picker.dart';
import 'package:widget_lab/catalog/layout/align.dart';
import 'package:widget_lab/catalog/layout/aspect_ratio.dart';
import 'package:widget_lab/catalog/layout/baseline.dart';
import 'package:widget_lab/catalog/layout/carousel_view.dart';
import 'package:widget_lab/catalog/layout/center.dart';
import 'package:widget_lab/catalog/layout/constrained_box.dart';
import 'package:widget_lab/catalog/layout/custom_multi_child_layout.dart';
import 'package:widget_lab/catalog/layout/custom_scroll_view.dart';
import 'package:widget_lab/catalog/layout/custom_single_child_layout.dart';
import 'package:widget_lab/catalog/layout/expanded.dart';
import 'package:widget_lab/catalog/layout/fitted_box.dart';
import 'package:widget_lab/catalog/layout/flow.dart';
import 'package:widget_lab/catalog/layout/fractionally_sized_box.dart';
import 'package:widget_lab/catalog/layout/grid_view.dart';
import 'package:widget_lab/catalog/layout/indexed_stack.dart';
import 'package:widget_lab/catalog/layout/intrinsic_height.dart';
import 'package:widget_lab/catalog/layout/intrinsic_width.dart';
import 'package:widget_lab/catalog/layout/layout_builder.dart';
import 'package:widget_lab/catalog/layout/limited_box.dart';
import 'package:widget_lab/catalog/layout/list_body.dart';
import 'package:widget_lab/catalog/layout/list_view.dart';
import 'package:widget_lab/catalog/layout/offstage.dart';
import 'package:widget_lab/catalog/layout/overflow_bar.dart';
import 'package:widget_lab/catalog/layout/overflow_box.dart';
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/layout/sized_box.dart';
import 'package:widget_lab/catalog/layout/sized_overflow_box.dart';
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
import 'package:widget_lab/catalog/layout/stack.dart';
import 'package:widget_lab/catalog/layout/table.dart';
import 'package:widget_lab/catalog/layout/transform.dart';
import 'package:widget_lab/catalog/layout/wrap.dart';
import 'package:widget_lab/catalog/material/alert_dialog.dart';
import 'package:widget_lab/catalog/material/app_bar.dart';
import 'package:widget_lab/catalog/material/badge.dart';
import 'package:widget_lab/catalog/material/bottom_app_bar.dart';
import 'package:widget_lab/catalog/material/bottom_sheet.dart';
import 'package:widget_lab/catalog/material/card.dart';
import 'package:widget_lab/catalog/material/checkbox.dart';
import 'package:widget_lab/catalog/material/chip.dart';
import 'package:widget_lab/catalog/material/common_buttons.dart';
import 'package:widget_lab/catalog/material/date_picker.dart';
import 'package:widget_lab/catalog/material/divider.dart';
import 'package:widget_lab/catalog/material/extended_floating_action_button.dart';
import 'package:widget_lab/catalog/material/floating_action_button.dart';
import 'package:widget_lab/catalog/material/icon_button.dart';
import 'package:widget_lab/catalog/material/linear_progress_indicator.dart';
import 'package:widget_lab/catalog/material/list_tile.dart';
import 'package:widget_lab/catalog/material/menu.dart';
import 'package:widget_lab/catalog/material/navigation_bar.dart';
import 'package:widget_lab/catalog/material/navigation_drawer.dart';
import 'package:widget_lab/catalog/material/navigation_rail.dart';
import 'package:widget_lab/catalog/material/radio.dart';
import 'package:widget_lab/catalog/material/segmented_button.dart';
import 'package:widget_lab/catalog/material/slider.dart';
import 'package:widget_lab/catalog/material/snack_bar.dart';
import 'package:widget_lab/catalog/material/switch.dart';
import 'package:widget_lab/catalog/material/tab_bar.dart';
import 'package:widget_lab/catalog/material/text_field.dart';
import 'package:widget_lab/catalog/material/time_picker.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
import 'package:widget_lab/catalog/painting/backdrop_filter.dart';
import 'package:widget_lab/catalog/painting/clip_oval.dart';
import 'package:widget_lab/catalog/painting/clip_path.dart';
import 'package:widget_lab/catalog/painting/clip_rect.dart';
import 'package:widget_lab/catalog/painting/custom_paint.dart';
import 'package:widget_lab/catalog/painting/decorated_box.dart';
import 'package:widget_lab/catalog/painting/fractional_translation.dart';
import 'package:widget_lab/catalog/painting/opacity.dart';
import 'package:widget_lab/catalog/painting/rotated_box.dart';
import 'package:widget_lab/catalog/scrolling/notification_listener.dart';
import 'package:widget_lab/catalog/styling/media_query.dart';

/// 収録する全 Widget。ファイルは最初のジャンルのディレクトリに置く。
///
/// 公式の API ドキュメントの URL（`Uri`）が const にできないため `final`。
final allEntries = <WidgetEntry>[
  cupertinoActionSheetEntry,
  cupertinoActionSheetActionEntry,
  cupertinoActivityIndicatorEntry,
  cupertinoAdaptiveTextSelectionToolbarEntry,
  cupertinoAlertDialogEntry,
  cupertinoAppEntry,
  cupertinoButtonEntry,
  cupertinoCheckBoxEntry,
  cupertinoColorsEntry,
  cupertinoContextMenuEntry,
  cupertinoContextMenuActionEntry,
  cupertinoDatePickerEntry,
  cupertinoDesktopTextSelectionControlsEntry,
  cupertinoDesktopTextSelectionToolbarEntry,
  cupertinoDesktopTextSelectionToolbarButtonEntry,
  cupertinoDialogActionEntry,
  cupertinoDialogRouteEntry,
  cupertinoDynamicColorEntry,
  cupertinoFormRowEntry,
  cupertinoFormSectionEntry,
  cupertinoFullscreenDialogTransitionEntry,
  cupertinoThemeDataEntry,
  cupertinoListSectionEntry,
  cupertinoListTileEntry,
  cupertinoListTileChevronEntry,
  cupertinoLocalizationsEntry,
  cupertinoMagnifierEntry,
  cupertinoModalPopupRouteEntry,
  cupertinoNavigationBarEntry,
  cupertinoNavigationBarBackButtonEntry,
  cupertinoPageEntry,
  cupertinoPageRouteEntry,
  cupertinoPageScaffoldEntry,
  cupertinoPageTransitionEntry,
  cupertinoPickerEntry,
  cupertinoPickerDefaultSelectionOverlayEntry,
  cupertinoPopupSurfaceEntry,
  cupertinoRadioEntry,
  cupertinoScrollbarEntry,
  cupertinoScrollBehaviorEntry,
  cupertinoSearchTextFieldEntry,
  cupertinoSliderEntry,
  cupertinoSlidingSegmentedControlEntry,
  cupertinoSliverNavigationBarEntry,
  cupertinoSliverRefreshControlEntry,
  cupertinoSpellCheckSuggestionsToolbarEntry,
  cupertinoSwitchEntry,
  cupertinoTabBarEntry,
  cupertinoTabControllerEntry,
  cupertinoTabScaffoldEntry,
  cupertinoTabViewEntry,
  cupertinoTextFieldEntry,
  cupertinoTextFormFieldRowEntry,
  cupertinoTextMagnifierEntry,
  cupertinoTextSelectionControlsEntry,
  cupertinoTextSelectionToolbarEntry,
  cupertinoTextSelectionToolbarButtonEntry,
  cupertinoTextThemeDataEntry,
  cupertinoThemeEntry,
  cupertinoThumbPainterEntry,
  cupertinoTimerPickerEntry,
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
  backdropFilterEntry,
  clipOvalEntry,
  clipPathEntry,
  clipRectEntry,
  customPaintEntry,
  decoratedBoxEntry,
  fractionalTranslationEntry,
  opacityEntry,
  rotatedBoxEntry,
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
