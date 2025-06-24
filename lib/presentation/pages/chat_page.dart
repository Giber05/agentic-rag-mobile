// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../bloc/chat/chat_cubit.dart';
// import '../widgets/chat/chat_message_list.dart';
// import '../widgets/chat/chat_input_field.dart';
// import '../widgets/chat/chat_app_bar.dart';
// import '../widgets/chat/agent_status_indicator.dart';
// import '../widgets/common/error_widget.dart';

// /// Main chat page for RAG pipeline interaction
// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _messageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     // Get initial pipeline status
//     context.read<ChatCubit>().getPipelineStatus();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   void _sendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       context.read<ChatCubit>().sendMessage(message);
//       _messageController.clear();

//       // Scroll to bottom after a short delay to allow for message addition
//       Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
//     }
//   }

//   void _retryLastMessage() {
//     context.read<ChatCubit>().retryLastMessage();
//     Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
//   }

//   void _clearMessages() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Clear Messages'),
//             content: const Text('Are you sure you want to clear all messages?'),
//             actions: [
//               TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
//               TextButton(
//                 onPressed: () {
//                   context.read<ChatCubit>().clearMessages();
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('Clear'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: ChatAppBar(onClearMessages: _clearMessages, onShowMetrics: () => _showMetricsDialog(context)),
//       body: BlocConsumer<ChatCubit, ChatState>(
//         listener: (context, state) {
//           // Auto-scroll when new messages arrive
//           if (state.messages.isNotEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _scrollToBottom();
//             });
//           }
//         },
//         builder: (context, state) {
//           return Column(
//             children: [
//               // Agent status indicator
//               if (state.isProcessing || state.currentStage != null)
//                 AgentStatusIndicator(
//                   isStreaming: state.isStreaming,
//                   currentStage: state.currentStage,
//                   onCancel: state.isProcessing ? () => context.read<ChatCubit>().cancelCurrentRequest() : null,
//                 ),

//               // Messages list
//               Expanded(
//                 child:
//                     state.hasMessages
//                         ? ChatMessageList(
//                           messages: state.messages,
//                           scrollController: _scrollController,
//                           isLoading: state.isLoading,
//                           isStreaming: state.isStreaming,
//                         )
//                         : _buildEmptyState(),
//               ),

//               // Error display
//               if (state.error != null)
//                 Container(
//                   width: double.infinity,
//                   margin: const EdgeInsets.all(16),
//                   child: AppErrorWidget(error: state.error!, onRetry: _retryLastMessage),
//                 ),

//               // Input field
//               ChatInputField(
//                 controller: _messageController,
//                 onSendMessage: _sendMessage,
//                 isEnabled: !state.isProcessing,
//                 onAttachFile: () => _showAttachFileDialog(context),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.chat_bubble_outline, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
//           const SizedBox(height: 16),
//           Text(
//             'Welcome to Agentic RAG AI',
//             style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Ask me anything and I\'ll search through your documents to provide accurate answers with source citations.',
//             textAlign: TextAlign.center,
//             style: Theme.of(
//               context,
//             ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
//           ),
//           const SizedBox(height: 24),
//           _buildSampleQuestions(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSampleQuestions() {
//     final sampleQuestions = [
//       'What are the key features of this system?',
//       'How does the RAG pipeline work?',
//       'What documents have been uploaded?',
//       'Explain the agent coordination process',
//     ];

//     return Column(
//       children: [
//         Text(
//           'Try asking:',
//           style: Theme.of(
//             context,
//           ).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
//         ),
//         const SizedBox(height: 12),
//         Wrap(
//           spacing: 8,
//           runSpacing: 8,
//           children:
//               sampleQuestions.map((question) {
//                 return ActionChip(
//                   label: Text(question),
//                   onPressed: () {
//                     _messageController.text = question;
//                     _sendMessage();
//                   },
//                 );
//               }).toList(),
//         ),
//       ],
//     );
//   }

//   void _showMetricsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => BlocBuilder<ChatCubit, ChatState>(
//             builder: (context, state) {
//               return AlertDialog(
//                 title: const Text('Pipeline Metrics'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (state.lastProcessingTime != null) ...[
//                         Text('Last Processing Time: ${state.lastProcessingTime!.toStringAsFixed(2)}s'),
//                         const SizedBox(height: 8),
//                       ],
//                       if (state.lastQualityMetrics != null) ...[
//                         const Text('Quality Metrics:', style: TextStyle(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Text('Relevance: ${(state.lastQualityMetrics!.relevance * 100).toStringAsFixed(1)}%'),
//                         Text('Completeness: ${(state.lastQualityMetrics!.completeness * 100).toStringAsFixed(1)}%'),
//                         Text('Accuracy: ${(state.lastQualityMetrics!.accuracy * 100).toStringAsFixed(1)}%'),
//                         if (state.lastQualityMetrics!.clarity != null)
//                           Text('Clarity: ${(state.lastQualityMetrics!.clarity! * 100).toStringAsFixed(1)}%'),
//                         if (state.lastQualityMetrics!.coherence != null)
//                           Text('Coherence: ${(state.lastQualityMetrics!.coherence! * 100).toStringAsFixed(1)}%'),
//                         const SizedBox(height: 8),
//                       ],
//                       if (state.pipelineStatus != null) ...[
//                         const Text('Pipeline Status:', style: TextStyle(fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 4),
//                         Text(state.pipelineStatus.toString()),
//                       ],
//                     ],
//                   ),
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       context.read<ChatCubit>().getPipelineMetrics();
//                     },
//                     child: const Text('Refresh'),
//                   ),
//                   TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
//                 ],
//               );
//             },
//           ),
//     );
//   }

//   void _showAttachFileDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Attach File'),
//             content: const Text('File attachment feature will be implemented in the next phase.'),
//             actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
//           ),
//     );
//   }
// }
