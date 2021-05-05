import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class ObfuscateExamplePage extends StatefulWidget {
  const ObfuscateExamplePage({Key? key}) : super(key: key);

  @override
  _ObfuscateExamplePageState createState() => _ObfuscateExamplePageState();
}

class _ObfuscateExamplePageState extends State<ObfuscateExamplePage> {
  bool _show = false;
  TooltipDirection _direction = TooltipDirection.down;
  GlobalKey<SimpleTooltipState> _exampleTooltipKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Basics"),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: <Widget>[
              ElevatedButton(
                child: Text("toogle: $_show"),
                onPressed: () {
                  setState(() {
                    _show = !_show;
                  });
                },
              ),
              ElevatedButton(
                child: Text("change direction"),
                onPressed: () {
                  setState(() {
                    switch (_direction) {
                      case TooltipDirection.up:
                        _direction = TooltipDirection.right;
                        break;
                      case TooltipDirection.right:
                        _direction = TooltipDirection.down;
                        break;
                      case TooltipDirection.down:
                        _direction = TooltipDirection.left;
                        break;
                      case TooltipDirection.left:
                        _direction = TooltipDirection.up;
                        break;
                      default:
                    }
                  });
                },
              ),
              ElevatedButton(
                child: Text("Show Dialog"),
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    transitionDuration: Duration(milliseconds: 400),
                    barrierDismissible: true,
                    barrierLabel: "label",
                    pageBuilder: (context, a1, a2) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ObfuscateTooltipItem(
                            tooltipKeys: [_exampleTooltipKey],
                            child: Container(
                              height: 100,
                              width: 300,
                              child: Card(
                                child: Text("Hello"),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Align(
                alignment: AlignmentDirectional.center,
                child: SimpleTooltip(
                  key: _exampleTooltipKey,
                  show: _show,
                  tooltipDirection: _direction,
                  child: Container(
                    color: Colors.cyan,
                    width: 80,
                    height: 80,
                  ),
                  minWidth: 200,
                  content: Container(
                    width: 200,
                    child: Text("content!"),
                    color: Colors.blue,
                  ),
                  routeObserver: MyApp.of(context)?.routeObserver,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
