/// One node in the booking detail timeline (e.g. "Đặt sân thành công").
///
/// `done` controls the dot/connector color and text emphasis in the UI.
class TimelineStep {
  final String label;
  final String time;
  final bool done;

  const TimelineStep({
    required this.label,
    required this.time,
    required this.done,
  });
}

/// Status values used across the booking flow. Kept here so the page,
/// the timeline generator, and the status badge stay in sync.
class BookingStatus {
  static const String upcoming = 'upcoming';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  static const List<String> all = [upcoming, completed, cancelled];
}

typedef TimelineStepBuilder = TimelineStep Function(
  String status,
  String bookingTime,
);
