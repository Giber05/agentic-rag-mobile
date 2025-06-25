import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/assistant/assistant_cubit.dart';
import '../../../cubits/authentication/auth_cubit.dart';

/// Options menu component for assistant actions
/// Handles logout, conversation clearing, and health checks
class AssistantOptionsMenu {
  /// Shows the quick options bottom sheet
  static void showQuickOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (sheetContext) => _OptionsBottomSheet(
            onClearConversation: () {
              Navigator.pop(sheetContext);
              // Get the cubit from the original context, not the sheet context
              final cubit = BlocProvider.of<AssistantCubit>(context);
              cubit.clearConversation();
            },
            onCheckHealth: () {
              Navigator.pop(sheetContext);
              // Get the cubit from the original context, not the sheet context
              final cubit = BlocProvider.of<AssistantCubit>(context);
              cubit.checkHealth();
            },
            onLogout: () {
              Navigator.pop(sheetContext);
              _showLogoutConfirmation(context);
            },
          ),
    );
  }

  /// Shows the options menu bottom sheet
  static void showOptionsMenu(BuildContext context) {
    showQuickOptions(context); // Same implementation for now
  }

  /// Shows logout confirmation dialog
  static void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  // Use the original context, not the dialog context
                  final authCubit = BlocProvider.of<AuthCubit>(context);
                  authCubit.logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  /// Shows source details dialog
  static void showSourceDetails(BuildContext context, dynamic source) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(source.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Relevance: ${(source.relevanceScore * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 16),
                  Text(source.excerpt),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
          ),
    );
  }
}

/// Private widget for the options bottom sheet
class _OptionsBottomSheet extends StatelessWidget {
  final VoidCallback onClearConversation;
  final VoidCallback onCheckHealth;
  final VoidCallback onLogout;

  const _OptionsBottomSheet({required this.onClearConversation, required this.onCheckHealth, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionTile(icon: Icons.clear_all_rounded, title: 'Clear Conversation', onTap: onClearConversation),
          _buildOptionTile(icon: Icons.refresh_rounded, title: 'Check Health', onTap: onCheckHealth),
          const Divider(),
          _buildOptionTile(icon: Icons.logout_rounded, title: 'Logout', onTap: onLogout),
        ],
      ),
    );
  }

  Widget _buildOptionTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
