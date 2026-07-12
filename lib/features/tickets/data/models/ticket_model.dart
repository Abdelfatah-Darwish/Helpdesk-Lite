import '../../domain/entities/ticket.dart';

class TicketModel extends TicketEntity {
  const TicketModel({
    required super.id,
    required super.subject,
    required super.description,
    required super.priority,
    required super.category,
    required super.status,
    required super.creatorId,
    required super.creatorName,
    super.assignedStaffId,
    super.assignedStaffName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      priority: TicketPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TicketPriority.low,
      ),
      category: TicketCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TicketCategory.it,
      ),
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.newStatus,
      ),
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      assignedStaffId: json['assignedStaffId'] as String?,
      assignedStaffName: json['assignedStaffName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'description': description,
      'priority': priority.name,
      'category': category.name,
      'status': status.name,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'assignedStaffId': assignedStaffId,
      'assignedStaffName': assignedStaffName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TicketModel.fromEntity(TicketEntity entity) {
    return TicketModel(
      id: entity.id,
      subject: entity.subject,
      description: entity.description,
      priority: entity.priority,
      category: entity.category,
      status: entity.status,
      creatorId: entity.creatorId,
      creatorName: entity.creatorName,
      assignedStaffId: entity.assignedStaffId,
      assignedStaffName: entity.assignedStaffName,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
