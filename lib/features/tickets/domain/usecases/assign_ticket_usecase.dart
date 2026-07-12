import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class AssignTicketUseCase {
  final TicketRepository repository;

  AssignTicketUseCase(this.repository);

  Future<TicketEntity> call(
    String ticketId,
    String? staffId,
    String? staffName,
  ) {
    return repository.assignTicket(ticketId, staffId, staffName);
  }
}
