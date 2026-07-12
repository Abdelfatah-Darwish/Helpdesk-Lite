import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/workspace_shell.dart';
import '../../../auth/data/repositories/mock_auth_repository.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_event.dart';
import '../../domain/entities/ticket.dart';
import '../bloc/ticket_bloc.dart';
import '../bloc/ticket_event.dart';
import '../bloc/ticket_state.dart';

class TicketDetailsPage extends StatefulWidget {
  final String ticketId;
  final TicketEntity? ticket;

  const TicketDetailsPage({
    super.key,
    required this.ticketId,
    this.ticket,
  });

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  late TicketEntity _localTicket;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const Scaffold(body: LoadingIndicator());

    final user = authState.user;

    return BlocConsumer<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state.updatedTicket != null && state.updatedTicket!.id == widget.ticketId) {
          setState(() {
            _localTicket = state.updatedTicket!;
          });

          // Dispatch local notification upon ticket status or assignment changes!
          final msg = 'Ticket ${state.updatedTicket!.id} was updated. Status: ${state.updatedTicket!.status.displayName}, Assigned: ${state.updatedTicket!.assignedStaffName ?? "Unassigned"}';
          context.read<NotificationBloc>().add(AddLocalNotification(
                ticketId: state.updatedTicket!.id,
                message: msg,
              ));
        }
      },
      builder: (context, state) {
        // Attempt to resolve ticket
        if (!_initialized) {
          try {
            _localTicket = state.allTickets.firstWhere((t) => t.id == widget.ticketId);
            _initialized = true;
          } catch (_) {
            if (widget.ticket != null) {
              _localTicket = widget.ticket!;
              _initialized = true;
            } else {
              return WorkspaceShell(
                title: 'Ticket Details',
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Fetching ticket metadata...'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/tickets'),
                        child: const Text('Back to Tickets'),
                      ),
                    ],
                  ),
                ),
              );
            }
          }
        }

        return WorkspaceShell(
          title: 'Ticket ${_localTicket.id}',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ResponsiveLayout(
              mobile: _buildMobileLayout(user, state),
              tablet: _buildSplitLayout(user, state, isDesktop: false),
              desktop: _buildSplitLayout(user, state, isDesktop: true),
            ),
          ),
        );
      },
    );
  }

  // --- MOBILE STACK LAYOUT ---
  Widget _buildMobileLayout(UserEntity user, TicketState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMainDetailsCard(),
        const SizedBox(height: 16),
        _buildMetaDetailsPanel(user, state, isCompact: true),
      ],
    );
  }

  // --- DESKTOP/TABLET SPLIT LAYOUT ---
  Widget _buildSplitLayout(UserEntity user, TicketState state, {required bool isDesktop}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isDesktop ? 3 : 2,
          child: _buildMainDetailsCard(),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildMetaDetailsPanel(user, state, isCompact: false),
        ),
      ],
    );
  }

  // --- MAIN DESCRIPTION & TEXT CARD ---
  Widget _buildMainDetailsCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryChip(_localTicket.category),
              Text(
                'Submitted by ${_localTicket.creatorName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _localTicket.subject,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            _localTicket.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // --- METADATA & OPERATIONS SIDE PANEL ---
  Widget _buildMetaDetailsPanel(UserEntity user, TicketState state, {required bool isCompact}) {
    final formattedCreated = DateFormat('MMM d, y • h:mm a').format(_localTicket.createdAt);
    final formattedUpdated = DateFormat('MMM d, y • h:mm a').format(_localTicket.updatedAt);
    final theme = Theme.of(context);

    // List of support agents for dropdown
    final supportAgents = MockAuthRepository.getSupportAgents();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ticket Metadata', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Status Row
          _buildMetaItem('Status', _buildStatusBadge(_localTicket.status)),
          _buildMetaItem('Priority', _buildPriorityBadge(_localTicket.priority)),
          _buildMetaItem('Category', Text(_localTicket.category.displayName, style: const TextStyle(fontWeight: FontWeight.w500))),
          _buildMetaItem('Created On', Text(formattedCreated, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          _buildMetaItem('Last Updated', Text(formattedUpdated, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          _buildMetaItem('Assigned Staff', Text(_localTicket.assignedStaffName ?? 'Unassigned', style: const TextStyle(fontWeight: FontWeight.bold))),

          const Divider(height: 24, color: AppColors.border),

          // Operational workflows for agents/managers
          if (user.role != UserRole.employee) ...[
            Text('Actions Command', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Change Status action dropdown
            const Text('Change Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<TicketStatus>(
              value: _localTicket.status,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: TicketStatus.values
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName, style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: state.isSubmitting
                  ? null
                  : (status) {
                      if (status != null) {
                        context.read<TicketBloc>().add(
                              UpdateTicketStatusRequested(
                                ticketId: _localTicket.id,
                                status: status,
                              ),
                            );
                      }
                    },
            ),
            const SizedBox(height: 16),

            // Assignment dropdown
            const Text('Assign Ticket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String?>(
              value: _localTicket.assignedStaffId,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              hint: const Text('Select Agent', style: TextStyle(fontSize: 14)),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Unassigned (Queue)', style: TextStyle(fontSize: 14)),
                ),
                ...supportAgents.map((agent) => DropdownMenuItem<String?>(
                      value: agent.id,
                      child: Text(agent.name, style: const TextStyle(fontSize: 14)),
                    ))
              ],
              onChanged: state.isSubmitting
                  ? null
                  : (agentId) {
                      final selectedAgent = agentId == null ? null : supportAgents.firstWhere((a) => a.id == agentId);
                      context.read<TicketBloc>().add(
                            AssignTicketRequested(
                              ticketId: _localTicket.id,
                              staffId: selectedAgent?.id,
                              staffName: selectedAgent?.name,
                            ),
                          );
                    },
            ),
            const SizedBox(height: 12),

            // Claim Ticket helper
            if (_localTicket.assignedStaffId != user.id && _localTicket.status != TicketStatus.closed)
              CustomButton(
                label: 'Claim For Myself',
                isOutlined: true,
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        context.read<TicketBloc>().add(
                              AssignTicketRequested(
                                ticketId: _localTicket.id,
                                staffId: user.id,
                                staffName: user.name,
                              ),
                            );
                      },
              ),
          ] else ...[
            // Employee options: Close ticket manually if resolved!
            if (_localTicket.status != TicketStatus.closed) ...[
              const SizedBox(height: 12),
              CustomButton(
                label: 'Mark Ticket as Closed',
                isOutlined: true,
                onPressed: state.isSubmitting
                    ? null
                    : () {
                        context.read<TicketBloc>().add(
                              UpdateTicketStatusRequested(
                                ticketId: _localTicket.id,
                                status: TicketStatus.closed,
                              ),
                            );
                      },
              ),
            ]
          ]
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          content,
        ],
      ),
    );
  }

  Widget _buildCategoryChip(TicketCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.displayName,
        style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w600),
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
