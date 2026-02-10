// rsharma30 in-class activity 02

import 'package:flutter/material.dart';

// entry point of the application
void main() {
  runApp(MyApp());
}

// myapp is a statefulwidget so we can manage the theme state
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // state variable to track the current theme mode
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Theme Demo',
      debugShowCheckedModeBanner: false,

      // light theme definition with cohesive color scheme
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),

      // dark theme definition
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
        ),
      ),

      // apply the current theme mode
      themeMode: _themeMode,

      // home screen with callback to toggle theme
      home: HomeScreen(
        themeMode: _themeMode,
        onThemeChanged: (ThemeMode mode) {
          setState(() {
            _themeMode = mode;
          });
        },
      ),
    );
  }
}

// homescreen displays the main ui with theme controls
class HomeScreen extends StatelessWidget {
  final ThemeMode themeMode;
  final Function(ThemeMode) onThemeChanged;

  HomeScreen({required this.themeMode, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // app bar with title
      appBar: AppBar(
        title: Text('Theme Demo'),
        centerTitle: true,
      ),
      // main body - centered column layout
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // container color changes based on the current theme
            AnimatedContainer(
              duration: const Duration(milliseconds: 500), // task 3: 500ms animation
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                // light mode: grey background, dark mode: white background
                color: themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
                // shadow for professional styling
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // phone icon at the top
                  Icon(
                    Icons.phone_android,
                    size: 40,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(height: 10),
                  // main title text - font size 18 as required
                  Text(
                    'Mobile App Development Testing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  // subtitle text
                  Text(
                    'Rajan Sharma',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // theme settings card section
            Card(
              margin: EdgeInsets.symmetric(horizontal: 40),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // section title
                    Text(
                      'Theme Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),

                    // switch widget with dynamic icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // sun icon for light mode
                        Icon(
                          Icons.wb_sunny,
                          color: themeMode == ThemeMode.light
                              ? Colors.orange
                              : Colors.grey,
                        ),

                        // switch widget to toggle theme
                        Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (isDark) {
                            onThemeChanged(
                              isDark ? ThemeMode.dark : ThemeMode.light,
                            );
                          },
                        ),

                        // moon icon for dark mode
                        Icon(
                          Icons.nightlight_round,
                          color: themeMode == ThemeMode.dark
                              ? Colors.yellow
                              : Colors.grey,
                        ),
                      ],
                    ),

                    // label showing current mode
                    Text(
                      themeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // light and dark buttons for theme switching
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // light mode button
                ElevatedButton(
                  onPressed: () {
                    onThemeChanged(ThemeMode.light);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text('Light'),
                ),
                SizedBox(width: 20),
                // dark mode button
                ElevatedButton(
                  onPressed: () {
                    onThemeChanged(ThemeMode.dark);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[800],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text('Dark'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
