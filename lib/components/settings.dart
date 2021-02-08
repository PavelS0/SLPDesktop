import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PortSelectScreen extends StatefulWidget {
  const PortSelectScreen(this._ports, {Key key, this.onSelected, this.onClose})
      : super(key: key);
  final List<String> _ports;
  final void Function(String) onSelected;
  final void Function() onClose;
  State createState() => PortSelectState();
}

class PortSelectState extends State<PortSelectScreen> {
  String selectedPort;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: widget._ports.length,
            itemBuilder: (BuildContext context, int index) {
              return FlatButton(
                  height: 50,
                  child: Text('Entry ${widget._ports[index]}',
                      style: widget._ports[index] == selectedPort
                          ? TextStyle(fontWeight: FontWeight.bold)
                          : null),
                  onPressed: () {
                    selectedPort = widget._ports[index];
                    if (widget.onSelected != null) {
                      widget.onSelected(selectedPort);
                    }
                  });
            }),
      ),
      FlatButton(child: Text('Назад'), onPressed: widget.onClose)
    ]);
  }
}
