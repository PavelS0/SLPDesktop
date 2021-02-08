import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:slp_desktop/components/app.dart';
import 'package:slp_desktop/components/settings.dart';
import 'package:slp_desktop/model/app.dart';
import 'package:slp_desktop/services/app.dart';
import 'package:slp_desktop/widgets/strength.dart';
import 'package:slp_desktop/widgets/wave.dart';

class AppScreen extends StatefulWidget {
  AppScreen(this._service);
  final AppService _service;

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<AppScreen> {
  AppComponent _appComponent;

  @override
  void initState() {
    _appComponent = AppComponent(widget._service);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bloc'),
      ),
      body: SafeArea(
        child: StreamBuilder<AppState>(
          stream: _appComponent.user,
          initialData: AppMainState(AppData()),
          builder: (context, snapshot) {
            if (snapshot.data is AppConnectionState) {
              return _buildSettings(snapshot.data);
            }
            if (snapshot.data is AppMainState) {
              AppMainState state = snapshot.data;
              return _buildMain(state.data);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSettings(AppConnectionState st) {
    return Center(
        child: PortSelectScreen(
      st.ports,
      onSelected: (String port) => _appComponent.loadUserData(port),
      onClose: () => _appComponent.loadUserData(''),
    ));
  }

  Widget _buildMain(AppData user) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            RaisedButton(
              child: const Text('Соединение'),
              onPressed: () {
                _appComponent.loadConnections();
              },
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Expanded(
                child: CustomPaint(
                  painter: WavePainter(user.signal, const Color(0xFFFF0000)),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(
                            width: 1.0, color: const Color(0xFFFF0000))),
                  ),
                ),
              ),
            ]),
            Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
            Expanded(
                child: Row(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                  child: CustomPaint(
                      painter: WavePainter(user.spect, const Color(0xFFFF00F0),
                          WavePainterType.spect),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            border: Border.all(
                                width: 1.0, color: const Color(0xFFFF00F0))),
                      ))),
              Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
              CustomPaint(
                  painter: StrengthPainter(user.ch1, const Color(0xFFFF00F0)),
                  child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(
                              width: 1.0, color: const Color(0xFFFF00F0))))),
              Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
              CustomPaint(
                  painter: StrengthPainter(user.ch2, const Color(0xFFFF00F0)),
                  child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(
                              width: 1.0, color: const Color(0xFFFF00F0))))),
              Padding(padding: EdgeInsets.symmetric(horizontal: 5.0)),
              CustomPaint(
                  painter: StrengthPainter(user.ch3, const Color(0xFFFF00F0)),
                  child: Container(
                      width: 50,
                      decoration: BoxDecoration(
                          color: Colors.black54,
                          border: Border.all(
                              width: 1.0, color: const Color(0xFFFF00F0)))))
            ])),
            Padding(padding: EdgeInsets.symmetric(vertical: 5.0)),
          ],
        ));
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    _appComponent.dispose();
    super.dispose();
  }
}
