import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class MySlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const MySlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.onChanged,
  });

  @override
  State<MySlider> createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(MySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _handleDrag(Offset globalPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPosition = box.globalToLocal(globalPosition);
    final double width = box.size.width;

    double newValue =
        (localPosition.dx / width) * (widget.max - widget.min) + widget.min;

    newValue = newValue.clamp(widget.min, widget.max);

    setState(() {
      _currentValue = newValue;
    });

    widget.onChanged?.call(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _handleDrag(details.globalPosition),
          onTapDown: (details) => _handleDrag(details.globalPosition),
          child: CustomPaint(
            painter: _SliderPainter(
              value: _currentValue,
              min: widget.min,
              max: widget.max,
            ),
            size: const Size(double.infinity, 40),
          ),
        ),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double _value;
  final double _min;
  final double _max;

  _SliderPainter({
    required double value,
    required double min,
    required double max,
  }) : _min = min,
       _max = max,
       _value = value;

  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = LightColor.medium.color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = HighlightColor.darkest.color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      trackPaint,
    );

    final percentage = (_value - _min) / (_max - _min);
    final thumbX = percentage * size.width;
    final thumbOffset = Offset(thumbX, size.height / 2);

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(thumbX, size.height / 2),
      activePaint,
    );

    canvas.drawShadow(
      Path()..addOval(Rect.fromCircle(center: thumbOffset, radius: 10)),
      Colors.black,
      4,
      false,
    );

    canvas.drawCircle(
      Offset(thumbX, size.height / 2),
      10,
      Paint()..color = LightColor.lightest.color,
    );

    canvas.drawCircle(
      Offset(thumbX, size.height / 2),
      5,
      Paint()..color = HighlightColor.darkest.color,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) {
    return oldDelegate._value != _value;
  }
}

class MySliderDefault extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const MySliderDefault({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.onChanged,
  });

  @override
  State<MySliderDefault> createState() => _MySliderDefaultState();
}

class _MySliderDefaultState extends State<MySliderDefault> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(MySliderDefault oldWidget) {
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
            child: MySlider(
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
              '${_value.toStringAsFixed(0)}%',
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

class MySliderTitled extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final String title;
  final ValueChanged<double>? onChanged;

  const MySliderTitled({
    super.key,
    required this.value,
    required this.title,
    this.min = 0,
    this.max = 100,
    this.onChanged,
  });

  @override
  State<MySliderTitled> createState() => _MySliderTitledState();
}

class _MySliderTitledState extends State<MySliderTitled> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(MySliderTitled oldWidget) {
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
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                  '${_value.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: DarkColor.medium.color,
                    fontSize: bSSize,
                    fontWeight: bSWeight,
                  ),
                ),
              ],
            ),
          ),
          MySlider(
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
