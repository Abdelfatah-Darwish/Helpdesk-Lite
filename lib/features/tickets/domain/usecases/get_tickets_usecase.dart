import '../../../auth/domain/entities/user.dart';
import '../entities/ticket.dart';
import '../repositories/ticket_repository.dart';

class GetTicketsUseCase {
  final TicketRepository repository;

  GetTicketsUseCase(this.repository);

  Future<List<TicketEntity>> call({
    required String userId,
    required UserRole role,
    bool forceGetAllForSupport = false,
  }) {
    switch (role) {
      case UserRole.employee:
        return repository.getTicketsByUser(userId);
      case UserRole.support:
        if (forceGetAllForSupport) {
          return repository.getTickets();
        }
        return repository.getTicketsAssignedTo(userId);
      case UserRole.manager:
        return repository.getTickets();
    }
  }
}
