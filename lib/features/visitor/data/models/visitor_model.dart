import '../../../../core/utils/date_formatter.dart';

/// Supported visitor classifications.
enum VisitorType {
  customer('Customer'),
  vendor('Vendor'),
  other('Other');

  final String label;
  const VisitorType(this.label);

  static VisitorType fromString(String? value) {
    if (value == null) return VisitorType.customer;
    return VisitorType.values.firstWhere(
      (e) => e.label.toLowerCase() == value.trim().toLowerCase() ||
             e.name.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => VisitorType.other,
    );
  }

  String toJson() => label;
}

/// Permitted project locations.
enum ProjectName {
  projectA('Project A'),
  projectB('Project B'),
  projectC('Project C');

  final String label;
  const ProjectName(this.label);

  static ProjectName fromString(String? value) {
    if (value == null) return ProjectName.projectA;
    return ProjectName.values.firstWhere(
      (e) => e.label.toLowerCase() == value.trim().toLowerCase() ||
             e.name.toLowerCase() == value.trim().toLowerCase(),
      orElse: () => ProjectName.projectA,
    );
  }

  String toJson() => label;
}

/// Visitor lifecycle status: Registered -> Checked In -> Checked Out.
enum VisitorStatus {
  registered('Registered'),
  checkedIn('Checked In'),
  checkedOut('Checked Out');

  final String label;
  const VisitorStatus(this.label);

  static VisitorStatus fromString(String? value) {
    if (value == null) return VisitorStatus.registered;
    final normalized = value.trim().toLowerCase().replaceAll('_', ' ');
    if (normalized == 'registered') return VisitorStatus.registered;
    if (normalized == 'checked in' || normalized == 'checkedin') return VisitorStatus.checkedIn;
    if (normalized == 'checked out' || normalized == 'checkedout') return VisitorStatus.checkedOut;
    return VisitorStatus.registered;
  }

  String toJson() => label;
}

/// Immutable domain model representing a Visitor.
class Visitor {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final VisitorType visitorType;
  final ProjectName project;
  final String purpose;
  final VisitorStatus status;
  final String createdAt;
  final String? checkInTime;
  final String? checkOutTime;

  const Visitor({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.visitorType = VisitorType.customer,
    this.project = ProjectName.projectA,
    required this.purpose,
    this.status = VisitorStatus.registered,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  /// Business Rule: Check-in is permitted only for Registered visitors.
  bool get canCheckIn => status == VisitorStatus.registered;

  /// Business Rule: Check-out is permitted only for Checked In visitors.
  bool get canCheckOut => status == VisitorStatus.checkedIn;

  /// Business Rule: A completed visit cannot be checked in again.
  bool get isCompleted => status == VisitorStatus.checkedOut;

  /// Check whether visitor registered today in device's local date.
  bool get isRegisteredToday => DateFormatter.isToday(createdAt);

  /// Check whether visitor checked in today in device's local date.
  bool get isCheckedInToday =>
      status == VisitorStatus.checkedIn ||
      (checkInTime != null && DateFormatter.isToday(checkInTime));

  /// Check whether visitor checked out today in device's local date.
  bool get isCheckedOutToday =>
      status == VisitorStatus.checkedOut &&
      checkOutTime != null &&
      DateFormatter.isToday(checkOutTime);

  /// Parse from JSON with tolerant fallback handling for server responses.
  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: json['email']?.toString(),
      visitorType: VisitorType.fromString(json['visitor_type']?.toString()),
      project: ProjectName.fromString(json['project']?.toString()),
      purpose: json['purpose']?.toString() ?? '',
      status: VisitorStatus.fromString(json['status']?.toString()),
      createdAt: json['created_at']?.toString() ?? DateFormatter.nowIso(),
      checkInTime: json['check_in_time']?.toString(),
      checkOutTime: json['check_out_time']?.toString(),
    );
  }

  /// Serialize to JSON matching REST API schema.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'visitor_type': visitorType.toJson(),
      'project': project.toJson(),
      'purpose': purpose,
      'status': status.toJson(),
      'created_at': createdAt,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
    };
  }

  /// Create a payload for new visitor registration (without server-generated ID).
  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'mobile': mobile,
      'email': email?.trim().isEmpty == true ? null : email?.trim(),
      'visitor_type': visitorType.toJson(),
      'project': project.toJson(),
      'purpose': purpose,
      'status': VisitorStatus.registered.toJson(),
      'created_at': createdAt,
      'check_in_time': null,
      'check_out_time': null,
    };
  }

  Visitor copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    VisitorType? visitorType,
    ProjectName? project,
    String? purpose,
    VisitorStatus? status,
    String? createdAt,
    String? checkInTime,
    String? checkOutTime,
  }) {
    return Visitor(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      visitorType: visitorType ?? this.visitorType,
      project: project ?? this.project,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Visitor &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status &&
          checkInTime == other.checkInTime &&
          checkOutTime == other.checkOutTime;

  @override
  int get hashCode => id.hashCode ^ status.hashCode ^ (checkInTime?.hashCode ?? 0);
}
