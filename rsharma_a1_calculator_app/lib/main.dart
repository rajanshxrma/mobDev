// rajan sharma - assignment 01: simple calculator app
// csc 4360 - mobile app development
// features implemented: clear/all clear, percentage operation, positive/negative toggle

import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1C2E),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // state variables for calculator logic
  String _display = '0';
  String _firstOperand = '';
  String _operator = '';
  bool _shouldResetDisplay = false;

  // handles number button presses
  void _onNumberPressed(String number) {
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = number;
        _shouldResetDisplay = false;
      } else {
        _display += number;
      }
    });
  }

  // handles decimal point
  void _onDecimalPressed() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  // handles operator button presses (+, -, ×, ÷)
  void _onOperatorPressed(String operator) {
    setState(() {
      // if there's already a pending operation, calculate first
      if (_firstOperand.isNotEmpty && _operator.isNotEmpty && !_shouldResetDisplay) {
        _calculateResult();
      }
      _firstOperand = _display;
      _operator = operator;
      _shouldResetDisplay = true;
    });
  }

  // performs the calculation and updates display
  void _calculateResult() {
    if (_firstOperand.isEmpty || _operator.isEmpty) return;

    double num1 = double.parse(_firstOperand);
    double num2 = double.parse(_display);
    double result = 0;

    setState(() {
      switch (_operator) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '×':
          result = num1 * num2;
          break;
        case '÷':
          // error handling: division by zero
          if (num2 == 0) {
            _display = 'Error';
            _firstOperand = '';
            _operator = '';
            _shouldResetDisplay = true;
            return;
          }
          result = num1 / num2;
          break;
      }

      // format result: remove trailing .0 for whole numbers
      _display = _formatResult(result);
      _firstOperand = '';
      _operator = '';
      _shouldResetDisplay = true;
    });
  }

  // formats the result to remove unnecessary decimal places
  String _formatResult(double result) {
    if (result == result.toInt().toDouble()) {
      return result.toInt().toString();
    }
    // limit to 8 decimal places to avoid display overflow
    String formatted = result.toStringAsFixed(8);
    // remove trailing zeros
    formatted = formatted.replaceAll(RegExp(r'0+$'), '');
    formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    return formatted;
  }

  // feature: clear/all clear - resets calculator to initial state
  void _onClearPressed() {
    setState(() {
      _display = '0';
      _firstOperand = '';
      _operator = '';
      _shouldResetDisplay = false;
    });
  }

  // feature: positive/negative toggle - switches sign of current number
  void _onToggleSignPressed() {
    setState(() {
      if (_display == '0' || _display == 'Error') return;

      if (_display.startsWith('-')) {
        _display = _display.substring(1);
      } else {
        _display = '-$_display';
      }
    });
  }

  // feature: percentage operation - converts current number to percentage
  void _onPercentPressed() {
    setState(() {
      if (_display == 'Error') return;

      double value = double.parse(_display);
      double result = value / 100;
      _display = _formatResult(result);
    });
  }

  // handles equals button press
  void _onEqualsPressed() {
    if (_firstOperand.isNotEmpty && _operator.isNotEmpty) {
      // error handling: pressing = without entering second operand
      if (_display == 'Error') return;
      _calculateResult();
    }
  }

  // builds a calculator button with consistent styling
  Widget _buildButton(String text, {Color? buttonColor, Color? textColor, int flex = 1}) {
    Color bgColor = buttonColor ?? const Color(0xFF2D2D44);
    Color txtColor = textColor ?? Colors.white;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        // button press animation using inkwell for tap feedback
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _handleButtonPress(text),
            splashColor: Colors.white24,
            child: Container(
              height: 72,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: txtColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // routes button presses to the correct handler
  void _handleButtonPress(String text) {
    switch (text) {
      case 'C':
        _onClearPressed();
        break;
      case '±':
        _onToggleSignPressed();
        break;
      case '%':
        _onPercentPressed();
        break;
      case '÷':
      case '×':
      case '-':
      case '+':
        if (_display != 'Error') {
          _onOperatorPressed(text);
        }
        break;
      case '=':
        _onEqualsPressed();
        break;
      case '.':
        _onDecimalPressed();
        break;
      default:
        // number buttons
        if (_display == 'Error') {
          _onClearPressed();
        }
        _onNumberPressed(text);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // colors matching the expected ui mockup
    const Color functionColor = Color(0xFF3B3B5C);
    const Color operatorColor = Color(0xFF7C5CFC);
    const Color functionTextColor = Color(0xFF50E3A4);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // display area - shows current number or result
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _display,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
            ),

            // button grid - 4 columns layout
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // row 1: C, ±, %, ÷
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('C', buttonColor: functionColor, textColor: functionTextColor),
                          _buildButton('±', buttonColor: functionColor, textColor: functionTextColor),
                          _buildButton('%', buttonColor: functionColor, textColor: functionTextColor),
                          _buildButton('÷', buttonColor: operatorColor),
                        ],
                      ),
                    ),
                    // row 2: 7, 8, 9, ×
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('7'),
                          _buildButton('8'),
                          _buildButton('9'),
                          _buildButton('×', buttonColor: operatorColor),
                        ],
                      ),
                    ),
                    // row 3: 4, 5, 6, -
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('4'),
                          _buildButton('5'),
                          _buildButton('6'),
                          _buildButton('-', buttonColor: operatorColor),
                        ],
                      ),
                    ),
                    // row 4: 1, 2, 3, +
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('1'),
                          _buildButton('2'),
                          _buildButton('3'),
                          _buildButton('+', buttonColor: operatorColor),
                        ],
                      ),
                    ),
                    // row 5: 0 (wide), ., =
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton('0', flex: 2),
                          _buildButton('.'),
                          _buildButton('=', buttonColor: operatorColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
