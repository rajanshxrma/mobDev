// rajan sharma - in-class activity #5: digital pet app
// demonstrates state management in flutter using statefulwidget

import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  State<DigitalPetApp> createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  // pet state variables
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;

  // part 2: energy level for advanced features
  int _energyLevel = 100;

  // selected activity for dropdown
  String _selectedActivity = "Play";

  // controller for pet name text field
  final TextEditingController _nameController = TextEditingController();

  // timer for auto-increasing hunger
  Timer? _hungerTimer;

  // timer to track how long happiness has been above 80 (for win condition)
  Timer? _winTimer;
  int _happySeconds = 0;

  // game over flag
  bool _gameOver = false;
  bool _gameWon = false;

  @override
  void initState() {
    super.initState();
    // start auto-hunger timer: increases hunger every 30 seconds
    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_gameOver && !_gameWon) {
        _updateHunger();
      }
    });

    // start win condition timer: checks every second if happiness > 80
    _winTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameOver || _gameWon) return;
      if (happinessLevel > 80) {
        _happySeconds++;
        // win condition: happiness > 80 for 3 minutes (180 seconds)
        if (_happySeconds >= 180) {
          setState(() {
            _gameWon = true;
          });
          _showGameWonDialog();
        }
      } else {
        // reset counter if happiness drops below 80
        _happySeconds = 0;
      }
    });
  }

  @override
  void dispose() {
    // cancel timers to avoid memory leaks
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // determine pet color based on happiness level using colorfiltered
  // happy (>70): green | neutral (30-70): yellow | unhappy (<30): red
  Color _moodColor(double happinessLevel) {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  // get mood text and emoji based on happiness
  String _getMoodText() {
    if (happinessLevel > 70) {
      return "Happy 😊";
    } else if (happinessLevel >= 30) {
      return "Neutral 😐";
    } else {
      return "Unhappy 😢";
    }
  }

  // play with pet: increases happiness, costs energy
  void _playWithPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;
      // playing uses energy
      _energyLevel -= 10;
      if (_energyLevel < 0) _energyLevel = 0;
      _updateHunger();
    });
    _checkLossCondition();
  }

  // feed pet: decreases hunger
  void _feedPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      hungerLevel -= 10;
      if (hungerLevel < 0) hungerLevel = 0;
      _updateHappiness();
    });
    _checkLossCondition();
  }

  // update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
    } else {
      happinessLevel += 10;
    }
    if (happinessLevel > 100) happinessLevel = 100;
    if (happinessLevel < 0) happinessLevel = 0;
  }

  // auto hunger update: hunger increases over time
  void _updateHunger() {
    setState(() {
      hungerLevel += 5;
      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
        if (happinessLevel < 0) happinessLevel = 0;
      }
    });
    _checkLossCondition();
  }

  // check loss condition: hunger reaches 100 and happiness drops to 10
  void _checkLossCondition() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      setState(() {
        _gameOver = true;
      });
      _showGameOverDialog();
    }
  }

  // show game over dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Game Over'),
        content: const Text('your pet is too hungry and unhappy! the game is over.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: const Text('try again'),
          ),
        ],
      ),
    );
  }

  // show win dialog
  void _showGameWonDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('You Win! 🎉'),
        content: const Text('your pet has been happy for 3 minutes! great job!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _resetGame();
            },
            child: const Text('play again'),
          ),
        ],
      ),
    );
  }

  // reset game to initial state
  void _resetGame() {
    setState(() {
      happinessLevel = 50;
      hungerLevel = 50;
      _energyLevel = 100;
      _gameOver = false;
      _gameWon = false;
      _happySeconds = 0;
    });
  }

  // set custom pet name from text field
  void _setCustomName() {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        petName = _nameController.text.trim();
      });
      _nameController.clear();
    }
  }

  // part 2: perform selected activity from dropdown
  void _performActivity() {
    if (_gameOver || _gameWon) return;
    setState(() {
      switch (_selectedActivity) {
        case "Play":
          // playing increases happiness but costs energy and increases hunger
          happinessLevel += 10;
          _energyLevel -= 15;
          hungerLevel += 5;
          break;
        case "Run":
          // running costs more energy but increases happiness a lot
          happinessLevel += 15;
          _energyLevel -= 25;
          hungerLevel += 10;
          break;
        case "Sleep":
          // sleeping restores energy but increases hunger
          _energyLevel += 30;
          hungerLevel += 10;
          happinessLevel += 5;
          break;
        case "Bath":
          // bath slightly increases happiness, costs some energy
          happinessLevel += 5;
          _energyLevel -= 5;
          break;
      }
      // clamp all values between 0 and 100
      happinessLevel = happinessLevel.clamp(0, 100);
      hungerLevel = hungerLevel.clamp(0, 100);
      _energyLevel = _energyLevel.clamp(0, 100);
    });
    _checkLossCondition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // pet name customization input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'enter pet name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _setCustomName,
                      child: const Text('set name'),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // pet name display
                Text(
                  'Name: $petName',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 16.0),

                // pet image with dynamic color change using colorfiltered
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    _moodColor(happinessLevel.toDouble()),
                    BlendMode.modulate,
                  ),
                  child: Image.asset(
                    'assets/pet_image.png',
                    width: 150,
                    height: 150,
                  ),
                ),
                const SizedBox(height: 8.0),

                // mood indicator text and emoji
                Text(
                  'Mood: ${_getMoodText()}',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 16.0),

                // happiness level display
                Text(
                  'Happiness Level: $happinessLevel',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 16.0),

                // hunger level display
                Text(
                  'Hunger Level: $hungerLevel',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 16.0),

                // part 2: energy level display with progress bar
                Text(
                  'Energy Level: $_energyLevel',
                  style: const TextStyle(fontSize: 20.0),
                ),
                const SizedBox(height: 8.0),
                LinearProgressIndicator(
                  value: _energyLevel / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _energyLevel > 50 ? Colors.blue : Colors.orange,
                  ),
                  minHeight: 12,
                ),
                const SizedBox(height: 16.0),

                // game status text
                if (_gameOver)
                  const Text(
                    'Game Over! 💀',
                    style: TextStyle(fontSize: 24, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                if (_gameWon)
                  const Text(
                    'You Win! 🎉',
                    style: TextStyle(fontSize: 24, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 16.0),

                // play and feed buttons
                ElevatedButton(
                  onPressed: (!_gameOver && !_gameWon) ? _playWithPet : null,
                  child: const Text('Play with Your Pet'),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: (!_gameOver && !_gameWon) ? _feedPet : null,
                  child: const Text('Feed Your Pet'),
                ),
                const SizedBox(height: 24.0),

                // part 2: activity selection dropdown
                const Text(
                  'select an activity:',
                  style: TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                DropdownButton<String>(
                  value: _selectedActivity,
                  items: const [
                    DropdownMenuItem(value: "Play", child: Text("Play")),
                    DropdownMenuItem(value: "Run", child: Text("Run")),
                    DropdownMenuItem(value: "Sleep", child: Text("Sleep")),
                    DropdownMenuItem(value: "Bath", child: Text("Bath")),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedActivity = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: (!_gameOver && !_gameWon) ? _performActivity : null,
                  child: Text('do $_selectedActivity'),
                ),
                const SizedBox(height: 16.0),

                // win condition progress indicator
                Text(
                  'happy streak: $_happySeconds / 180 seconds',
                  style: const TextStyle(fontSize: 14.0, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
