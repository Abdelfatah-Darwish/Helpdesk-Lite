import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/workspace_shell.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../tickets/domain/entities/ticket.dart';
import '../../../tickets/presentation/bloc/ticket_bloc.dart';
import '../../../tickets/presentation/bloc/ticket_event.dart';
import '../../../tickets/presentation/bloc/ticket_state.dart';
import '../widgets/chart_placeholder.dart';
import '../widgets/stats_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      context.read<TicketBloc>().add(
            FetchTickets(
              userId: user.id,
              role: user.role,
              forceGetAllForSupport: user.role != UserRole.employee,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: LoadingIndicator());
    }

    final user = authState.user;

    return WorkspaceShell(
      title: 'Workspace Dashboard',
      child: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          if (state.isLoading && state.allTickets.isEmpty) {
            return const LoadingIndicator(message: 'Loading dashboard statistics...');
          }

          if (state.errorMessage != null && state.allTickets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage!, style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDashboardData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          switch (user.role) {
            case UserRole.employee:
              return _buildEmployeeDashboard(user, state.allTickets);
            case UserRole.support:
              return _buildSupportDashboard(user, state.allTickets);
            case UserRole.manager:
              return _buildManagerDashboard(user, state.allTickets);
          }
        },
      ),
    );
  }

  // --- EMPLOYEE DASHBOARD ---
  Widget _buildEmployeeDashboard(UserEntity user, List<TicketEntity> tickets) {
    final openTickets = tickets.where((t) => t.status == TicketStatus.newStatus || t.status == TicketStatus.inProgress).length;
    final resolvedTickets = tickets.where((t) => t.status == TicketStatus.resolved).length;
    final closedTickets = tickets.where((t) => t.status == TicketStatus.closed).length;

    final recentTickets = tickets.take(3).toList();

    return RefreshIndicator(
      onRefresh: () async => _loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeBanner(user.name, "Need technical support, facility repair, or HR assistance? Submit a request below."),
            const SizedBox(height: 24),

            // Statistics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 100,
                  ),
                  children: [
                    StatsCard(
                      title: 'Open Requests',
                      value: '$openTickets',
                      icon: Icons.pending_actions,
                      iconColor: AppColors.statusInProgress,
                    ),
                    StatsCard(
                      title: 'Resolved Requests',
                      value: '$resolvedTickets',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.statusResolved,
                    ),
                    StatsCard(
                      title: 'Closed Requests',
                      value: '$closedTickets',
                      icon: Icons.archive_outlined,
                      iconColor: AppColors.statusClosed,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Recent Requests header & CTA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Recent Support Tickets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => context.go('/tickets'),
                  child: const Row(
                    children: [
                      Text('View All'),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (recentTickets.isEmpty)
              EmptyState(
                title: 'No Tickets Submitted Yet',
                description: 'Submit your first ticket using the "Submit Request" button below to get assistance.',
                buttonLabel: 'Submit Ticket Request',
                onButtonPressed: () => context.push('/tickets/create'),
              )
            else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTickets.length,
                itemBuilder: (context, index) {
                  return _buildTicketCard(recentTickets[index]);
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: CustomButton(
                  label: 'Submit Ticket Request',
                  icon: Icons.add,
                  onPressed: () => context.push('/tickets/create'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- SUPPORT DASHBOARD ---
  Widget _buildSupportDashboard(UserEntity user, List<TicketEntity> tickets) {
    // Stats for support staff
    final myAssigned = tickets.where((t) => t.assignedStaffId == user.id).toList();
    final myOpen = myAssigned.where((t) => t.status == TicketStatus.newStatus || t.status == TicketStatus.inProgress).length;
    final myResolved = myAssigned.where((t) => t.status == TicketStatus.resolved).length;
    
    // Unassigned tickets queue
    final unassignedQueue = tickets.where((t) => t.assignedStaffId == null && t.status == TicketStatus.newStatus).toList();

    return RefreshIndicator(
      onRefresh: () async => _loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(user.name, "Here is your support agent command center. Claim unassigned tickets to begin resolving them."),
            const SizedBox(height: 24),

            // Stat Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 100,
                  ),
                  children: [
                    StatsCard(
                      title: 'My Active Tickets',
                      value: '$myOpen',
                      icon: Icons.work_outline,
                      iconColor: AppColors.primary,
                    ),
                    StatsCard(
                      title: 'My Resolved Tickets',
                      value: '$myResolved',
                      icon: Icons.task_alt_outlined,
                      iconColor: AppColors.statusResolved,
                    ),
                    StatsCard(
                      title: 'Global Unassigned Queue',
                      value: '${unassignedQueue.length}',
                      icon: Icons.queue_play_next,
                      iconColor: AppColors.statusNew,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Queue sections
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unassigned Queue (${unassignedQueue.length})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: () => context.go('/tickets'),
                  child: const Row(
                    children: [
                      Text('View All Tickets'),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (unassignedQueue.isEmpty)
              const EmptyState(
                icon: Icons.check_circle_outline,
                title: 'Queue is Completely Empty!',
                description: 'All submitted tickets have been assigned to support staff. Good job!',
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unassignedQueue.length > 3 ? 3 : unassignedQueue.length,
                itemBuilder: (context, index) {
                  final ticket = unassignedQueue[index];
                  return _buildQueueTicketCard(ticket, user);
                },
              ),
          ],
        ),
      ),
    );
  }

  // --- MANAGER DASHBOARD ---
  Widget _buildManagerDashboard(UserEntity user, List<TicketEntity> tickets) {
    final total = tickets.length;
    final newCount = tickets.where((t) => t.status == TicketStatus.newStatus).length;
    final progressCount = tickets.where((t) => t.status == TicketStatus.inProgress).length;
    final resolvedCount = tickets.where((t) => t.status == TicketStatus.resolved).length;
    final closedCount = tickets.where((t) => t.status == TicketStatus.closed).length;

    final urgentTickets = tickets
        .where((t) => t.priority == TicketPriority.urgent && t.status != TicketStatus.closed && t.status != TicketStatus.resolved)
        .toList();

    return RefreshIndicator(
      onRefresh: () async => _loadDashboardData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeBanner(user.name, "Workload summary, team status allocations, and critical bottlenecks at a glance."),
            const SizedBox(height: 24),

            // Manager grid stats
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                final int crossAxisCount = width > 1000 ? 4 : (width > 600 ? 2 : 1);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 100,
                  ),
                  children: [
                    StatsCard(
                      title: 'Total Tickets',
                      value: '$total',
                      icon: Icons.confirmation_number_outlined,
                      iconColor: AppColors.primary,
                    ),
                    StatsCard(
                      title: 'New Requests',
                      value: '$newCount',
                      icon: Icons.fiber_new_outlined,
                      iconColor: AppColors.statusNew,
                    ),
                    StatsCard(
                      title: 'In Progress',
                      value: '$progressCount',
                      icon: Icons.rotate_left_outlined,
                      iconColor: AppColors.statusInProgress,
                    ),
                    StatsCard(
                      title: 'Resolved',
                      value: '$resolvedCount',
                      icon: Icons.done_all_outlined,
                      iconColor: AppColors.statusResolved,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Charts Layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: ChartPlaceholder(
                          newCount: newCount,
                          inProgressCount: progressCount,
                          resolvedCount: resolvedCount,
                          closedCount: closedCount,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _buildUrgentOverviewCard(urgentTickets),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      ChartPlaceholder(
                        newCount: newCount,
                        inProgressCount: progressCount,
                        resolvedCount: resolvedCount,
                        closedCount: closedCount,
                      ),
                      const SizedBox(height: 24),
                      _buildUrgentOverviewCard(urgentTickets),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---
  Widget _buildWelcomeBanner(String name, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            sub,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentOverviewCard(List<TicketEntity> urgentTickets) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.priorityUrgent),
              const SizedBox(width: 8),
              Text(
                'Critical Bottlenecks (${urgentTickets.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.priorityUrgent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (urgentTickets.isEmpty)
            const Text(
              'No active urgent priority tickets.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: urgentTickets.length > 3 ? 3 : urgentTickets.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final ticket = urgentTickets[index];
                return InkWell(
                  onTap: () => context.push('/tickets/${ticket.id}', extra: ticket),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(ticket.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                          _buildPriorityBadge(ticket.priority),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(ticket.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('By: ${ticket.creatorName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(TicketEntity ticket) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => context.push('/tickets/${ticket.id}', extra: ticket),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.id,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  _buildStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                ticket.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${DateFormat('MMM d, y').format(ticket.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  _buildPriorityBadge(ticket.priority),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueTicketCard(TicketEntity ticket, UserEntity supportUser) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.id,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                _buildPriorityBadge(ticket.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(ticket.subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'From: ${ticket.creatorName}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                CustomButton(
                  label: 'Claim Ticket',
                  onPressed: () {
                    context.read<TicketBloc>().add(
                          AssignTicketRequested(
                            ticketId: ticket.id,
                            staffId: supportUser.id,
                            staffName: supportUser.name,
                          ),
                        );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case TicketStatus.newStatus:
        bg = AppColors.statusNew.withOpacity(0.12);
        fg = AppColors.statusNew;
        break;
      case TicketStatus.inProgress:
        bg = AppColors.statusInProgress.withOpacity(0.12);
        fg = AppColors.statusInProgress;
        break;
      case TicketStatus.resolved:
        bg = AppColors.statusResolved.withOpacity(0.12);
        fg = AppColors.statusResolved;
        break;
      case TicketStatus.closed:
        bg = AppColors.statusClosed.withOpacity(0.12);
        fg = AppColors.statusClosed;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    Color color;
    switch (priority) {
      case TicketPriority.low:
        color = AppColors.priorityLow;
        break;
      case TicketPriority.medium:
        color = AppColors.priorityMedium;
        break;
      case TicketPriority.high:
        color = AppColors.priorityHigh;
        break;
      case TicketPriority.urgent:
        color = AppColors.priorityUrgent;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
