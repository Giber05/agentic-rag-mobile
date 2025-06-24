import 'package:flutter/material.dart';

/// Widget for chat message input field
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSendMessage;
  final bool isEnabled;
  final VoidCallback? onAttachFile;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.isEnabled = true,
    this.onAttachFile,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleSend() {
    if (_hasText && widget.isEnabled) {
      widget.onSendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attach file button
            if (widget.onAttachFile != null)
              IconButton(
                onPressed: widget.isEnabled ? widget.onAttachFile : null,
                icon: Icon(
                  Icons.attach_file,
                  color:
                      widget.isEnabled
                          ? theme.colorScheme.onSurface.withOpacity(0.6)
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                tooltip: 'Attach file',
              ),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.isEnabled,
                  maxLines: null,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: widget.isEnabled ? 'Ask me anything...' : 'Processing your request...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  style: theme.textTheme.bodyMedium,
                  onSubmitted: widget.isEnabled ? (_) => _handleSend() : null,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _hasText && widget.isEnabled ? _handleSend : null,
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        _hasText && widget.isEnabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send,
                    size: 20,
                    color:
                        _hasText && widget.isEnabled
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
                tooltip: 'Send message',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
