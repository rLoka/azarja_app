import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// This is the main function, entrypoint of our app
// In this function we run our App
void main() {
  runApp(MyApp());
}

// The MyApp class extends StatelessWidget.
// Widgets are the elements from which you build every Flutter app.
// As you can see, even the app itself is a widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The state is created and provided to the whole app using a ChangeNotifierProvider.
    //This allows any widget in the app to get hold of the state.
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        // home defines a home or starting widget of our App
        home: MyHomePage(),
      ),
    );
  }
}

// MyAppState defines the data the app needs to function.
// The state class extends ChangeNotifier,
// which means that it can notify others about its own changes
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  // generics
  var favourites = <WordPair>[];

  // The new getNext() method reassigns current with a new random WordPair.
  // It also calls notifyListeners()(a method of ChangeNotifier)
  // that ensures that anyone watching MyAppState is notified.
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavourite() {
    if (favourites.contains(current)) {
      favourites.remove(current);
    } else {
      favourites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  // Every widget defines a build() method
  // that's automatically called every time the widget's circumstances change
  // so that the widget is always up to date.

  IconData generateLikeIcon(MyAppState myAppState) {
    if (myAppState.favourites.contains(myAppState.current)) {
      return Icons.favorite;
    }
    return Icons.favorite_border_outlined;
  }

  @override
  Widget build(BuildContext context) {
    // MyHomePage tracks changes to the app's current state using the watch method
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // Every build method must return a widget or (more typically) a nested tree of widgets
    // Scaffold is a helpful widget and is found in the vast majority of real-world Flutter apps.
    return Scaffold(
      // Wrapping a column widget centers it inside a scaffold
      // center may be used to center any widget for that purpose
      body: Center(
        child: Column(
          // mainAxisAlignment centers the content inside a column
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      appState.toggleFavourite();
                    },
                    icon: Icon(generateLikeIcon(appState)),
                    label: Text("Like")),
                ElevatedButton(
                    onPressed: () {
                      appState.getNext();
                    },
                    child: Text("Next")),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // By using theme.textTheme, you access the app's font theme.
    // This class includes members such as bodyMedium (for standard text of medium size),
    // caption (for captions of images), or headlineLarge (for large headlines).
    // The theme's displayMedium property could theoretically be null.
    // Dart, the programming language in which you're writing this app,
    // is null-safe, so it won't let you call methods of objects that are potentially null.
    // In this case, though, you can use the ! operator ("bang operator")
    // to assure Dart you know what you're doing.
    // Calling copyWith() on displayMedium returns a copy of the text style with
    // the changes you define. In this case, you're only changing the text's color.
    // The color scheme's onPrimary property defines a color that is a good fit
    // for use on the app's primary color.
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    // Note: Flutter uses Composition over Inheritance whenever it can.
    // Here, instead of padding being an attribute of Text, it's a widget!
    // This way, widgets can focus on their single responsibility,
    // and you, the developer, have total freedom in how to compose your UI.
    // For example, you can use the Padding widget to pad text, images, buttons,
    // your own custom widgets, or the whole app.
    // The widget doesn't care what it's wrapping.
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
