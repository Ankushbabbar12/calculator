import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Ankush Calculator'),

        ),
        body: Calculator(),
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _expression = '';
  String _output = '';

  @override
  void initState() {
    super.initState();
    _loadLastResult();
  }

  void _loadLastResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastResult = prefs.getString('last_result') ?? '';
    setState(() {
      _output = lastResult;
    });
  }

  void _onPressed(String text) {
    setState(() {
      if (_output == 'ERROR') {
        _output = '';
        _expression = '';
      }
      if (text == 'CE') {
        _output = '';
        _expression = '';
      } else if (text == 'C') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          _output = _expression;
        }
      } else if (text == '=') {
        _calculate();
      } else {
        _expression += text;
        _output = _expression;
      }
    });
  }

  void _calculate() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_expression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _output = eval.toString();
        _expression = '';
      });
      _saveLastResult(eval.toString());
    } catch (e) {
      setState(() {
        _output = 'ERROR';
        _expression = '';
      });
    }
  }

  void _saveLastResult(String result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_result', result);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(16.0),
            child: Text(
              _output,
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ),
        Divider(height: 0.0),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildRow(['7', '8', '9', '/']),
              _buildRow(['4', '5', '6', '*']),
              // Changed 'x' to '*'
              _buildRow(['1', '2', '3', '-']),
              _buildRow(['0', 'CE', 'C', '+']),
              _buildRow(['=','.']),
              // Additional row for decimal and equals
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> texts) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: texts
            .map((text) => _buildButton(text))
            .toList()
            .expand((widget) => [widget, SizedBox(width: 1)])
            .toList()
          ..removeLast(),
      ),
    );
  }
  Widget _buildButton(String text) {
    Color textColor;
    Color? boxColor;

    // Set text and box color based on button type
    if (text == 'CE' || text == 'C') {
      textColor = Colors.white;
      boxColor = Colors.red;
    } else if (text == '+' || text == '-' || text == '*' || text == '/' || text == '.') {
      textColor = Colors.white;
      boxColor = Colors.blue;
    } else if (text == '=') {
      textColor = Colors.white;
      boxColor = Colors.green;
    }else {
      textColor = Colors.black;
    }


    return Expanded(
      child: Container(
        color: boxColor, // Apply box color only if it's defined
        child: TextButton(
          onPressed: () {
            _onPressed(text);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: Ink(
            decoration: boxColor != null
                ? BoxDecoration(
              border: Border.all(color: Colors.grey), // Add border for better visibility
            )
                : null, // Remove decoration if box color is null
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24.0,
                  color: textColor, // Apply calculated text color
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
