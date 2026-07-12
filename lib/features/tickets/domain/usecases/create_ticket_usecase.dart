import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class CreateTicketUseCase {
  final TicketRepository repository;

  CreateTicketUseCase(this.repository);

  Future<TicketEntity> call({
    required String subject,
    required String description,
    required TicketPriority priority,
    required TicketCategory category,
    required String creatorId,
    required String creatorName,
  }) {
    return repository.createTicket(
      subject: subject,
      description: description,
      priority: priority,
      category: category,
      creatorId: creatorId,
      creatorName: creatorName,
    );
  }
}
