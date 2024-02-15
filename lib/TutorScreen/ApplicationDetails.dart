class ApplicationDetails {
  final String tutorSeekerId;
  final String tutorPostId;
  final String subject; // Assuming subject is stored as a String
  final double fee; // Assuming fee is stored as a double

  ApplicationDetails({
    required this.tutorSeekerId,
    required this.tutorPostId,
    required this.subject,
    required this.fee,
  });
}
