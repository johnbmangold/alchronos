/// Represents a notification received by the application.
class ReceivedNotification {
  /// Creates a [ReceivedNotification] with the specified details.
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  /// The unique identifier of the notification.
  final int id;

  /// The title of the notification.
  final String? title;

  /// The body text of the notification.
  final String? body;

  /// The optional payload data associated with the notification.
  final String? payload;
}
