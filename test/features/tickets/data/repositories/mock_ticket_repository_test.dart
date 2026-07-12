import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpdesk_lite/features/tickets/data/repositories/mock_ticket_repository.dart';
import 'package:helpdesk_lite/features/tickets/domain/entities/ticket.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockTicketRepository repository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = MockTicketRepository(sharedPreferences: sharedPreferences);
  });

  group('MockTicketRepository Tests', () {
    test('should fetch initial list of pre-populated tickets', () async {
      final tickets = await repository.getTickets();
      expect(tickets.isNotEmpty, true);
      expect(tickets.length, 6); // default tickets count
    });

    test('should create a new ticket and append it to local lists', () async {
      final newTicket = await repository.createTicket(
        subject: 'Keyboard Broken',
        description: 'Several keys are sticking.',
        priority: TicketPriority.low,
        category: TicketCategory.it,
        creatorId: 'u-1',
        creatorName: 'Alice Johnson',
      );

      expect(newTicket.id.startsWith('TICK-'), true);
      expect(newTicket.subject, 'Keyboard Broken');

      final userTickets = await repository.getTicketsByUser('u-1');
      // Should find the ticket in user's list
      expect(userTickets.any((t) => t.id == newTicket.id), true);
    });

    test('should update status of a ticket successfully', () async {
      final updated = await repository.updateTicketStatus('TICK-101', TicketStatus.resolved);
      expect(updated.status, TicketStatus.resolved);

      final fetched = await repository.getTicketById('TICK-101');
      expect(fetched.status, TicketStatus.resolved);
    });

    test('should assign support agent to a ticket successfully', () async {
      final updated = await repository.assignTicket('TICK-102', 'u-2', 'Bob Smith');
      expect(updated.assignedStaffId, 'u-2');
      expect(updated.assignedStaffName, 'Bob Smith');

      final fetched = await repository.getTicketById('TICK-102');
      expect(fetched.assignedStaffId, 'u-2');
    });
  });
}
