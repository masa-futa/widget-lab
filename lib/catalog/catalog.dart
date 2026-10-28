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
import 'package:widget_lab/catalog/layout/padding.dart';
import 'package:widget_lab/catalog/model/widget_entry.dart';
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
  mediaQueryEntry,
  streamBuilderEntry,
  notificationListenerEntry,
];
