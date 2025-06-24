import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/assistant/assistant_cubit.dart';

/// Widget for inputting queries to the intelligent assistant
class QueryInputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onSubmitted;
  final void Function(String)? onTextChanged;

  const QueryInputWidget({super.key, this.controller, this.onSubmitted, this.onTextChanged});

  @override
  State<QueryInputWidget> createState() => _QueryInputWidgetState();
}

class _QueryInputWidgetState extends State<QueryInputWidget> with TickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onTextChanged != null) {
      widget.onTextChanged!(_controller.text);
    }

    /// this code will be not used because it cost billing too much
    // final text = _controller.text.trim();
    // if (text.isNotEmpty) {
    //   context.read<AssistantCubit>().getSuggestions(text);
    // } else {
    //   context.read<AssistantCubit>().clearSuggestions();
    // }
  }

  void _submitQuery() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      if (widget.onSubmitted != null) {
        widget.onSubmitted!(text);
      } else {
        context.read<AssistantCubit>().askQuestion(text);
        _controller.clear();
        _focusNode.unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssistantCubit, AssistantState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Input Field
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(scale: _scaleAnimation.value, child: child);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          _focusNode.hasFocus
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: _focusNode.hasFocus ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Leading Icon
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          Icons.psychology_rounded,
                          color:
                              state.isProcessing
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 24,
                        ),
                      ),

                      // Text Field
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          enabled: !state.isProcessing,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _submitQuery(),
                          decoration: InputDecoration(
                            hintText: state.isProcessing ? 'Processing your question...' : 'Ask me anything...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                            ),
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ),

                      // Send Button
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: GestureDetector(
                            onTapDown: (_) => _animationController.forward(),
                            onTapUp: (_) => _animationController.reverse(),
                            onTapCancel: () => _animationController.reverse(),
                            child: Material(
                              color:
                                  _controller.text.trim().isNotEmpty && !state.isProcessing
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: _controller.text.trim().isNotEmpty && !state.isProcessing ? _submitQuery : null,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child:
                                      state.isProcessing
                                          ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).colorScheme.onPrimary,
                                              ),
                                            ),
                                          )
                                          : Icon(
                                            Icons.send_rounded,
                                            color:
                                                _controller.text.trim().isNotEmpty
                                                    ? Theme.of(context).colorScheme.onPrimary
                                                    : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                            size: 20,
                                          ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Processing Indicator
              if (state.isProcessing) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Analyzing your question...',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
