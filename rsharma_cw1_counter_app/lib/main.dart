// rsharma - cw1 counter & image toggle app
import 'package:flutter/material.dart';

void main() {
  runApp(const CounterImageToggleApp());
}

// main app widget
class CounterImageToggleApp extends StatelessWidget {
  const CounterImageToggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW1 Counter & Toggle',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

// homepage is stateful because we need to track counter, theme, and image
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;
  bool _isDark = false;
  bool _isFirstImage = true;
  int _stepSize = 1; // current step size for multi-step controls

  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    // set up animation controller for image fade
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // increment counter by current step size
  void _incrementCounter() {
    setState(() => _counter += _stepSize);
  }

  // decrement counter by current step size
  void _decrementCounter() {
    setState(() {
      _counter -= _stepSize;
      // don't go below 0
      if (_counter < 0) _counter = 0;
    });
  }

  // reset counter back to 0
  void _resetCounter() {
    setState(() => _counter = 0);
  }

  // toggle between light and dark theme
  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  // toggle between the two images with animation
  void _toggleImage() {
    if (_isFirstImage) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFirstImage = !_isFirstImage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CW1 Counter & Toggle'),
          actions: [
            // theme toggle button in app bar
            IconButton(
              onPressed: _toggleTheme,
              icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // counter display
              Text(
                'Counter: $_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),

              // step size selector row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Step: '),
                  // +1 button
                  ChoiceChip(
                    label: const Text('+1'),
                    selected: _stepSize == 1,
                    onSelected: (_) => setState(() => _stepSize = 1),
                  ),
                  const SizedBox(width: 8),
                  // +5 button
                  ChoiceChip(
                    label: const Text('+5'),
                    selected: _stepSize == 5,
                    onSelected: (_) => setState(() => _stepSize = 5),
                  ),
                  const SizedBox(width: 8),
                  // +10 button
                  ChoiceChip(
                    label: const Text('+10'),
                    selected: _stepSize == 10,
                    onSelected: (_) => setState(() => _stepSize = 10),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // increment, decrement, reset buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // decrement button - disabled when counter is 0
                  ElevatedButton(
                    onPressed: _counter > 0 ? _decrementCounter : null,
                    child: const Text('Decrement'),
                  ),
                  const SizedBox(width: 8),
                  // increment button
                  ElevatedButton(
                    onPressed: _incrementCounter,
                    child: const Text('Increment'),
                  ),
                  const SizedBox(width: 8),
                  // reset button - disabled when counter is 0
                  ElevatedButton(
                    onPressed: _counter > 0 ? _resetCounter : null,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // image with fade animation
              FadeTransition(
                opacity: _fade,
                child: Image.asset(
                  _isFirstImage ? 'assets/image1.jpg' : 'assets/image2.jpg',
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),

              // toggle image button
              ElevatedButton(
                onPressed: _toggleImage,
                child: const Text('Toggle Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
