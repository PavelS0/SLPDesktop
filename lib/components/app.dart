import 'dart:async';
import 'dart:typed_data';
import 'package:slp_desktop/services/app.dart';
import 'package:slp_desktop/model/app.dart';
import 'package:dart_serial_port/dart_serial_port.dart';
import 'package:slp_desktop/services/com.dart';

class AppComponent {
  bool allowRequesting = false;
  double _step = 0.05;
  double _addition = 0.01;
  SerialPort com;
  ComReader comReader;

  AppComponent(this._appService);
  final AppService _appService;

  final _stateStream = StreamController<AppState>();

  Stream<AppState> get user => _stateStream.stream;

  Future<void> loadUserData(String port) async {
    if (port != null && port.isNotEmpty) {
      var error = '';
      if (com != null && com.isOpen) {
        if (!com.close()) {
          error = SerialPort.lastError.toString();
        }
      }
      if (error.isEmpty) {
        com = SerialPort(port);
        //com.config = SerialPortConfig();
        /* 
        print('bd ${com.config.baudRate}');
        print('bits ${com.config.bits}');
        print('cts ${com.config.cts}');
        print('dsr ${com.config.dsr}');
        print('dtr ${com.config.dtr}');
        print('parity ${com.config.parity}');
        print('rts ${com.config.rts}');
        print('stopBits ${com.config.stopBits}');
        print('xonXoff ${com.config.xonXoff}');
        */

        if (com.openRead()) {
          final conf = SerialPortConfig();
          conf.baudRate = 115200;
          conf.flowControl = SerialPortFlowControl.none;
          conf.stopBits = 1;
          conf.bits = 8;
          conf.parity = SerialPortParity.none;
          com.config = conf;
          final reader = SerialPortReader(com);

          print(SerialPort.lastError.toString());
          print('opend read');
          comReader = ComReader.connect(reader.stream);
          comReader.stream.listen((data) {
            _stateStream.sink.add(AppState._userData(data, port));
          });
        } else {
          error = SerialPort.lastError.toString();
        }
        print(error);
      }

      allowRequesting = true;
    } else {
      _stateStream.sink.add(AppState._userData(AppData(), ''));
    }
  }

  Future<void> loadConnections() async {
    final ports = SerialPort.availablePorts;
    allowRequesting = false;
    _stateStream.sink.add(AppState._connections(ports));
  }

  void dispose() {
    _stateStream.close();
    if (com.isOpen) {
      com.close();
      com.dispose();
    }
  }
}

class AppState {
  AppState();
  factory AppState._userData(AppData data, String port) = AppMainState;
  factory AppState._connections(List<String> ports) = AppConnectionState;
}

class AppMainState extends AppState {
  AppMainState(this.data, [this.port = '', this.statusString = 'Ok']);
  final AppData data;
  final String port;
  final String statusString;
}

class AppConnectionState extends AppState {
  AppConnectionState(this.ports);
  final List<String> ports;
}
