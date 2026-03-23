import 'package:flutter/material.dart';
import 'package:test_app/l10n/locales/l10n.dart';
import 'package:test_app/src/features/themes/app_theme.dart';
import 'package:test_app/src/features/themes/styles.dart';
import 'package:test_app/src/widgets/common/app_image_view.dart';

enum MessageType { received, sent }

class AppMessageBubble extends StatelessWidget {
  final String? name;
  final String body;
  final bool isLastInSequence;
  final bool? isRead;
  final List<String> imageUrls;
  final String replyBody;
  final MessageType messageType;
  final DateTime timestamp;
  final VoidCallback? onTap;
  final VoidCallback? onReplyTap;

  const AppMessageBubble({
    super.key,
    this.name,
    required this.body,
    required this.isLastInSequence,
    required this.messageType,
    required this.isRead,
    this.imageUrls = const [],
    this.replyBody = '',
    required this.timestamp,
    this.onTap,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (messageType) {
      MessageType.received => IntrinsicWidth(
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: spacing12),
            backgroundColor: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isLastInSequence
                    ? Radius.zero
                    : const Radius.circular(20),
                bottomRight: const Radius.circular(20),
              ),
            ),
          ),
          onPressed: onTap,
          child: AppMessageContent(
            name: name,
            body: body,
            imageUrls: imageUrls,
            isLastInSequence: isLastInSequence,
            messageType: messageType,
            isRead: isRead,
            timestamp: timestamp,
            replyBody: replyBody,
            nameColor: Theme.of(
              context,
            ).extension<AppTheme>()?.foregroundStrongColor,
            bodyColor: Theme.of(
              context,
            ).extension<AppTheme>()?.foregroundStrongestColor,
            replyColor: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundMediumColor,
            onReplyTap: onReplyTap,
          ),
        ),
      ),
      MessageType.sent => IntrinsicWidth(
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: spacing12),
            backgroundColor: Theme.of(
              context,
            ).extension<AppTheme>()?.highlightDarkestColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: const Radius.circular(20),
                bottomRight: isLastInSequence
                    ? Radius.zero
                    : const Radius.circular(20),
              ),
            ),
          ),
          onPressed: onTap,
          child: AppMessageContent(
            name: name,
            body: body,
            imageUrls: imageUrls,
            isLastInSequence: isLastInSequence,
            messageType: messageType,
            isRead: isRead,
            timestamp: timestamp,
            replyBody: replyBody,
            nameColor: Theme.of(
              context,
            ).extension<AppTheme>()?.highlightLightColor,
            bodyColor: Theme.of(
              context,
            ).extension<AppTheme>()?.backgroundStrongestColor,
            replyColor: Theme.of(
              context,
            ).extension<AppTheme>()?.highlightDarkColor,
            onReplyTap: onReplyTap,
          ),
        ),
      ),
    };
  }
}

class AppMessageContent extends StatelessWidget {
  final String? name;
  final String body;
  final bool isLastInSequence;
  final bool? isRead;
  final List<String> imageUrls;
  final String replyBody;
  final MessageType messageType;
  final DateTime timestamp;
  final Color? nameColor;
  final Color? bodyColor;
  final Color? replyColor;
  final VoidCallback? onReplyTap;

  const AppMessageContent({
    super.key,
    this.name,
    required this.body,
    required this.isLastInSequence,
    required this.messageType,
    required this.isRead,
    this.imageUrls = const [],
    this.replyBody = '',
    required this.timestamp,
    this.nameColor,
    this.bodyColor,
    this.replyColor,
    this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (name != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing16),
            child: Text(
              name!,
              style: TextStyle(
                fontSize: h5Size,
                fontWeight: h5Weight,
                color: nameColor,
              ),
            ),
          ),
        if (replyBody.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: spacing4, bottom: spacing8),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(spacing8),
                backgroundColor: replyColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: onReplyTap,
              child: Text(
                '${context.l10n.replyingToLabel}: $replyBody',
                style: TextStyle(
                  fontSize: bMSize,
                  fontWeight: bMWeight,
                  color: bodyColor,
                ),
              ),
            ),
          ),
        if (body.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: spacing16),
            child: Text(
              body,
              style: TextStyle(
                fontSize: bMSize,
                fontWeight: bMWeight,
                color: bodyColor,
              ),
            ),
          ),
        if (imageUrls.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: spacing2,
              left: spacing16,
              right: spacing16,
            ),
            child: Wrap(
              spacing: spacing8,
              runSpacing: spacing8,
              children: imageUrls
                  .map(
                    (url) => TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () =>
                          AppImageView.show(context, imageUrl: url),
                      child: Image.network(
                        url,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: spacing16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  TimeOfDay.fromDateTime(timestamp).format(context),
                  style: TextStyle(
                    fontSize: cMSize,
                    fontWeight: cMWeight,
                    color: nameColor,
                  ),
                ),
                if (isRead != null) const SizedBox(width: spacing4),
                if (isRead != null)
                  isRead!
                      ? Icon(Icons.done_all, size: 16, color: nameColor)
                      : Icon(Icons.done, size: 16, color: nameColor),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
