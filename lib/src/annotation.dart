/// [Tag] is an annotation which is used by [Decoder.decode] to manipulate mapping
class Tag {
  /// [tag] is the name the [Decoder] will take into account, if the value doesn't match, it will be ignored
  final String tag;

  /// [name] is the alias name given to an attributes during decoding
  final String name;
  const Tag({this.tag = "dmap", this.name});
}
