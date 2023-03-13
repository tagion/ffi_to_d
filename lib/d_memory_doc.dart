import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'tagion_lib_provider.dart';

class DMemoryDoc {
  /// Library provider.
  final LibProvider _provider = LibProvider();

  /// Document id.
  /// Assigned when document is created.
  int _docId = 0;

  int get docId => _docId;

  List<int> getOwnBuffer() {
    /// Get document length.
    final int length = _provider.getDocLenById(docId);

    /// Get document pointer.
    final Pointer<Uint8> pointer = _provider.getDocPtrById(docId);

    List<int> buffer = List.filled(length, 0);

    /// Fill buffer from mem.
    for (int i = 0; i < length; i++) {
      buffer[i] = pointer[i];
    }
    return buffer;
  }

  List<int> get buffer => getOwnBuffer();

  /// Creates a document from a buffer.
  DMemoryDoc.fromBuffer(List<int> innerBuffer) {
    /// Get data pointer.
    final Pointer<Uint8>? pointer = calloc<Uint8>(innerBuffer.length);

    for (int i = 0; i < innerBuffer.length; ++i) {
      pointer![i] = innerBuffer[i];
    }

    _create(pointer, innerBuffer.length);
  }

  DMemoryDoc.fromId(int docId) {
    if (docId == 0) {
      throw Exception('Document could not be created with index 0.');
    }
    _docId = docId;
  }

  /// Creates a document from pointer and length.
  DMemoryDoc.fromPointer(Pointer<Uint8> pointer, int length) {
    List<int> buffer = List.filled(length, 0);

    /// Fill buffer from mem.
    for (int i = 0; i < length; i++) {
      buffer[i] = pointer[i];
    }

    /// Create a document.
    _create(pointer, length);
  }

  static List<int> bufferFromPointer(Pointer<Uint8> pointer, int length) {
    List<int> buffer = List.filled(length, 0);

    /// Fill buffer from mem.
    for (int i = 0; i < length; i++) {
      buffer[i] = pointer[i];
    }

    return buffer;
  }

  /// Update index of created doc.
  void _create(Pointer<Uint8>? pointer, int length) {
    _docId = _provider.createDoc(pointer, length);
  }

  /// Retrieve inner document.
  DMemoryDoc getInnerDoc(String key) {
    final Pointer<Utf8> innerTag = key.toNativeUtf8();
    final Pointer<Uint8>? docPointer = _provider.getDocPtr(docId, innerTag, innerTag.length);
    final int? docLength = _provider.getDocLen(docId, innerTag, innerTag.length);

    /// Check if doc is not null.
    if (docPointer == null || docLength == null) {
      throw Exception('Inner doc does not exist');
    }
    return DMemoryDoc.fromPointer(docPointer, docLength);
  }

  /// Get String with current id.
  String getString(String key) {
    final Pointer<Utf8> tag = key.toNativeUtf8();
    final Pointer<Utf8> result = _provider.getStrByTag(docId, tag, tag.length);

    if (result == null) return '';

    /// Convert to String type.
    return result.toDartString();
  }

  /// Get Int with current id.
  int getInt(String key) {
    final Pointer<Utf8> tag = key.toNativeUtf8();
    final int result = _provider.getIntByTag(docId, tag, tag.length);
    if (result == null) return 0;
    return result;
  }

  /// Get Int with current id.
  int getLong(String key) {
    final Pointer<Utf8> tag = key.toNativeUtf8();
    final int result = _provider.getLongByTag(docId, tag, tag.length);
    if (result == null) return 0;
    return result;
  }

  List<int> getBuffer(String key) {
    final Pointer<Utf8> innerTag = key.toNativeUtf8();
    final Pointer<Uint8>? docPointer = _provider.getBufferPtr(docId, innerTag, innerTag.length);
    final int? docLength = _provider.getBufferLen(docId, innerTag, innerTag.length);

    /// Check if doc is not null.
    if (docPointer == null || docLength == null) {
      throw Exception('Inner doc does not exist');
    }

    List<int> buffer = DMemoryDoc.bufferFromPointer(docPointer, docLength);

    return buffer;
  }

  /// Returns document's members count.
  int getMembersCount() => _provider.getMembersCount(docId);

  /// Call to delete document from a memory by [docId].
  void dispose() {
    _provider.delDocById(docId);
  }
}
