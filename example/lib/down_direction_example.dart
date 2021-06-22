import 'package:flutter/material.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

class DownDirectionExample extends StatefulWidget {
  const DownDirectionExample({Key? key}) : super(key: key);

  @override
  _DownDirectionExampleState createState() => _DownDirectionExampleState();
}

class _DownDirectionExampleState extends State<DownDirectionExample> {
  bool _show = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Down Direction"),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 300,
          ),
          SimpleTooltip(
            show: _show,
            maxWidth: 300,
            tooltipDirection: TooltipDirection.down,
            arrowTipDistance: 10,
            animationDuration: Duration(milliseconds: 50),
            content: Text(
              "Some text example!!!! THIS IS A VERY LOOOOOOOOOOOOOOOOOOOOOOOONG TEXT",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                decoration: TextDecoration.none,
              ),
            ),
            child: Padding(
              padding: new EdgeInsets.all(10.0),
              child: ElevatedButton(
                child: Text('toggle tooltip'),
                onPressed: () {
                  setState(() {
                    _show = !_show;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
