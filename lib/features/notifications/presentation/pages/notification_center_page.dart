import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/workspace_shell.dart';
import '../../../tickets/presentation/bloc/ticket_bloc.dart';
import '../../../tickets/presentation/bloc/ticket_event.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return WorkspaceShell(
      title: 'Notification Center',
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.isLoading && state.notifications.isEmpty) {
            return const LoadingIndicator();
          }

          if (state.notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'All Caught Up!',
              description: 'You have no notifications in your activity log.',
            );
          }

          return Column(
            children: [
              // Operations Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                border: const Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Activity Log (${state.notifications.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Mark all as read'),
                      onPressed: () {
                        context.read<NotificationBloc>().add(MarkAllNotificationsAsRead());
                      },
                    ),
                  ],
                ),
              ),

              // Notifications List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<NotificationBloc>().add(FetchNotifications());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final item = state.notifications[index];
                      return Container(
                        color: item.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.02),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.isRead ? AppColors.border.withOpacity(0.3) : AppColors.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.isRead ? Icons.notifications_none : Icons.notifications_active,
                              color: item.isRead ? AppColors.textSecondary : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            item.message,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.topForLargePhones ?? const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormat('MMM d, y • h:mm a').format(item.createdAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ),
                          onTap: () {
                            if (!item.isRead) {
                              context.read<NotificationBloc>().add(MarkNotificationAsRead(item.id));
                            }
                            // Redirect to ticket details page!
                            context.push('/tickets/${item.ticketId}');
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
