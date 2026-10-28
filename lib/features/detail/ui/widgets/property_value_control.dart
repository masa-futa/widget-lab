import 'package:flutter/material.dart';
import 'package:widget_lab/catalog/model/choice.dart';
import 'package:widget_lab/catalog/model/control_value.dart';
import 'package:widget_lab/catalog/model/property_control.dart';
import 'package:widget_lab/core/theme/nimi_spacing.dart';
import 'package:widget_lab/features/detail/view_model/value_label.dart';

/// 型に合わせた値の操作。[enabled] が `false` なら非活性。
/// [FixedControl] は ON/OFF だけなので何も出さない。
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
      (SwitchControl(), SwitchValue(:final value)) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Switch(
          value: value,
          onChanged: onChanged == null
              ? null
              : (v) => onChanged(SwitchValue(v)),
        ),
      ),
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
      _ => const SizedBox.shrink(),
    };
  }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onChanged = this.onChanged;
    final label = valueLabel(control, SliderValue(value));
    return Row(
      children: [
        Expanded(
          child: Slider(
            min: control.min,
            max: control.max,
            divisions: control.divisions,
            value: value.clamp(control.min, control.max),
            label: label,
            onChanged: onChanged == null
                ? null
                : (v) => onChanged(SliderValue(v)),
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: onChanged == null
                ? theme.colorScheme.onSurfaceVariant
                : null,
          ),
        ),
      ],
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

  @override
  Widget build(BuildContext context) {
    final spacing = NimiSpacing.of(context);
    final scheme = Theme.of(context).colorScheme;
    final onChanged = this.onChanged;
    return Wrap(
      spacing: spacing.xxs,
      runSpacing: spacing.xxs,
      children: [
        for (var i = 0; i < palette.length; i++)
          Semantics(
            label: palette[i].label,
            selected: i == index,
            button: true,
            enabled: onChanged != null,
            excludeSemantics: true,
            onTap: onChanged == null ? null : () => onChanged(ChoiceValue(i)),
            // 押せる大きさは 48dp、見本の円は 40dp
            child: SizedBox.square(
              dimension: 48,
              child: InkResponse(
                onTap: onChanged == null
                    ? null
                    : () => onChanged(ChoiceValue(i)),
                radius: 24,
                child: Center(
                  child: Opacity(
                    opacity: onChanged == null ? 0.38 : 1,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: switch (palette[i].value) {
                          final Color color => color,
                          _ => null,
                        },
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == index ? scheme.onSurface : scheme.outline,
                          width: i == index ? 3 : 1,
                        ),
                      ),
                      child: i == index
                          ? Icon(Icons.check, size: 20, color: scheme.surface)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
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
