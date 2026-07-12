import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/usecases/assign_ticket_usecase.dart';
import '../../domain/usecases/create_ticket_usecase.dart';
import '../../domain/usecases/get_tickets_usecase.dart';
import '../../domain/usecases/update_ticket_status_usecase.dart';
import 'ticket_event.dart';
import 'ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final GetTicketsUseCase getTicketsUseCase;
  final CreateTicketUseCase createTicketUseCase;
  final AssignTicketUseCase assignTicketUseCase;
  final UpdateTicketStatusUseCase updateTicketStatusUseCase;

  // Track user information to allow self-reloading
  String? _lastUserId;
  dynamic _lastRole;

  TicketBloc({
    required this.getTicketsUseCase,
    required this.createTicketUseCase,
    required this.assignTicketUseCase,
    required this.updateTicketStatusUseCase,
  }) : super(const TicketState()) {
    on<FetchTickets>(_onFetchTickets);
    on<CreateTicketSubmitted>(_onCreateTicketSubmitted);
    on<AssignTicketRequested>(_onAssignTicketRequested);
    on<UpdateTicketStatusRequested>(_onUpdateTicketStatusRequested);
    on<SearchTicketsQueryChanged>(_onSearchQueryChanged);
    on<FilterTicketsChanged>(_onFilterChanged);
    on<ClearFiltersRequested>(_onClearFilters);
  }

  Future<void> _onFetchTickets(
    FetchTickets event,
    Emitter<TicketState> emit,
  ) async {
    _lastUserId = event.userId;
    _lastRole = event.role;
    emit(state.copyWith(isLoading: true, isSuccess: false));
    try {
      final tickets = await getTicketsUseCase(
        userId: event.userId,
        role: event.role,
        forceGetAllForSupport: event.forceGetAllForSupport,
      );
      // Sort: Newest first
      tickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final filtered = _filterTickets(
        tickets: tickets,
        query: state.searchQuery,
        status: state.filterStatus,
        priority: state.filterPriority,
        category: state.filterCategory,
      );

      emit(state.copyWith(
        isLoading: false,
        allTickets: tickets,
        filteredTickets: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch tickets. Please pull to refresh.',
      ));
    }
  }

  Future<void> _onCreateTicketSubmitted(
    CreateTicketSubmitted event,
    Emitter<TicketState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final newTicket = await createTicketUseCase(
        subject: event.subject,
        description: event.description,
        priority: event.priority,
        category: event.category,
        creatorId: event.creatorId,
        creatorName: event.creatorName,
      );

      // Mutate local state for immediate feedback
      final updatedList = List<TicketEntity>.from(state.allTickets)..insert(0, newTicket);
      final filtered = _filterTickets(
        tickets: updatedList,
        query: state.searchQuery,
        status: state.filterStatus,
        priority: state.filterPriority,
        category: state.filterCategory,
      );

      emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        allTickets: updatedList,
        filteredTickets: filtered,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create support ticket. Please try again.',
      ));
    }
  }

  Future<void> _onAssignTicketRequested(
    AssignTicketRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final updated = await assignTicketUseCase(
        event.ticketId,
        event.staffId,
        event.staffName,
      );

      final updatedList = state.allTickets.map((t) {
        return t.id == event.ticketId ? updated : t;
      }).toList();

      final filtered = _filterTickets(
        tickets: updatedList,
        query: state.searchQuery,
        status: state.filterStatus,
        priority: state.filterPriority,
        category: state.filterCategory,
      );

      emit(state.copyWith(
        isSubmitting: false,
        allTickets: updatedList,
        filteredTickets: filtered,
        updatedTicket: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to assign ticket. Please try again.',
      ));
    }
  }

  Future<void> _onUpdateTicketStatusRequested(
    UpdateTicketStatusRequested event,
    Emitter<TicketState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true));
    try {
      final updated = await updateTicketStatusUseCase(
        event.ticketId,
        event.status,
      );

      final updatedList = state.allTickets.map((t) {
        return t.id == event.ticketId ? updated : t;
      }).toList();

      final filtered = _filterTickets(
        tickets: updatedList,
        query: state.searchQuery,
        status: state.filterStatus,
        priority: state.filterPriority,
        category: state.filterCategory,
      );

      emit(state.copyWith(
        isSubmitting: false,
        allTickets: updatedList,
        filteredTickets: filtered,
        updatedTicket: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to update status. Please try again.',
      ));
    }
  }

  void _onSearchQueryChanged(
    SearchTicketsQueryChanged event,
    Emitter<TicketState> emit,
  ) {
    final filtered = _filterTickets(
      tickets: state.allTickets,
      query: event.query,
      status: state.filterStatus,
      priority: state.filterPriority,
      category: state.filterCategory,
    );
    emit(state.copyWith(
      searchQuery: event.query,
      filteredTickets: filtered,
    ));
  }

  void _onFilterChanged(
    FilterTicketsChanged event,
    Emitter<TicketState> emit,
  ) {
    // Keep existing or change
    final status = event.status == null ? state.filterStatus : (event.status == TicketStatus.newStatus && state.filterStatus == TicketStatus.newStatus ? null : event.status);
    
    final filtered = _filterTickets(
      tickets: state.allTickets,
      query: state.searchQuery,
      status: event.status,
      priority: event.priority,
      category: event.category,
    );

    emit(state.copyWith(
      filterStatus: event.status,
      filterPriority: event.priority,
      filterCategory: event.category,
      filteredTickets: filtered,
    ));
  }

  void _onClearFilters(
    ClearFiltersRequested event,
    Emitter<TicketState> emit,
  ) {
    emit(state.copyWith(
      searchQuery: '',
      clearStatus: true,
      clearPriority: true,
      clearCategory: true,
      filteredTickets: state.allTickets,
    ));
  }

  List<TicketEntity> _filterTickets({
    required List<TicketEntity> tickets,
    required String query,
    required TicketStatus? status,
    required TicketPriority? priority,
    required TicketCategory? category,
  }) {
    return tickets.where((t) {
      final matchesQuery = query.isEmpty ||
          t.subject.toLowerCase().contains(query.toLowerCase()) ||
          t.id.toLowerCase().contains(query.toLowerCase());

      final matchesStatus = status == null || t.status == status;
      final matchesPriority = priority == null || t.priority == priority;
      final matchesCategory = category == null || t.category == category;

      return matchesQuery && matchesStatus && matchesPriority && matchesCategory;
    }).toList();
  }
}
