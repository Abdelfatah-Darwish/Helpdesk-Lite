import '../entities/ticket.dart';

abstract class TicketRepository {
  Future<List<TicketEntity>> getTickets();
  Future<List<TicketEntity>> getTicketsByUser(String userId);
  Future<List<TicketEntity>> getTicketsAssignedTo(String staffId);
  Future<TicketEntity> getTicketById(String ticketId);
  Future<TicketEntity> createTicket({
    required String subject,
    required String description,
    required TicketPriority priority,
    required TicketCategory category,
    required String creatorId,
    required String creatorName,
  });
  Future<TicketEntity> assignTicket(
    String ticketId,
    String? staffId,
    String? staffName,
  );
  Future<TicketEntity> updateTicketStatus(
    String ticketId,
    TicketStatus status,
  );
}
