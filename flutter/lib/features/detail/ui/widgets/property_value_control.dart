import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:gap/gap.dart';
import 'package:widget_lab/core/theme/nimi_colors.dart';
import 'package:widget_lab/core/theme/nimi_radius.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/core/theme/nimi_text_styles.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';

/// 型に合わせた値の操作。[enabled] が `false` なら非活性。
/// [FixedControl] は変えられないので、コードでの書き方だけを出す。
class PropertyValueControl extends StatelessWidget {
  const PropertyValueControl({
    required this.control,
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  final PropertyControl control;
  final ControlValue value;
  final bool enabled;
  final ValueChanged<ControlValue> onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = enabled ? this.onChanged : null;
    return switch ((control, value)) {
      (final SliderControl c, SliderValue(:final value)) => _SliderField(
        control: c,
        value: value,
        onChanged: onChanged,
      ),
      (SwitchControl(), SwitchValue(:final value)) => Row(
        children: [
          Switch(
            value: value,
            onChanged: onChanged == null
                ? null
                : (v) => onChanged(SwitchValue(v)),
          ),
          Gap(NimiSpacing.of(context).xs),
          Text('$value', style: NimiTextStyles.of(context).code),
        ],
      ),
      (ChoiceControl(:final choices), ChoiceValue(:final index))
          when _isAlignment(choices) =>
        _AlignmentField(choices: choices, index: index, onChanged: onChanged),
      (ChoiceControl(:final choices), ChoiceValue(:final index))
          when choices.length <= 4 =>
        _SegmentedField(choices: choices, index: index, onChanged: onChanged),
      (ChoiceControl(:final choices), ChoiceValue(:final index)) =>
        _DropdownField(choices: choices, index: index, onChanged: onChanged),
      (ColorControl(:final palette), ChoiceValue(:final index)) => _ColorField(
        palette: palette,
        index: index,
        onChanged: onChanged,
      ),
      (final TextControl c, TextValue(:final value)) => _TextField(
        maxLength: c.maxLength,
        value: value,
        onChanged: onChanged,
      ),
      (FixedControl(:final source), _) => Text(
        source,
        style: NimiTextStyles.of(context).code
            .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      // 入れ子は編集パネルの NestedEditor が子のチップと子の操作を出す
      (NestedControl(), NestedValue()) => const SizedBox.shrink(),
      _ => const SizedBox.shrink(),
    };
  }

  /// 値が 3×3 の向き（x・y が -1・0・1）の Alignment の 9 つなら、3×3 のマスで出す。
  static bool _isAlignment(List<Choice> choices) =>
      choices.length == 9 &&
      {
            for (final choice in choices)
              if (choice.value case Alignment(:final x, :final y)) (x, y),
          }.length ==
          9 &&
      choices.every(
        (c) => switch (c.value) {
          Alignment(:final x, :final y) =>
            const [-1.0, 0.0, 1.0].contains(x) &&
                const [-1.0, 0.0, 1.0].contains(y),
          _ => false,
        },
      );
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.control,
    required this.value,
    required this.onChanged,
  });

  final SliderControl control;
  final double value;
  final ValueChanged<ControlValue>? onChanged;

  /// 下に出す目盛りの数字の区切りの数（最小・途中の 3 つ・最大）。
  static const _scaleParts = 4;

  /// トラックの左右の余白。吹き出しと目盛りの数字をつまみの位置に合わせる。
  static const _inset = 12.0;

  /// 値の吹き出しを置く幅と高さ。
  static const _bubbleWidth = 80.0;
  static const _bubbleHeight = 32.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onChanged = this.onChanged;
    final clamped = value.clamp(control.min, control.max);
    final label = valueLabel(control, SliderValue(clamped));
    final style = theme.textTheme.labelSmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    // Slider の値の吹き出し（alwaysVisible）は、編集パネルのフェードで作り直すと
    // 消えたままになるので、つまみの上に自前で描く
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final ratio = control.max == control.min
                ? 0.0
                : (clamped - control.min) / (control.max - control.min);
            final x = _inset + (constraints.maxWidth - _inset * 2) * ratio;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: _bubbleHeight),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: _inset),
                    ),
                    child: Slider(
                      min: control.min,
                      max: control.max,
                      divisions: control.divisions,
                      value: clamped,
                      semanticFormatterCallback: (v) =>
                          valueLabel(control, SliderValue(v)),
                      onChanged: onChanged == null
                          ? null
                          : (v) => onChanged(SliderValue(v)),
                    ),
                  ),
                ),
                Positioned(
                  left: x - _bubbleWidth / 2,
                  top: 0,
                  width: _bubbleWidth,
                  height: _bubbleHeight,
                  child: ExcludeSemantics(
                    child: Center(
                      child: _ValueBubble(
                        label: label,
                        enabled: onChanged != null,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _inset),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i <= _scaleParts; i++)
                Text(
                  chipValueLabel(
                    control,
                    SliderValue(
                      control.min +
                          (control.max - control.min) * i / _scaleParts,
                    ),
                  ),
                  style: style,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// スライダーのつまみの上の値の吹き出し。非活性なら surface-muted の地。
class _ValueBubble extends StatelessWidget {
  const _ValueBubble({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.xs,
        vertical: spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: enabled ? scheme.primary : NimiColors.of(context).surfaceMuted,
        borderRadius: BorderRadius.circular(NimiRadius.of(context).full),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SegmentedField extends StatelessWidget {
  const _SegmentedField({
    required this.choices,
    required this.index,
    required this.onChanged,
  });

  final List<Choice> choices;
  final int index;
  final ValueChanged<ControlValue>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return SegmentedButton<int>(
      showSelectedIcon: false,
      segments: [
        for (var i = 0; i < choices.length; i++)
          ButtonSegment(value: i, label: Text(choices[i].label)),
      ],
      selected: {index},
      onSelectionChanged: onChanged == null
          ? null
          : (selected) => onChanged(ChoiceValue(selected.first)),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.choices,
    required this.index,
    required this.onChanged,
  });

  final List<Choice> choices;
  final int index;
  final ValueChanged<ControlValue>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return LayoutBuilder(
      builder: (context, constraints) => DropdownMenu<int>(
        width: constraints.maxWidth,
        enabled: onChanged != null,
        initialSelection: index,
        // 初期状態に戻したときに表示を合わせる
        key: ValueKey(index),
        dropdownMenuEntries: [
          for (var i = 0; i < choices.length; i++)
            DropdownMenuEntry(value: i, label: choices[i].label),
        ],
        onSelected: (selected) {
          if (onChanged != null && selected != null) {
            onChanged(ChoiceValue(selected));
          }
        },
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  const _ColorField({
    required this.palette,
    required this.index,
    required this.onChanged,
  });

  final List<Choice> palette;
  final int index;
  final ValueChanged<ControlValue>? onChanged;

  /// 色見本の直径。押せる範囲はこれより広い。
  static const _swatch = 52.0;

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    final theme = Theme.of(context);
    final onChanged = this.onChanged;
    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        for (var i = 0; i < palette.length; i++)
          Semantics(
            label: palette[i].label,
            selected: i == index,
            button: true,
            enabled: onChanged != null,
            excludeSemantics: true,
            onTap: onChanged == null ? null : () => onChanged(ChoiceValue(i)),
            child: Material(
              type: MaterialType.transparency,
              child: InkResponse(
                onTap: onChanged == null
                    ? null
                    : () => onChanged(ChoiceValue(i)),
                radius: _swatch / 2 + spacing.xxs,
                child: Opacity(
                  opacity: onChanged == null ? 0.38 : 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Swatch(
                        color: switch (palette[i].value) {
                          final Color color => color,
                          _ => null,
                        },
                        selected: i == index,
                        size: _swatch,
                      ),
                      Gap(spacing.xxs),
                      Text(palette[i].label, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 色見本の円。選んだものは✓と ink の輪。✓は見本の明るさに合わせて白か墨にする。
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.size,
  });

  final Color? color;
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = this.color;
    final checkColor =
        color == null ||
            ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    // 波紋が見本の上に見えるように Ink で描く
    return Ink(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? scheme.onSurface : scheme.outline,
          width: selected ? 3 : 1,
        ),
      ),
      child: selected ? Icon(Icons.check, color: checkColor) : null,
    );
  }
}

/// Alignment の 9 つを 3×3 のマスで選ぶ。右に選んだ名前とコード。
class _AlignmentField extends StatelessWidget {
  const _AlignmentField({
    required this.choices,
    required this.index,
    required this.onChanged,
  });

  final List<Choice> choices;
  final int index;
  final ValueChanged<ControlValue>? onChanged;

  static const _cell = 48.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final spacing = NimiSpacing.of(context);
    final radius = BorderRadius.circular(NimiRadius.of(context).sm);
    final onChanged = this.onChanged;
    final selected = choices[index];
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(spacing.xxs),
          decoration: BoxDecoration(
            color: NimiColors.of(context).surfaceMuted,
            borderRadius: radius,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var row = 0; row < 3; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var column = 0; column < 3; column++)
                      _cellAt(
                        context,
                        _indexAt(column - 1.0, row - 1.0),
                        radius,
                        onChanged,
                      ),
                  ],
                ),
            ],
          ),
        ),
        Gap(spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(selected.label, style: theme.textTheme.titleSmall),
              Text(
                selected.code,
                style: NimiTextStyles.of(context).code
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 向きが (x, y) の選択肢の添字。収録データの並び順に頼らない。
  int _indexAt(double x, double y) =>
      choices.indexWhere((c) => c.value == Alignment(x, y));

  Widget _cellAt(
    BuildContext context,
    int i,
    BorderRadius radius,
    ValueChanged<ControlValue>? onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = i == index;
    final dot = isSelected ? scheme.onPrimary : scheme.onSurfaceVariant;
    return Semantics(
      label: choices[i].label,
      selected: isSelected,
      button: true,
      enabled: onChanged != null,
      excludeSemantics: true,
      onTap: onChanged == null ? null : () => onChanged(ChoiceValue(i)),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: isSelected ? scheme.primary : scheme.surfaceContainer,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: onChanged == null ? null : () => onChanged(ChoiceValue(i)),
            child: SizedBox.square(
              dimension: _cell,
              child: Center(
                child: Container(
                  width: isSelected ? 10 : 6,
                  height: isSelected ? 10 : 6,
                  decoration: BoxDecoration(
                    color: onChanged == null
                        ? dot.withValues(alpha: 0.38)
                        : dot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  const _TextField({
    required this.maxLength,
    required this.value,
    required this.onChanged,
  });

  final int maxLength;
  final String value;
  final ValueChanged<ControlValue>? onChanged;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(_TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 初期状態に戻したときなど、外から値が変わったら入力欄を合わせる
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onChanged = widget.onChanged;
    return TextField(
      controller: _controller,
      enabled: onChanged != null,
      maxLength: widget.maxLength,
      onChanged: onChanged == null ? null : (v) => onChanged(TextValue(v)),
    );
  }
}
