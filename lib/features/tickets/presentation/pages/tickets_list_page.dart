import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/workspace_shell.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/ticket.dart';
import '../bloc/ticket_bloc.dart';
import '../bloc/ticket_event.dart';
import '../bloc/ticket_state.dart';

class TicketsListPage extends StatefulWidget {
  const TicketsListPage({super.key});

  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const Scaffold(body: LoadingIndicator());

    final user = authState.user;

    return WorkspaceShell(
      title: user.role == UserRole.employee ? 'My Submitted Tickets' : 'Workspace Ticket Queue',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/tickets/create'),
        label: const Text('New Request'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      child: BlocBuilder<TicketBloc, TicketState>(
        builder: (context, state) {
          return Column(
            children: [
              // Search & Filter Panel
              _buildFilterPanel(context, state),

              // Main List/Grid View
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadTickets(),
                  child: _buildTicketsContent(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, TicketState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      border: const Border(
        bottom: BorderSide(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search tickets by ID or subject...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    context.read<TicketBloc>().add(SearchTicketsQueryChanged(val));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Filter Chips Scroll
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Status Dropdown
                _buildFilterDropdown<TicketStatus>(
                  value: state.filterStatus,
                  hint: 'Status',
                  items: TicketStatus.values,
                  itemLabel: (v) => v.displayName,
                  onChanged: (v) {
                    context.read<TicketBloc>().add(FilterTicketsChanged(
                          status: v,
                          priority: state.filterPriority,
                          category: state.filterCategory,
                        ));
                  },
                ),
                const SizedBox(width: 8),

                // Priority Dropdown
                _buildFilterDropdown<TicketPriority>(
                  value: state.filterPriority,
                  hint: 'Priority',
                  items: TicketPriority.values,
                  itemLabel: (v) => v.displayName,
                  onChanged: (v) {
                    context.read<TicketBloc>().add(FilterTicketsChanged(
                          status: state.filterStatus,
                          priority: v,
                          category: state.filterCategory,
                        ));
                  },
                ),
                const SizedBox(width: 8),

                // Category Dropdown
                _buildFilterDropdown<TicketCategory>(
                  value: state.filterCategory,
                  hint: 'Category',
                  items: TicketCategory.values,
                  itemLabel: (v) => v.displayName,
                  onChanged: (v) {
                    context.read<TicketBloc>().add(FilterTicketsChanged(
                          status: state.filterStatus,
                          priority: state.filterPriority,
                          category: v,
                        ));
                  },
                ),
                const SizedBox(width: 16),

                // Clear Filters button
                if (state.searchQuery.isNotEmpty ||
                    state.filterStatus != null ||
                    state.filterPriority != null ||
                    state.filterCategory != null)
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      context.read<TicketBloc>().add(ClearFiltersRequested());
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear Filters'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          onChanged: onChanged,
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text('All $hint', style: const TextStyle(fontSize: 13)),
            ),
            ...items.map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), style: const TextStyle(fontSize: 13)),
                ))
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsContent(BuildContext context, TicketState state) {
    if (state.isLoading && state.filteredTickets.isEmpty) {
      return const LoadingIndicator();
    }

    if (state.filteredTickets.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_outlined,
        title: 'No Tickets Found',
        description: 'Try adjusting your search filters or create a new ticket request.',
        buttonLabel: 'Create Ticket',
        onButtonPressed: () => context.push('/tickets/create'),
      );
    }

    return ResponsiveLayout(
      mobile: _buildTicketsList(state.filteredTickets),
      tablet: _buildTicketsGrid(state.filteredTickets, 2),
      desktop: _buildTicketsGrid(state.filteredTickets, 3),
    );
  }

  Widget _buildTicketsList(List<TicketEntity> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildTicketCard(list[index]);
      },
    );
  }

  Widget _buildTicketsGrid(List<TicketEntity> list, int crossAxisCount) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 220,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _buildTicketCard(list[index]);
      },
    );
  }

  Widget _buildTicketCard(TicketEntity ticket) {
    final formattedDate = DateFormat('MMM d, y • h:mm a').format(ticket.createdAt);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push('/tickets/${ticket.id}', extra: ticket),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                  _buildStatusBadge(ticket.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ticket.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  ticket.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildPriorityBadge(ticket.priority),
                ],
              )
            ],
          ),
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
