import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class UpdateTicketStatusUseCase {
  final TicketRepository repository;

  UpdateTicketStatusUseCase(this.repository);

  Future<TicketEntity> call(String ticketId, TicketStatus status) {
    return repository.updateTicketStatus(ticketId, status);
  }
}
