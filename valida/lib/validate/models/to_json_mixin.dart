/// Objects that implement this should have a [toJson] function,
/// which makes them serializable using `jsonEncode`.
mixin ToJson {
  /// Returns this as a Map with JSON representation
  Map<String, Object?> toJson();
}
