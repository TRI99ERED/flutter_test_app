import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const AppSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.onChanged,
  }) : assert(min < max, 'min must be less than max');

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(AppSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sliderTheme = SliderTheme.of(context).copyWith(
      trackHeight: 8,
      inactiveTrackColor: LightColor.medium.color,
      activeTrackColor: HighlightColor.darkest.color,
      thumbColor: LightColor.lightest.color,
      thumbShape: const _InnerDotThumbShape(),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing8),
        child: SizedBox(
          height: 40,
          child: SliderTheme(
            data: sliderTheme,
            child: Slider(
              value: _currentValue.clamp(widget.min, widget.max),
              min: widget.min,
              max: widget.max,
              onChanged: widget.onChanged == null
                  ? null
                  : (value) {
                      setState(() {
                        _currentValue = value;
                      });
                      widget.onChanged?.call(value);
                    },
            ),
          ),
        ),
      ),
    );
  }
}

class _InnerDotThumbShape extends SliderComponentShape {
  final double outerRadius = 9;
  final double innerRadius = 4.5;
  final double elevation = 3;
  final Color shadowColor = const Color(0x33000000);

  const _InnerDotThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(outerRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final thumbColor = sliderTheme.thumbColor ?? LightColor.lightest.color;

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: center, radius: outerRadius)),
      shadowColor,
      elevation,
      false,
    );

    canvas.drawCircle(center, outerRadius, Paint()..color = thumbColor);
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = HighlightColor.darkest.color,
    );
  }
}

class AppSliderDefault extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const AppSliderDefault({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.onChanged,
  });

  @override
  State<AppSliderDefault> createState() => _AppSliderDefaultState();
}

class _AppSliderDefaultState extends State<AppSliderDefault> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(AppSliderDefault oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 375),
      child: Row(
        children: [
          Expanded(
            child: AppSlider(
              value: _value,
              min: widget.min,
              max: widget.max,
              onChanged: (value) {
                setState(() {
                  _value = value;
                });
                widget.onChanged?.call(value);
              },
            ),
          ),
          Container(
            width: 56,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.light.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${((_value - widget.min) / (widget.max - widget.min) * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: DarkColor.darkest.color,
                fontSize: bSSize,
                fontWeight: bSWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppSliderTitled extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String title;
  final ValueChanged<double>? onChanged;

  const AppSliderTitled({
    super.key,
    required this.value,
    required this.title,
    this.min = 0,
    this.max = 100,
    this.onChanged,
  });

  @override
  State<AppSliderTitled> createState() => _AppSliderTitledState();
}

class _AppSliderTitledState extends State<AppSliderTitled> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(AppSliderTitled oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _value = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 375),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: DarkColor.darkest.color,
                    fontSize: h5Size,
                    fontWeight: h5Weight,
                  ),
                ),
                Text(
                  '${((_value - widget.min) / (widget.max - widget.min) * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: DarkColor.medium.color,
                    fontSize: bSSize,
                    fontWeight: bSWeight,
                  ),
                ),
              ],
            ),
          ),
          AppSlider(
            value: _value,
            min: widget.min,
            max: widget.max,
            onChanged: (value) {
              setState(() {
                _value = value;
              });
              widget.onChanged?.call(value);
            },
          ),
        ],
      ),
    );
  }
}
