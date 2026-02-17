// rsharma - class activity 4: stateful widget counter app
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

// root app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // this widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // application name
      title: 'Stateful Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // a widget that will be started on the application startup
      home: CounterWidget(),
    );
  }
}

// stateful widget for the counter
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  // initial counter value
  int _counter = 0;

  // maximum counter limit
  final int _maxLimit = 100;

  // custom increment value controller
  final TextEditingController _incrementController = TextEditingController(text: '1');

  // history of counter values
  final List<int> _history = [];

  // tracks whether we already showed the dialog for 50 and 100
  bool _showed50 = false;
  bool _showed100 = false;

  // get the current custom increment value (defaults to 1 if invalid)
  int get _incrementValue {
    int? val = int.tryParse(_incrementController.text);
    if (val == null || val <= 0) return 1;
    return val;
  }

  // determine background color based on counter value
  // red when counter is 0, green when counter exceeds 50, blue otherwise
  Color _getDisplayColor() {
    if (_counter == 0) return Colors.red;
    if (_counter > 50) return Colors.green;
    return Colors.blue;
  }

  // increment counter by custom value
  void _incrementCounter() {
    setState(() {
      // save current value to history before changing
      _history.add(_counter);
      int newVal = _counter + _incrementValue;
      // enforce maximum limit
      if (newVal > _maxLimit) {
        newVal = _maxLimit;
      }
      _counter = newVal;
    });
    // check if max limit was reached
    if (_counter >= _maxLimit) {
      _showMessage('Maximum limit reached!');
    }
    // check for milestone targets
    _checkMilestones();
  }

  // decrement counter by custom value with a limit of 0
  void _decrementCounter() {
    setState(() {
      // save current value to history before changing
      _history.add(_counter);
      int newVal = _counter - _incrementValue;
      // don't go below 0
      if (newVal < 0) newVal = 0;
      _counter = newVal;
    });
    // check for milestone targets
    _checkMilestones();
  }

  // reset the counter back to 0
  void _resetCounter() {
    setState(() {
      // save current value to history before resetting
      _history.add(_counter);
      _counter = 0;
      // reset milestone flags
      _showed50 = false;
      _showed100 = false;
    });
  }

  // undo: revert counter to the previous value from history
  void _undo() {
    if (_history.isNotEmpty) {
      setState(() {
        _counter = _history.removeLast();
      });
    }
  }

  // show a snackbar message
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // check if counter hit milestones (50 or 100) and show dialog
  void _checkMilestones() {
    if (_counter == 50 && !_showed50) {
      _showed50 = true;
      _showCongratulationsDialog(50);
    }
    if (_counter == 100 && !_showed100) {
      _showed100 = true;
      _showCongratulationsDialog(100);
    }
  }

  // display a congratulatory pop-up dialog for reaching a target
  void _showCongratulationsDialog(int target) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('congratulations!'),
        content: Text('you reached the target value of $target!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ok'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _incrementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stateful Widget'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // counter display with color feedback
            Center(
              child: Container(
                color: _getDisplayColor(),
                padding: const EdgeInsets.all(16),
                child: Text(
                  // displays the current number
                  '$_counter',
                  style: const TextStyle(fontSize: 50.0, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // slider to change counter value
            Slider(
              min: 0,
              max: 100,
              value: _counter.toDouble(),
              onChanged: (double value) {
                setState(() {
                  // save current value to history
                  _history.add(_counter);
                  _counter = value.toInt();
                });
                // reset milestone flags if slider moves below targets
                if (_counter < 50) _showed50 = false;
                if (_counter < 100) _showed100 = false;
                // check milestones
                _checkMilestones();
              },
              activeColor: Colors.blue,
              inactiveColor: Colors.red,
            ),
            const SizedBox(height: 10),

            // custom increment value input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _incrementController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'custom increment value',
                  hintText: 'enter a number (e.g., 1, 2, 5)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) {
                  // validate input - only allow numbers
                  if (val.isNotEmpty && int.tryParse(val) == null) {
                    _showMessage('please enter a valid number');
                  }
                  // trigger rebuild to reflect new increment value
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 10),

            // increment, decrement, reset buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // increment button
                ElevatedButton(
                  onPressed: _counter < _maxLimit ? _incrementCounter : null,
                  child: const Text('increment'),
                ),
                const SizedBox(width: 8),
                // decrement button - disabled when counter is 0
                ElevatedButton(
                  onPressed: _counter > 0 ? _decrementCounter : null,
                  child: const Text('decrement'),
                ),
                const SizedBox(width: 8),
                // reset button
                ElevatedButton(
                  onPressed: _counter > 0 ? _resetCounter : null,
                  child: const Text('reset'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // undo button
            ElevatedButton(
              onPressed: _history.isNotEmpty ? _undo : null,
              child: const Text('undo'),
            ),
            const SizedBox(height: 16),

            // counter history section
            const Text(
              'counter history:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // display history list below the slider
            Container(
              height: 150,
              width: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _history.isEmpty
                  ? const Center(child: Text('no history yet'))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        // show history in reverse order (newest first)
                        int reverseIndex = _history.length - 1 - index;
                        return ListTile(
                          dense: true,
                          leading: Text('#${reverseIndex + 1}'),
                          title: Text('value: ${_history[reverseIndex]}'),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
