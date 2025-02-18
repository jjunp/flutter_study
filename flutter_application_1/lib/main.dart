import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(BigWheelApp());
}

class BigWheelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Big Wheel Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BigWheelScreen(),
    );
  }
}

class BigWheelScreen extends StatefulWidget {
  @override
  _BigWheelScreenState createState() => _BigWheelScreenState();
}

class _BigWheelScreenState extends State<BigWheelScreen>
    with TickerProviderStateMixin {
  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;
  bool _isSpinning = false;
  double _currentAngle = 0;
  String _selectedBet = '';

  final Map<int, String> numberToGrade = {
    for (int i = 1; i <= 24; i++) i: 'SILVER',
    for (int i = 25; i <= 39; i++) i: 'GOLD',
    for (int i = 40; i <= 46; i++) i: 'EMERALD',
    for (int i = 47; i <= 50; i++) i: 'DIAMOND',
    51: 'CRISTAL',
    52: 'CRISTAL',
    53: 'JOKER',
    54: 'MEGA',
  };

  int _currentNumber = 0;
  String _currentGrade = '';

  @override
  void initState() {
    super.initState();

    _wheelController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );

    _wheelAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _wheelController, curve: Curves.decelerate),
    );

    _arrowController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _arrowAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  void _startSpin() {
    if (_isSpinning || _selectedBet.isEmpty) return;

    _arrowController.repeat(reverse: true);
    final int randomTurns = Random().nextInt(3) + 3;
    final double endAngle =
        _currentAngle + (360 * randomTurns) + Random().nextDouble() * 360;

    _wheelAnimation = Tween<double>(
      begin: _currentAngle,
      end: endAngle,
    ).animate(
      CurvedAnimation(parent: _wheelController, curve: Curves.decelerate),
    );

    _wheelController.forward(from: 0);
    setState(() => _isSpinning = true);

    _wheelController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _arrowController.stop();
        setState(() {
          _isSpinning = false;
          _currentAngle = endAngle % 360;
          int totalSections = numberToGrade.length;
          int index =
              ((_currentAngle ~/ (360 / totalSections)) + 1) % totalSections;
          _currentNumber = index == 0 ? totalSections : index;
          _currentGrade = numberToGrade[_currentNumber] ?? 'UNKNOWN';
        });
      }
    });
  }

  void _placeBet(String grade) {
    setState(() {
      _selectedBet = grade;
    });
  }

  void _resetGame() {
    setState(() {
      _selectedBet = '';
      _currentNumber = 0;
      _currentGrade = '';
      _currentAngle = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Big Wheel Game')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _wheelAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _wheelAnimation.value * pi / 180,
                          child: Image.asset(
                            'assets/big_wheel.png',
                            width: 400,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: -40,
                      child: AnimatedBuilder(
                        animation: _arrowAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _arrowAnimation.value,
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 70,
                              color: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectedBet.isNotEmpty ? _startSpin : null,
                  child: Text(_isSpinning ? 'Spinning...' : 'Spin'),
                ),
                SizedBox(height: 20),
                // Text(
                //   'Number: $_currentNumber',
                //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                // ),
                Text(
                  'Grade: $_currentGrade',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                if (_selectedBet.isNotEmpty && _currentNumber != 0)
                  Text(
                    _selectedBet == _currentGrade
                        ? 'Bet Successful! ✅'
                        : 'Bet Failed ❌',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...numberToGrade.values.toSet().map((grade) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      onPressed: () => _placeBet(grade),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _selectedBet == grade ? Colors.green : null,
                      ),
                      child: Text('Bet on $grade'),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _resetGame,
                  child: Text('New Game', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
