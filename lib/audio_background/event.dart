class Event {
  final String name;
  final String startTime;
  final String endTime;
  final int placeId;
  // final int event_id;

  Event({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.placeId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      placeId: json['place_id'],
    );
  }
}
