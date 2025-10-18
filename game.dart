import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const espresso   = Color(0xFF5A402F);
const latte      = Color(0xFFC2A588);
const darkRoast  = Color(0xFF2E2218);

void main() => runApp(const MyGamebookApp());

class MyGamebookApp extends StatelessWidget {
  const MyGamebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameState(),
      child: MaterialApp(
        theme: ThemeData(
          textTheme: Theme.of(context).textTheme.copyWith(
            titleLarge: GoogleFonts.manrope(
              fontWeight: FontWeight.w500,
              fontSize: 16, 
            ),
          ),
        ),
        home: const GamePageHome(),
      ),
    );
  }
}

class GameState extends ChangeNotifier {
  int _coins = 100;
  int _beans = 20;
  int _customers = 10;
  int _day = 1;

  int get coins => _coins;
  int get beans => _beans;
  int get customers => _customers;
  int get day => _day;

  static const int _initialCoins = 100;
  static const int _initialBeans = 20;
  static const int _initialCustomers = 10;
  static const int _initialDay = 1;

  void reset() {
    _coins = _initialCoins;
    _beans = _initialBeans;
    _customers = _initialCustomers;
    _day = _initialDay;
    notifyListeners(); 
  }

  Future<void> saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', _coins);
    await prefs.setInt('beans', _beans);
    await prefs.setInt('customers', _customers);
    await prefs.setInt('day', _day);
  }

  Future<bool> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('coins')) {
      return false;
    }
    _coins = prefs.getInt('coins') ?? _initialCoins;
    _beans = prefs.getInt('beans') ?? _initialBeans;
    _customers = prefs.getInt('customers') ?? _initialCustomers;
    _day = prefs.getInt('day') ?? _initialDay;
    notifyListeners();
    return true;
  }

  bool buyBeans() {
    if (_coins >= 15) {
      _coins -= 15;
      _beans += 10;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool startDay() {
    if (_coins >= 5) {
      _coins -= 5;
      notifyListeners();
      return true;
    }
    return false;
  }

  void incrementDay() {
    _day += 1;
    notifyListeners();
  }

  bool morningRushServeEveryone() {
    if (_beans >= 30) {
      _beans -= 30;
      _customers += 5;
      _coins += 25;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool morningRushTurnAway() {
    if (_beans >= 15) {
      _beans -= 15;
      _customers = (_customers - 1).clamp(0, 999);
      _coins += 15;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool supplierBuyBulk() {
    if (_coins >= 35) {
      _coins -= 35;
      _beans += 30;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool supplierSkip() {
    notifyListeners();
    return true;
  }

  bool competitorPromotion() {
    if (_coins >= 20) {
      _coins -= 20;
      _customers += 10;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool competitorDoNothing() {
    _customers = (_customers - 2).clamp(0, 999);
    notifyListeners();
    return true;
  }

  bool equipmentRepair() {
    if (_coins >= 30) {
      _coins -= 30;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool equipmentDIY() {
    _customers = (_customers - 5).clamp(0, 999);
    notifyListeners();
    return true;
  }

  bool socialMediaFreeCoffee() {
    if (_beans >= 5) {
      _beans -= 5;
      _customers += 5;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool socialMediaIgnore() {
    _customers += 1;
    notifyListeners();
    return true;
  }

  bool quietDayServe() {
    if (_beans >= 5) {
      _beans -= 5;
      _coins += 10;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool hasWon() => _customers >= 30;
  bool hasLost() => _coins == 0 && _beans < 10;
  bool isGameOver() => _day > 6;
}

class ResourcesInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const ResourcesInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text('$label : $value'),
        ],
      )
    );
  }
}

class Choice extends StatelessWidget {
  final String text;
  final Widget Function(BuildContext context) func;
  final IconData icon;

  const Choice({super.key, required this.text, required this.func, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding (
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: latte,
          foregroundColor: darkRoast,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: func),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),  
          ]
        )
      )
    );
  }
}

class StateChoice extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool Function(GameState) action;
  final Widget Function(BuildContext context) nextPage;
  final String? errorMessage;

  const StateChoice({
    super.key,
    required this.text,
    required this.icon,
    required this.action,
    required this.nextPage,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: latte,
          foregroundColor: darkRoast,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
        onPressed: () {
          final gameState = Provider.of<GameState>(context, listen: false);
          bool success = action(gameState);
          
          if (success) {
            gameState.incrementDay();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: nextPage),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage ?? 'Cannot perform this action!'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
          ]
        )
      )
    );
  }
}

class ResourcesDisplay extends StatelessWidget {
  const ResourcesDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResourcesInfoRow(
                  icon: Icons.monetization_on,
                  color: Colors.yellow,
                  label: 'Coins',
                  value: gameState.coins,
                ),
                const SizedBox(height: 8),
                ResourcesInfoRow(
                  icon: Icons.local_cafe,
                  color: espresso,
                  label: 'Beans',
                  value: gameState.beans,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResourcesInfoRow(
                  icon: Icons.people,
                  color: Colors.blueGrey,
                  label: 'Customers',
                  value: gameState.customers,
                ),
                const SizedBox(height: 8),
                ResourcesInfoRow(
                  icon: Icons.calendar_month,
                  color: Colors.deepOrange,
                  label: 'Day',
                  value: gameState.day,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GamePageHome extends StatelessWidget {
  const GamePageHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/coffee_outside.png',
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Center(
                child: Choice(
                  icon: Icons.business,
                  text: "Start your business!",
                  func: (context) => const GamePageStart(),
                )
              )
            ),
          ],
        ),
      ),
    );
  }
}

class GamePageStart extends StatelessWidget {
  const GamePageStart({super.key});

  Widget _getEventForDay(int day) {
    switch (day) {
      case 1:
        return const GameEvent001();
      case 2:
        return const GameEvent002();
      case 3:
        return const GameEvent003();
      case 4:
        return const GameEvent004();
      case 5:
        return const GameEvent005();
      case 6:
        return const GameEvent006();
      default:
        return const GamePageStart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    if (gameState.isGameOver()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameEndScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Restart',
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Restart Game?'),
                  content: const Text('This will reset all progress to the beginning. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        gameState.reset();
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Game restarted!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: const Text('Roselyn Coffee Shop Executive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load',
            onPressed: () async {
              bool success = await gameState.loadGame();
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Game loaded successfully!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.blue,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No saved game found!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () async {
              await gameState.saveGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Game saved successfully!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/coffee_inside.png',
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (gameState.day <= 6)
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: latte,
                          foregroundColor: darkRoast,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)
                          )
                        ),
                        onPressed: () async {
                          if (gameState.coins < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Not enough coins to run the day! (Need 5 coins)'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          
                          gameState.startDay();
                          
                          if (!context.mounted) return;
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Daily costs: -5 coins'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.blue,
                            ),
                          );
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => _getEventForDay(gameState.day)),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.play_arrow_rounded),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Run the day",
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                          ]
                        )
                      ),
                    ),
                  Choice(
                    icon: Icons.local_cafe,
                    text: "Beans Supplies Shop",
                    func: (context) => const Beans(),
                  ),
                  Choice(
                    icon: Icons.note,
                    text: "Rules",
                    func: (context) => const Rules(),
                  ),
                  const ResourcesDisplay(),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}

class WinAnimation extends StatefulWidget {
  const WinAnimation({super.key});

  @override
  State<WinAnimation> createState() => _WinAnimationState();
}

class _WinAnimationState extends State<WinAnimation> {
  final List<double> sizes = [900, 900, 900, 900];
  final List<double> lefts = [0, -400, 0, -400];
  final List<double> tops = [0, -10, -330, -320];
  int iteration = 0;
  int duration = 3000;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: duration));
      if (mounted) {
        setState(() {
          iteration = (iteration + 1) % sizes.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: duration),
          top: tops[iteration],
          left: lefts[iteration],
          child: AnimatedContainer(
            duration: Duration(milliseconds: duration),
            width: sizes[iteration],
            child: Image.asset(
              'images/coffee_win.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class LoseAnimation extends StatefulWidget {
  const LoseAnimation({super.key});

  @override
  State<LoseAnimation> createState() => _LoseAnimationState();
}

class _LoseAnimationState extends State<LoseAnimation> {
  final List<double> sizes = [600, 600, 900, 900];
  final List<double> lefts = [0, -150, 0, -450];
  final List<double> tops = [0, -10, -700, -700];
  int iteration = 0;
  int duration = 3000;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      await Future.delayed(Duration(milliseconds: duration));
      if (mounted) {
        setState(() {
          iteration = (iteration + 1) % sizes.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: Duration(milliseconds: duration),
          top: tops[iteration],
          left: lefts[iteration],
          child: AnimatedContainer(
            duration: Duration(milliseconds: duration),
            width: sizes[iteration],
            child: Image.asset(
              'images/coffee_lose.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}

class GameEndScreen extends StatelessWidget {
  const GameEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final bool won = gameState.hasWon();
    
    return Scaffold(
      backgroundColor: won ? Colors.green.shade50 : Colors.red.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: ClipRect(
                  child: won ? const WinAnimation() : const LoseAnimation(),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        won ? 'YOU WON!' : 'GAME OVER',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: won ? Colors.green.shade800 : Colors.red.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        won 
                          ? 'You built a thriving business!'
                          : 'Your coffee shop closed down.',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Final Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('Coins: ${gameState.coins}', style: const TextStyle(fontSize: 14)),
                            Text('Beans: ${gameState.beans}', style: const TextStyle(fontSize: 14)),
                            Text('Customers: ${gameState.customers}', style: const TextStyle(fontSize: 14)),
                            Text('Days: ${gameState.day - 1}', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: latte,
                          foregroundColor: darkRoast,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          gameState.reset();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const GamePageHome()),
                            (route) => false,
                          );
                        },
                        child: const Text('Play Again', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameEvent001 extends StatelessWidget {
  const GameEvent001({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/morning_rush.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '25 customers arrive! Do you have enough beans?',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            StateChoice(
              icon: Icons.coffee,
              text: "Serve everyone (uses 30 beans, +5 customers, +25 coins)",
              action: (state) => state.morningRushServeEveryone(),
              nextPage: (context) => const GamePageStart(),
              errorMessage: 'Not enough beans! Need 30 beans.',
            ),
            StateChoice(
              icon: Icons.person_off,
              text: "Turn some away (uses 15 beans, -1 customer, +15 coins)",
              action: (state) => state.morningRushTurnAway(),
              nextPage: (context) => const GamePageStart(),
              errorMessage: 'Not enough beans! Need 15 beans.',
            ),
            const ResourcesDisplay(),
            if (gameState.beans < 30)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Not enough beans to serve everyone!',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameEvent002 extends StatelessWidget {
  const GameEvent002({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/supplier_deal.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Your supplier offers bulk beans at a discount!',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            StateChoice(
              icon: Icons.shopping_bag,
              text: "Buy 30 beans for 35 coins (good deal!)",
              action: (state) => state.supplierBuyBulk(),
              nextPage: (context) => const GamePageStart(),
              errorMessage: 'Not enough coins! Need 35 coins.',
            ),
            StateChoice(
              icon: Icons.cancel,
              text: "Skip it (no change)",
              action: (state) => state.supplierSkip(),
              nextPage: (context) => const GamePageStart(),
            ),
            const ResourcesDisplay(),
            if (gameState.coins < 35)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Not enough coins for bulk purchase!',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameEvent003 extends StatelessWidget {
  const GameEvent003({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/competitor_opens.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'A new café opened nearby! They are stealing customers.',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            StateChoice(
              icon: Icons.campaign,
              text: "Run a promotion (spend 20 coins, +10 customers)",
              action: (state) => state.competitorPromotion(),
              nextPage: (context) => const GamePageStart(),
              errorMessage: 'Not enough coins! Need 20 coins.',
            ),
            StateChoice(
              icon: Icons.do_not_disturb,
              text: "Do nothing (-2 customers)",
              action: (state) => state.competitorDoNothing(),
              nextPage: (context) => const GamePageStart(),
            ),
            const ResourcesDisplay(),
            if (gameState.coins < 20)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Not enough coins for promotion!',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameEvent004 extends StatelessWidget {
  const GameEvent004({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/equipment_breakdown.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Your espresso machine is broken!',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            StateChoice(
              icon: Icons.build,
              text: "Pay for repair (30 coins, keeps customers)",
              action: (state) => state.equipmentRepair(),
              nextPage: (context) => const GamePageStart(),
              errorMessage: 'Not enough coins! Need 30 coins.',
            ),
            StateChoice(
              icon: Icons.handyman,
              text: "DIY fix (-5 customers but free)",
              action: (state) => state.equipmentDIY(),
              nextPage: (context) => const GamePageStart(),
            ),
            const ResourcesDisplay(),
            if (gameState.coins < 30)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Not enough coins for professional repair!',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameEvent005 extends StatelessWidget {
  const GameEvent005({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/social_media_buzz.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'A food blogger posted about you!',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            StateChoice(
              icon: Icons.thumb_up,
              text: "Give them free coffee (-5 beans, +5 customers)",
              action: (state) => state.socialMediaFreeCoffee(),
              nextPage: (context) => const GamePageStart(),
              errorMessage: 'Not enough beans! Need 5 beans.',
            ),
            StateChoice(
              icon: Icons.thumb_down,
              text: "Ignore it (+1 customer)",
              action: (state) => state.socialMediaIgnore(),
              nextPage: (context) => const GamePageStart(),
            ),
            const ResourcesDisplay(),
            if (gameState.beans < 5)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Not enough beans for free coffee!',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameEvent006 extends StatelessWidget {
  const GameEvent006({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/quiet_day.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'It is a slow day...',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            StateChoice(
              icon: Icons.check_circle,
              text: "Only serve existing customers (uses 5 beans, +10 coins)",
              action: (state) => state.quietDayServe(),
              nextPage: (context) => const GamePageStart(),
              errorMessage: 'Not enough beans! Need 5 beans.',
            ),
            StateChoice(
              icon: Icons.do_not_disturb,
              text: "Do nothing (-2 customers)",
              action: (state) => state.competitorDoNothing(),
              nextPage: (context) => const GamePageStart(),
            ),
            const ResourcesDisplay(),
            if (gameState.beans < 5)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Not enough beans!',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Beans extends StatelessWidget {
  const Beans({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Roselyn Coffee Shop Executive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load',
            onPressed: () async {
              bool success = await gameState.loadGame();
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game loaded!'), backgroundColor: Colors.blue),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No saved game!'), backgroundColor: Colors.orange),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () async {
              await gameState.saveGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game saved!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/supplier_deal.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Buy Beans',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: latte,
                  foregroundColor: darkRoast,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  )
                ),
                onPressed: gameState.coins >= 15 ? () {
                  bool success = gameState.buyBeans();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Purchased 10 beans for 15 coins!'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } : null,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shopping_cart),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Buy 10 beans for 15 coins",
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  ]
                )
              ),
            ),
            if (gameState.coins < 15)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Not enough coins!',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Choice(
              icon: Icons.arrow_back,
              text: "Back to menu",
              func: (context) => const GamePageStart(),
            ),
            const ResourcesDisplay(),
          ],
        ),
      ),
    );
  }
}

class Rules extends StatelessWidget {
  const Rules({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: latte,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Restart',
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Restart Game?'),
                  content: const Text('This will reset all progress. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        gameState.reset();
                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Game restarted!')),
                        );
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        title: const Text('Roselyn Coffee Shop Executive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Load',
            onPressed: () async {
              bool success = await gameState.loadGame();
              if (!context.mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Game loaded!'), backgroundColor: Colors.blue),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No saved game!'), backgroundColor: Colors.orange),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save',
            onPressed: () async {
              await gameState.saveGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game saved!'), backgroundColor: Colors.green),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Image.asset(
                'images/coffee_outside.png',
                fit: BoxFit.contain,
              ),
            ),
            const Divider(),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Rules and How to Win',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Win condition: Reach 30 customers (you have built a thriving business!)\n\n'
                'Lose condition: Have 0 coins AND less than 10 beans (can not operate anymore)\n\n'
                'Daily costs: Each Run the Day costs 5 coins (rent/utilities)\n\n'
                'The game lasts 6 days',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Choice(
              icon: Icons.arrow_back,
              text: 'Back to menu',
              func: (context) => const GamePageStart(),
            ),
          ],
        ),
      ),
    );
  }
}
