/// An immutable container class for a single Twoot.
class Message {
  /// This message unique ID.
  final String id;

  /// Which user posted this message.
  final String name;

  /// The message contents itself.
  final String message;

  /// When the message was published, as a UNIX timestamp in seconds.
  final int published;

  /// The number of seconds until this message expires and is removed.
  final int expires;

  /// Creates a new [Message] object.
  Message(this.id, this.name, this.message, this.published, this.expires);

  @override
  String toString() {
    return 'Message{id: $id, name: $name, message: $message, published: '
        '$published, expires: $expires}';
  }

  /// Construct a Message object from [json] data.
  static Message fromJSON(Map<String, dynamic> json) {
    // Read properties from json data
    String id = json['uid'];
    String name = json['name'];
    String message = json['message'];
    int published = json['published'];
    int expires = json['timeout'];

    // Construct new message object
    return Message(id, name, message, published, expires);
  }
}
