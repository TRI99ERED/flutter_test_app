import 'package:flutter/material.dart';
import 'package:test_app/src/core/resources/app_icons.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';

class AppMessageInput extends StatefulWidget {
  final String? text;
  final VoidCallback? onMorePressed;
  final ValueChanged<String>? onSendPressed;
  final TextEditingController? controller;

  const AppMessageInput({
    super.key,
    this.text,
    this.onMorePressed,
    this.onSendPressed,
    this.controller,
  }) : assert(
         controller == null || text == null,
         'controller and text cannot both be provided',
       );

  @override
  State<AppMessageInput> createState() => _AppMessageInputState();
}

class _AppMessageInputState extends State<AppMessageInput> {
  late TextEditingController _internalController;

  TextEditingController get _effectiveController =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController();
    if (widget.text != null) {
      _effectiveController.text = widget.text!;
    }
  }

  @override
  void didUpdateWidget(AppMessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && widget.text != oldWidget.text) {
      _internalController.text = widget.text ?? '';
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints.tightFor(width: 32, height: 32),
          child: IconButton(
            onPressed: widget.onMorePressed,
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(
                context,
              ).extension<AppTheme>()?.highlightDarkestColor,
              backgroundColor: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundStrongestColor,
            ),
            icon: const Icon(AppIcons.add, size: 16),
          ),
        ),
        const SizedBox(width: spacing6),
        Expanded(
          child: TextField(
            controller: _effectiveController,
            onSubmitted: (value) {
              widget.onSendPressed?.call(value);
              _effectiveController.clear();
            },
            cursorColor: Theme.of(
              context,
            ).extension<AppTheme>()?.highlightDarkestColor,
            style: TextStyle(
              color: Theme.of(
                context,
              ).extension<AppTheme>()?.foregroundStrongestColor,
              fontSize: bMSize,
              fontWeight: bMWeight,
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: 'Type a message...',
              contentPadding: const EdgeInsets.symmetric(
                vertical: spacing8,
                horizontal: spacing16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(71),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).extension<AppTheme>()?.backgroundStrongColor,
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).extension<AppTheme>()?.foregroundWeakestColor,
                fontSize: bMSize,
                fontWeight: bMWeight,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  widget.onSendPressed?.call(_effectiveController.text);
                  _effectiveController.clear();
                },
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).extension<AppTheme>()?.highlightDarkestColor,
                  foregroundColor: Theme.of(
                    context,
                  ).extension<AppTheme>()?.backgroundStrongestColor,
                ),
                icon: const Icon(AppIcons.send, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
