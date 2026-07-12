import 'package:equatable/equatable.dart';

enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }
}

enum TicketCategory {
  it,
  hr,
  facilities,
  finance;

  String get displayName {
    switch (this) {
      case TicketCategory.it:
        return 'IT Support';
      case TicketCategory.hr:
        return 'Human Resources';
      case TicketCategory.facilities:
        return 'Facilities';
      case TicketCategory.finance:
        return 'Finance';
    }
  }
}

enum TicketStatus {
  newStatus,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case TicketStatus.newStatus:
        return 'New';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }
}

class TicketEntity extends Equatable {
  final String id;
  final String subject;
  final String description;
  final TicketPriority priority;
  final TicketCategory category;
  final TicketStatus status;
  final String creatorId;
  final String creatorName;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketEntity({
    required this.id,
    required this.subject,
    required this.description,
    required this.priority,
    required this.category,
    required this.status,
    required this.creatorId,
    required this.creatorName,
    this.assignedStaffId,
    this.assignedStaffName,
    required this.createdAt,
    required this.updatedAt,
  });

  TicketEntity copyWith({
    String? subject,
    String? description,
    TicketPriority? priority,
    TicketCategory? category,
    TicketStatus? status,
    String? assignedStaffId,
    String? assignedStaffName,
    DateTime? updatedAt,
  }) {
    return TicketEntity(
      id: id,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      status: status ?? this.status,
      creatorId: creatorId,
      creatorName: creatorName,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        description,
        priority,
        category,
        status,
        creatorId,
        creatorName,
        assignedStaffId,
        assignedStaffName,
        createdAt,
        updatedAt,
      ];
}
