import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class GetTicketByIdUseCase {
  final TicketRepository repository;

  GetTicketByIdUseCase(this.repository);

  Future<TicketEntity> call(String ticketId) {
    return repository.getTicketById(ticketId);
  }
}
