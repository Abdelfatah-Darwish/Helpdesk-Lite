import 'package:equatable/equatable.dart';
import '../../domain/entities/ticket.dart';

class TicketState extends Equatable {
  final List<TicketEntity> allTickets;
  final List<TicketEntity> filteredTickets;
  final String searchQuery;
  final TicketStatus? filterStatus;
  final TicketPriority? filterPriority;
  final TicketCategory? filterCategory;
  final bool isLoading;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;
  final TicketEntity? updatedTicket;

  const TicketState({
    this.allTickets = const [],
    this.filteredTickets = const [],
    this.searchQuery = '',
    this.filterStatus,
    this.filterPriority,
    this.filterCategory,
    this.isLoading = false,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
    this.updatedTicket,
  });

  TicketState copyWith({
    List<TicketEntity>? allTickets,
    List<TicketEntity>? filteredTickets,
    String? searchQuery,
    TicketStatus? filterStatus,
    bool clearStatus = false,
    TicketPriority? filterPriority,
    bool clearPriority = false,
    TicketCategory? filterCategory,
    bool clearCategory = false,
    bool? isLoading,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    TicketEntity? updatedTicket,
  }) {
    return TicketState(
      allTickets: allTickets ?? this.allTickets,
      filteredTickets: filteredTickets ?? this.filteredTickets,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: clearStatus ? null : (filterStatus ?? this.filterStatus),
      filterPriority: clearPriority ? null : (filterPriority ?? this.filterPriority),
      filterCategory: clearCategory ? null : (filterCategory ?? this.filterCategory),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage,
      updatedTicket: updatedTicket ?? this.updatedTicket,
    );
  }

  @override
  List<Object?> get props => [
        allTickets,
        filteredTickets,
        searchQuery,
        filterStatus,
        filterPriority,
        filterCategory,
        isLoading,
        isSubmitting,
        isSuccess,
        errorMessage,
        updatedTicket,
      ];
}
