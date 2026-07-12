import 'package:equatable/equatable.dart';
import '../../../../features/auth/domain/entities/user.dart';
import '../../domain/entities/ticket.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();

  @override
  List<Object?> get props => [];
}

class FetchTickets extends TicketEvent {
  final String userId;
  final UserRole role;
  final bool forceGetAllForSupport;

  const FetchTickets({
    required this.userId,
    required this.role,
    this.forceGetAllForSupport = false,
  });

  @override
  List<Object?> get props => [userId, role, forceGetAllForSupport];
}

class CreateTicketSubmitted extends TicketEvent {
  final String subject;
  final String description;
  final TicketPriority priority;
  final TicketCategory category;
  final String creatorId;
  final String creatorName;

  const CreateTicketSubmitted({
    required this.subject,
    required this.description,
    required this.priority,
    required this.category,
    required this.creatorId,
    required this.creatorName,
  });

  @override
  List<Object?> get props => [
        subject,
        description,
        priority,
        category,
        creatorId,
        creatorName,
      ];
}

class AssignTicketRequested extends TicketEvent {
  final String ticketId;
  final String? staffId;
  final String? staffName;

  const AssignTicketRequested({
    required this.ticketId,
    this.staffId,
    this.staffName,
  });

  @override
  List<Object?> get props => [ticketId, staffId, staffName];
}

class UpdateTicketStatusRequested extends TicketEvent {
  final String ticketId;
  final TicketStatus status;

  const UpdateTicketStatusRequested({
    required this.ticketId,
    required this.status,
  });

  @override
  List<Object?> get props => [ticketId, status];
}

class SearchTicketsQueryChanged extends TicketEvent {
  final String query;

  const SearchTicketsQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterTicketsChanged extends TicketEvent {
  final TicketStatus? status;
  final TicketPriority? priority;
  final TicketCategory? category;

  const FilterTicketsChanged({
    this.status,
    this.priority,
    this.category,
  });

  @override
  List<Object?> get props => [status, priority, category];
}

class ClearFiltersRequested extends TicketEvent {}
