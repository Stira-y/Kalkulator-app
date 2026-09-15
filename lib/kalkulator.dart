import 'package:flutter/material.dart';



class KalkulatorScreen extends StatefulWidget {

  final Function(String, String) onCalculate;



  KalkulatorScreen({required this.onCalculate});



  @override

  _KalkulatorScreenState createState() => _KalkulatorScreenState();

}



class _KalkulatorScreenState extends State<KalkulatorScreen> {

  String _expression = '';

  String _liveResult = '';

  bool _isCalculated = false;



  final Color _primaryColor = const Color(0xFF2CA211);



  bool _isOperator(String char) {

    return '+-×÷'.contains(char);

  }



  void _onButtonPressed(String value) {

    setState(() {

      if (value == 'AC') {

        _expression = '';

        _liveResult = '';

        _isCalculated = false;

      } else if (value == 'C') {

        _backspace();

      } else if (value == '=') {

        if (_expression.isNotEmpty && _liveResult.isNotEmpty && !_isCalculated) {

          _isCalculated = true;

          widget.onCalculate(_expression, _liveResult);

        }

      } else if (value == '+/-') {

        _toggleSign();

      }  

      else {

        _handleInput(value);

      }

     

      if (value != '=' && value != 'AC') {

        _calculateLiveResult();

      }

    });

  }



  void _handleInput(String value) {

    if (_isCalculated) {

      if (_isOperator(value)) {

        _expression = _liveResult + value;

      } else {

        _expression = value;

      }

      _isCalculated = false;

      _liveResult = '';

    } else {

      if (_expression.isNotEmpty && _isOperator(value) && _isOperator(_expression[_expression.length - 1])) {

        _expression = _expression.substring(0, _expression.length - 1) + value;

      } else {

        _expression += value;

      }

    }

  }



  void _backspace() {

    if (_isCalculated) {

      _expression = '';

      _liveResult = '';

      _isCalculated = false;

      return;

    }



    if (_expression.isNotEmpty) {

      if (_expression.endsWith(')')) {

        int openBracketIndex = _expression.lastIndexOf('(-');

        if (openBracketIndex != -1) {

          _expression = _expression.substring(0, _expression.length - 1);

        } else {

          _expression = _expression.substring(0, _expression.length - 1);

        }

      } else {

        _expression = _expression.substring(0, _expression.length - 1);

      }

    }

  }



  void _toggleSign() {

    if (_expression.isEmpty) return;



    if (_isCalculated) {

      _expression = _liveResult;

      _isCalculated = false;

    }



    RegExp regex = RegExp(r'(\(-\d+\.?\d*\)|\d+\.?\d*)$');

    Match? match = regex.firstMatch(_expression);



    if (match != null) {

      String lastPart = match.group(0)!;

      String newPart;



      if (lastPart.startsWith('(-') && lastPart.endsWith(')')) {

        newPart = lastPart.substring(2, lastPart.length - 1);

      } else {

        newPart = '(-$lastPart)';

      }



      _expression = _expression.substring(0, _expression.length - lastPart.length) + newPart;

    }

  }



  void _calculateLiveResult() {

    if (_expression.isEmpty) {

      _liveResult = '';

      return;

    }



    if (_isOperator(_expression[_expression.length - 1])) return;



    try {

      String evalStr = _expression.replaceAll('×', '*').replaceAll('÷', '/');

     

      evalStr = evalStr.replaceAllMapped(RegExp(r'(\d+\.?\d*)%'), (Match m) {

        double val = double.parse(m.group(1)!);

        return (val / 100).toString();

      });



      evalStr = evalStr.replaceAllMapped(RegExp(r'\(\-(.*?)\)'), (Match m) {

        return '(0-${m.group(1)})';

      });



      double result = _evaluateSimpleMath(evalStr);

     

      if (result % 1 == 0) {

        _liveResult = result.toInt().toString();

      } else {

        _liveResult = result.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');

      }

    } catch (e) {

      // Abaikan error saat user sedang mengetik

    }

  }



  double _evaluateSimpleMath(String expr) {

    if (expr.contains('(')) {

      int openIdx = expr.lastIndexOf('(');

      int closeIdx = expr.indexOf(')', openIdx);

      if (closeIdx != -1) {

        String inside = expr.substring(openIdx + 1, closeIdx);

        double insideResult = _evaluateSimpleMath(inside);

        String newExpr = expr.substring(0, openIdx) + insideResult.toString() + expr.substring(closeIdx + 1);

        return _evaluateSimpleMath(newExpr);

      }

    }



    List<String> tokens = [];

    String temp = '';

    for (int i = 0; i < expr.length; i++) {

      if ('+-*/'.contains(expr[i])) {

        if (expr[i] == '-' && (i == 0 || '+-*/'.contains(expr[i - 1]))) {

          temp += expr[i];

        } else {

          if (temp.isNotEmpty) tokens.add(temp);

          tokens.add(expr[i]);

          temp = '';

        }

      } else {

        temp += expr[i];

      }

    }

    if (temp.isNotEmpty) tokens.add(temp);



    for (int i = 0; i < tokens.length; i++) {

      if (tokens[i] == '*' || tokens[i] == '/') {

        double left = double.parse(tokens[i - 1]);

        double right = double.parse(tokens[i + 1]);

        double res = tokens[i] == '*' ? left * right : left / right;

        tokens.replaceRange(i - 1, i + 2, [res.toString()]);

        i -= 2;

      }

    }



    double total = double.parse(tokens[0]);

    for (int i = 1; i < tokens.length; i += 2) {

      String op = tokens[i];

      double val = double.parse(tokens[i + 1]);

      if (op == '+') total += val;

      if (op == '-') total -= val;

    }



    return total;

  }



  @override

  Widget build(BuildContext context) {

    return Column(

      children: [

        // AREA DISPLAY (Porsi Flex 3)

        Expanded(

          flex: 3,

          child: Container(

            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),

            alignment: Alignment.bottomRight,

            child: Column(

              mainAxisAlignment: MainAxisAlignment.end,

              crossAxisAlignment: CrossAxisAlignment.end,

              children: [

                SingleChildScrollView(

                  scrollDirection: Axis.horizontal,

                  reverse: true,

                  child: Text(

                    _expression.isEmpty ? '0' : _expression,

                    style: TextStyle(

                      fontSize: _isCalculated ? 22 : 38,

                      color: _isCalculated ? Colors.grey[600] : Colors.black87,

                      fontWeight: _isCalculated ? FontWeight.normal : FontWeight.w500,

                    ),

                  ),

                ),

                SizedBox(height: 8),

                if (_liveResult.isNotEmpty || _isCalculated)

                  SingleChildScrollView(

                    scrollDirection: Axis.horizontal,

                    reverse: true,

                    child: Text(

                      '= $_liveResult',

                      style: TextStyle(

                        fontSize: _isCalculated ? 38 : 22,

                        color: _isCalculated ? Colors.black87 : Colors.grey[600],

                        fontWeight: _isCalculated ? FontWeight.w500 : FontWeight.normal,

                      ),

                    ),

                  ),

              ],

            ),

          ),

        ),



        // AREA KEYPAD (Porsi Flex 5)

        Expanded(

          flex: 5,

          child: Container(

            padding: EdgeInsets.all(12),

            child: Column(

              children: [

                Expanded(

                  child: Row(

                    children: [

                      _buildButton('AC', textColor: _primaryColor),

                      _buildButton('C', textColor: _primaryColor),

                      _buildButton('%', textColor: _primaryColor),

                      _buildButton('÷', textColor: _primaryColor),

                    ],

                  ),

                ),

                Expanded(

                  child: Row(

                    children: [

                      _buildButton('7'),

                      _buildButton('8'),

                      _buildButton('9'),

                      _buildButton('×', textColor: _primaryColor),

                    ],

                  ),

                ),

                Expanded(

                  child: Row(

                    children: [

                      _buildButton('4'),

                      _buildButton('5'),

                      _buildButton('6'),

                      _buildButton('-', textColor: _primaryColor),

                    ],

                  ),

                ),

                Expanded(

                  child: Row(

                    children: [

                      _buildButton('1'),

                      _buildButton('2'),

                      _buildButton('3'),

                      _buildButton('+', textColor: _primaryColor),

                    ],

                  ),

                ),

                Expanded(

                  child: Row(

                    children: [

                      _buildButton('+/-', textColor: _primaryColor),

                      _buildButton('0'),

                      _buildButton(','),

                      _buildButton('=', bgColor: _primaryColor, textColor: Colors.white),

                    ],

                  ),

                ),

              ],

            ),

          ),

        ),

      ],

    );

  }



  Widget _buildButton(String text, {Color? bgColor, Color? textColor}) {

    return Expanded(

      child: Container(

        margin: EdgeInsets.all(6),

        child: ElevatedButton(

          style: ElevatedButton.styleFrom(

            backgroundColor: bgColor ?? Colors.white,

            elevation: 0,

            shape: RoundedRectangleBorder(

              borderRadius: BorderRadius.circular(20),

            ),

            padding: EdgeInsets.zero,

          ),

          onPressed: () {

            String input = text == ',' ? '.' : text;

            _onButtonPressed(input);

          },

          child: Text(

            text,

            style: TextStyle(

              fontSize: 28,

              fontWeight: FontWeight.w400,

              color: textColor ?? Colors.black87,

            ),

          ),

        ),

      ),

    );

  }

}