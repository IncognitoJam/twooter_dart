/// TwooterEvent stores information about an event received from the Twooter
/// live feed service, such as a new user or new message.
class TwooterEvent {
  /// The event type
  final TwooterEventType type;

  /// The payload sent by the Twooter API
  final String payload;

  /// The time at which this event was received (milliseconds since epoch)
  final int time;

  /// Private constructor to create a new TwooterEvent
  TwooterEvent._(this.type, this.payload, this.time);

  /// Construct a new TwooterEvent from the [packetType] and [payload] data
  /// in a live feed message.
  TwooterEvent.fromPacket(packetType, payload)
      : this._(TwooterEventType.fromPacketType(packetType), payload,
            DateTime.now().millisecondsSinceEpoch);

  @override
  String toString() =>
      'TwooterEvent{type: $type, payload: $payload, time: $time}';
}

/// Implementations of TwooterEventListener can react to new [TwooterEvent]s.
typedef void TwooterEventListener(TwooterEvent event);

/// There are multiple types of Twooter events, including:
///   [CONNECT] - when the live feed is connected
///   [DISCONNECT] - when the live feed is disconnected
///   [MESSAGE] - when a new message is posted
///   [USER] - TODO: determine meaning
///   [TAG] - TODO: determine meaning
class TwooterEventType {
  static final CONNECT = TwooterEventType._('Connect');
  static final DISCONNECT = TwooterEventType._('Disconnect');
  static final MESSAGE = TwooterEventType._('Message');
  static final USER = TwooterEventType._('User');
  static final TAG = TwooterEventType._('Tag');

  /// The human readable name of this event type
  final String name;

  /// Private constructor to define a new TwooterEventType
  TwooterEventType._(this.name);

  /// Retrieve the TwooterEventType instance for this [packetType] string,
  /// parsed from a live feed message.
  static TwooterEventType fromPacketType(String packetType) {
    switch (packetType.toLowerCase()) {
      case 'message':
        return MESSAGE;
      case 'users':
        return USER;
      case 'tags':
        return TAG;
    }

    /*
     * If we didn't find the packet type, this twooter client might not be up
     * to date.
     */
    throw Exception('Unknown TwooterEventType packet type: ${packetType}. Maybe'
        ' Twooter Client is out of date?');
  }
}
