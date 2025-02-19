import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  // Base pet stats
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int _energyLevel = 50; // New energy level state variable

  // Game state flags
  bool _gameOver = false;
  bool _gameWon = false;
  int _winCounter = 0; // Counts seconds of continuous happiness above 80

  // Activity selection (nullable type)
  String? selectedActivity;
  List<String> activities = ["Walk", "Nap", "Do Tricks"];

  // Text controller for pet name customization
  TextEditingController _nameController = TextEditingController();

  // Timers for automatic hunger increase and win condition check (marked as late)
  late Timer _hungerTimer;
  late Timer _winTimer;

  @override
  void initState() {
    super.initState();
    // Automatically increase hunger every 10 seconds
    _hungerTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (!_gameOver && !_gameWon) {
        setState(() {
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          // If hunger is maxed out and happiness is very low, trigger loss.
          if (hungerLevel >= 100 && happinessLevel <= 10) {
            _triggerGameOver();
          }
        });
      }
    });
    // Check win condition every second: if happiness >80 continuously for 3 minutes (180 seconds)
    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_gameOver && !_gameWon) {
        if (happinessLevel > 80) {
          _winCounter++;
          if (_winCounter >= 3) {
            _triggerWin();
          }
        } else {
          _winCounter = 0;
        }
      }
    });
  }

  @override
  void dispose() {
    _hungerTimer.cancel();
    _winTimer.cancel();
    _nameController.dispose();
    super.dispose();
  }

  // Dynamic pet color based on happiness level
  Color getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  // Mood indicator based on happiness level with an emoji
  String getPetMood() {
    if (happinessLevel > 70) {
      return "Happy 😊";
    } else if (happinessLevel >= 30) {
      return "Neutral 😐";
    } else {
      return "Unhappy 😢";
    }
  }

  // Play with pet: increases happiness, reduces energy, and increases hunger slightly.
  void _playWithPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _energyLevel = (_energyLevel - 5).clamp(0, 100);
      _updateHunger();
      if (hungerLevel >= 100 && happinessLevel <= 10) {
        _triggerGameOver();
      }
    });
  }

  // Feed pet: reduces hunger and updates happiness.
  void _feedPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
    });
  }

  // Update happiness based on hunger level.
  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Increase hunger level slightly when playing with the pet.
  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel >= 100) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  // Activity selection: perform an activity that updates pet stats.
  void _performActivity() {
    if (_gameOver || _gameWon) return;
    if (selectedActivity == null) return;
    setState(() {
      switch (selectedActivity) {
        case "Walk":
          happinessLevel = (happinessLevel + 10).clamp(0, 100);
          _energyLevel = (_energyLevel - 10).clamp(0, 100);
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          break;
        case "Nap":
          _energyLevel = (_energyLevel + 20).clamp(0, 100);
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          happinessLevel = (happinessLevel + 5).clamp(0, 100);
          break;
        case "Do Tricks":
          happinessLevel = (happinessLevel + 15).clamp(0, 100);
          _energyLevel = (_energyLevel - 5).clamp(0, 100);
          hungerLevel = (hungerLevel + 5).clamp(0, 100);
          break;
        default:
          break;
      }
      if (hungerLevel >= 100 && happinessLevel <= 10) {
        _triggerGameOver();
      }
    });
  }

  // Trigger win condition: pet remains happy long enough.
  void _triggerWin() {
    _gameWon = true;
    _showDialog("You Win!", "Your pet has been happy for 3 minutes. Congratulations!");
  }

  // Trigger game over condition.
  void _triggerGameOver() {
    _gameOver = true;
    _showDialog("Game Over", "Your pet has become too hungry and unhappy. Game Over.");
  }

  // Simple dialog to display messages
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Pet Name Customization
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter pet name',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (_nameController.text.isNotEmpty) {
                      petName = _nameController.text;
                    }
                  });
                },
                child: Text('Set Name'),
              ),
              SizedBox(height: 16.0),
              // Pet representation with dynamic color (a simple circle)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: getPetColor(),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    petName.isNotEmpty ? petName[0] : "",
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              // Pet Mood Indicator
              Text(
                'Mood: ${getPetMood()}',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              // Display pet stats
              Text(
                'Happiness Level: $happinessLevel',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 8.0),
              Text(
                'Hunger Level: $hungerLevel',
                style: TextStyle(fontSize: 20.0),
              ),
              SizedBox(height: 16.0),
              // Energy Bar Widget
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      'Energy Level: $_energyLevel',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    SizedBox(height: 8.0),
                    LinearProgressIndicator(
                      value: _energyLevel / 100,
                      minHeight: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              // Interaction buttons
              ElevatedButton(
                onPressed: _playWithPet,
                child: Text('Play with Your Pet'),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: _feedPet,
                child: Text('Feed Your Pet'),
              ),
              SizedBox(height: 16.0),
              // Activity Selection Dropdown and Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButton<String>(
                  hint: Text('Select an Activity'),
                  value: selectedActivity,
                  isExpanded: true,
                  items: activities.map((String activity) {
                    return DropdownMenuItem<String>(
                      value: activity,
                      child: Text(activity),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedActivity = newValue;
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _performActivity,
                child: Text('Perform Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
