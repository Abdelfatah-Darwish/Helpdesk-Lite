import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helpdesk_lite/core/error/failures.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../models/ticket_model.dart';

class MockTicketRepository implements TicketRepository {
  final SharedPreferences sharedPreferences;
  static const String _ticketCacheKey = 'CACHED_TICKETS_LIST';

  MockTicketRepository({required this.sharedPreferences}) {
    _initDefaultTickets();
  }

  // Populate mock data if none exists
  Future<void> _initDefaultTickets() async {
    if (!sharedPreferences.containsKey(_ticketCacheKey)) {
      final now = DateTime.now();
      final defaultTickets = [
        TicketModel(
          id: 'TICK-101',
          subject: 'VPN Connection Issues on Macbook',
          description: 'Unable to connect to the corporate VPN from home. I keep getting a timeout error. I have tried restarting the router and my laptop but the problem persists.',
          priority: TicketPriority.high,
          category: TicketCategory.it,
          status: TicketStatus.inProgress,
          creatorId: 'u-1',
          creatorName: 'Alice Johnson',
          assignedStaffId: 'u-2',
          assignedStaffName: 'Bob Smith',
          createdAt: now.subtract(const Duration(days: 2, hours: 4)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        TicketModel(
          id: 'TICK-102',
          subject: 'Ergonomic Desk Chair Requisition',
          description: 'Requesting an ergonomic office chair for my desk on the 4th floor. My current chair has a broken height adjustment lever and is causing back pain.',
          priority: TicketPriority.low,
          category: TicketCategory.facilities,
          status: TicketStatus.newStatus,
          creatorId: 'u-1',
          creatorName: 'Alice Johnson',
          assignedStaffId: null,
          assignedStaffName: null,
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now.subtract(const Duration(hours: 3)),
        ),
        TicketModel(
          id: 'TICK-103',
          subject: 'March Travel Reimbursement Delay',
          description: 'My reimbursement for the client visit in March has not been processed yet. The finance system says "Pending Manager Approval" but Charlie approved it last week.',
          priority: TicketPriority.medium,
          category: TicketCategory.finance,
          status: TicketStatus.resolved,
          creatorId: 'u-1',
          creatorName: 'Alice Johnson',
          assignedStaffId: 'u-4',
          assignedStaffName: 'Diana Prince',
          createdAt: now.subtract(const Duration(days: 6)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        TicketModel(
          id: 'TICK-104',
          subject: 'Benefits Orientation Link Missing',
          description: 'I need the registration link for the upcoming employee benefits orientation scheduled for next Thursday.',
          priority: TicketPriority.low,
          category: TicketCategory.hr,
          status: TicketStatus.closed,
          creatorId: 'u-1',
          creatorName: 'Alice Johnson',
          assignedStaffId: 'u-4',
          assignedStaffName: 'Diana Prince',
          createdAt: now.subtract(const Duration(days: 12)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
        TicketModel(
          id: 'TICK-105',
          subject: 'MacBook Pro Battery Swollen',
          description: 'The aluminum chassis on my work laptop is starting to bulge near the trackpad. I believe the battery is swollen and needs immediate replacement as it represents a fire hazard.',
          priority: TicketPriority.urgent,
          category: TicketCategory.it,
          status: TicketStatus.newStatus,
          creatorId: 'u-3',
          creatorName: 'Charlie Brown',
          assignedStaffId: 'u-2',
          assignedStaffName: 'Bob Smith',
          createdAt: now.subtract(const Duration(hours: 5)),
          updatedAt: now.subtract(const Duration(hours: 5)),
        ),
        TicketModel(
          id: 'TICK-106',
          subject: 'Printer Jam and Error on 3rd Floor East',
          description: 'The main network printer on the 3rd floor (East wing) has a persistent paper jam that I cannot clear myself. The screen displays error code E-203.',
          priority: TicketPriority.medium,
          category: TicketCategory.facilities,
          status: TicketStatus.newStatus,
          creatorId: 'u-1',
          creatorName: 'Alice Johnson',
          assignedStaffId: null,
          assignedStaffName: null,
          createdAt: now.subtract(const Duration(hours: 12)),
          updatedAt: now.subtract(const Duration(hours: 12)),
        ),
      ];

      await _saveTickets(defaultTickets);
    }
  }

  Future<List<TicketModel>> _getCachedTickets() async {
    final cachedString = sharedPreferences.getString(_ticketCacheKey);
    if (cachedString == null) return [];
    try {
      final decoded = json.decode(cachedString) as List<dynamic>;
      return decoded.map((item) => TicketModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveTickets(List<TicketModel> tickets) async {
    final encoded = json.encode(tickets.map((t) => t.toJson()).toList());
    await sharedPreferences.setString(_ticketCacheKey, encoded);
  }

  @override
  Future<List<TicketEntity>> getTickets() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getCachedTickets();
  }

  @override
  Future<List<TicketEntity>> getTicketsByUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final all = await _getCachedTickets();
    return all.where((t) => t.creatorId == userId).toList();
  }

  @override
  Future<List<TicketEntity>> getTicketsAssignedTo(String staffId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final all = await _getCachedTickets();
    return all.where((t) => t.assignedStaffId == staffId).toList();
  }

  @override
  Future<TicketEntity> getTicketById(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final all = await _getCachedTickets();
    try {
      return all.firstWhere((t) => t.id == ticketId);
    } catch (_) {
      throw const CacheFailure('Ticket not found');
    }
  }

  @override
  Future<TicketEntity> createTicket({
    required String subject,
    required String description,
    required TicketPriority priority,
    required TicketCategory category,
    required String creatorId,
    required String creatorName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final all = await _getCachedTickets();
    
    // Generate next ticket ID
    final nextNum = all.isEmpty 
        ? 101 
        : (int.tryParse(all.map((t) => t.id.split('-').last).reduce((curr, next) {
              final currNum = int.tryParse(curr) ?? 0;
              final nextNum = int.tryParse(next) ?? 0;
              return currNum > nextNum ? curr : next;
            })) ?? 100) + 1;
    
    final newTicket = TicketModel(
      id: 'TICK-$nextNum',
      subject: subject,
      description: description,
      priority: priority,
      category: category,
      status: TicketStatus.newStatus,
      creatorId: creatorId,
      creatorName: creatorName,
      assignedStaffId: null,
      assignedStaffName: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    all.insert(0, newTicket); // Prepend to list
    await _saveTickets(all);
    return newTicket;
  }

  @override
  Future<TicketEntity> assignTicket(
    String ticketId,
    String? staffId,
    String? staffName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final all = await _getCachedTickets();
    
    final idx = all.indexWhere((t) => t.id == ticketId);
    if (idx == -1) throw const CacheFailure('Ticket not found');

    final updated = all[idx].copyWith(
      assignedStaffId: staffId,
      assignedStaffName: staffName,
      updatedAt: DateTime.now(),
    );

    all[idx] = TicketModel.fromEntity(updated);
    await _saveTickets(all);
    return updated;
  }

  @override
  Future<TicketEntity> updateTicketStatus(
    String ticketId,
    TicketStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final all = await _getCachedTickets();
    
    final idx = all.indexWhere((t) => t.id == ticketId);
    if (idx == -1) throw const CacheFailure('Ticket not found');

    final updated = all[idx].copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    all[idx] = TicketModel.fromEntity(updated);
    await _saveTickets(all);
    return updated;
  }
}
