import 'dart:async';
import 'dart:typed_data';

import 'package:slp_desktop/model/app.dart';

class _HeaderInfo {
  final int startIndex;
  final int packetSize;
  _HeaderInfo(this.startIndex, this.packetSize);
}

class ComReader {
  ComReader._();
  factory ComReader.connect(Stream<Uint8List> stream) {
    final r = ComReader._();
    stream.listen(r._readPart);
    return r;
  }

  static const int16Size = 2;
  static const float32Size = 4;
  static const maxBufferLen = 16000;

  final _readyStream = StreamController<AppData>();
  Stream<AppData> get stream => _readyStream.stream;

  var _buf = Uint8List(maxBufferLen); //16k buffer
  int _bufLen = 0;

  final headerMagic = Uint8List.fromList([0x6D, 0x6F, 0x43, 0x50]);
  final endMagic = Uint8List.fromList([0x50, 0x43, 0x6F, 0x6D]);

  _HeaderInfo _findHeader() {
    final l = _bufLen -
        (headerMagic.length +
            int16Size); //16 uint16_t - переменная размера пакета
    var i = 0;
    while (i < l &&
        !(_buf[i] == headerMagic[0] &&
            _buf[i + 1] == headerMagic[1] &&
            _buf[i + 2] == headerMagic[2] &&
            _buf[i + 3] == headerMagic[3])) i++;

    if (i != l) {
      final beg = i + headerMagic.length;
      final d = _buf.buffer.asByteData(); //
      final size = d.getUint16(beg, Endian.little);
      return _HeaderInfo(beg + int16Size, size);
    } else {
      return null;
    }
  }

  _checkMagic(int index, Uint8List magic) {
    return _buf[index] == magic[0] &&
        _buf[index + 1] == magic[1] &&
        _buf[index + 2] == magic[2] &&
        _buf[index + 3] == magic[3];
  }

  int _findMagic(int fromIndex, Uint8List magic) {
    final l = _bufLen - (magic.length + int16Size);
    var i = fromIndex;
    while (i < l &&
        !(_buf[i] == magic[0] &&
            _buf[i + 1] == magic[1] &&
            _buf[i + 2] == magic[2] &&
            _buf[i + 3] == magic[3])) i++;
    return i != l ? i : -1;
  }

  void _shiftBuf(int index) {
    final newLen = _bufLen - index;
    assert(newLen > 0);
    _buf.setRange(0, newLen, _buf.skip(index));
    _bufLen = newLen;
    _bufLen = 0;
  }

  List<double> _floatFromUInt16Array(ByteData bd, int byteOffset, int len) {
    final l = List<double>(len);
    var i = 0;
    while (i < len) {
      l[i] = bd.getUint16(byteOffset, Endian.little) / 65535;
      byteOffset += Uint16List.bytesPerElement;
      i++;
    }
    return l;
  }

  List<double> _floatFromInt16Array(ByteData bd, int byteOffset, int len) {
    final l = List<double>(len);
    var i = 0;
    while (i < len) {
      l[i] = bd.getInt16(byteOffset, Endian.little) / 32767;
      byteOffset += Int16List.bytesPerElement;
      i++;
    }
    return l;
  }

  void _unpack(int from, int length) {
    final bd = _buf.buffer.asByteData(from, length);
    var padding = 0;

    var p = (int add) {
      final old = padding;
      padding += add;
      return old;
    };

    final signalLen = bd.getUint16(p(int16Size), Endian.little);
    final signal = _floatFromInt16Array(
        bd, p(signalLen * Int16List.bytesPerElement), signalLen);

    final spectLen = bd.getUint16(p(int16Size), Endian.little);
    final spect = _floatFromUInt16Array(
        bd, p(spectLen * Int16List.bytesPerElement), spectLen);

    final ch1 =
        bd.getUint16(p(Int16List.bytesPerElement), Endian.little) / 32767;
    final ch2 =
        bd.getUint16(p(Int16List.bytesPerElement), Endian.little) / 32767;
    final ch3 =
        bd.getUint16(p(Int16List.bytesPerElement), Endian.little) / 32767;

    final appData =
        AppData(signal: signal, spect: spect, ch1: ch1, ch2: ch2, ch3: ch3);
    _readyStream.add(appData);
  }

  var partsReaded = 0;

  void _readPart(Uint8List part) {
    if (part.isNotEmpty) {
      if (_bufLen + part.length < maxBufferLen) {
        _buf.setRange(_bufLen, _bufLen + part.length, part);
        _bufLen += part.length;
        partsReaded++;
      } else {
        final h = _findHeader();
        if (h != null) {
          final payloadEnd = h.startIndex + h.packetSize;
          final packetEnd = payloadEnd + endMagic.length;
          if (_bufLen > packetEnd) {
            if (_checkMagic(payloadEnd, endMagic)) {
              _unpack(h.startIndex, payloadEnd - h.startIndex);
            } else {
              //final realMagic = _findMagic(h.startIndex, endMagic);
              //final diff = payloadEnd - realMagic;

            }
            _shiftBuf(packetEnd);
          } else {
            _shiftBuf(h.startIndex);
          }
        } else {
          _bufLen = 0;
        }
      }
    }
  }
}
