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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // This class extends State, and can therefore manage its own values.
  // (It can change itself.)
  var selectedIndex = 0;

  // Every widget defines a build() method
  @override
  Widget build(BuildContext context) {
    // MyHomePage tracks changes to the app's current state using the watch method
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError("No widget for selected index");
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        // Every build method must return a widget or (more typically) a nested tree of widgets
        // Scaffold is a helpful widget and is found in the vast majority of real-world Flutter apps.
        // The new MyHomePage contains a Row with two children.
        // The first widget is SafeArea, and the second is an Expanded widget.
        body: Row(
          children: [
            // The SafeArea ensures that its child is not obscured by a hardware
            // notch or a status bar. In this app, the widget wraps around
            // NavigationRail to prevent the navigation buttons from being
            // obscured by a mobile status bar, for example.
            SafeArea(
              child: NavigationRail(
                // When enabled, extended shows the labels next to the icons
                extended: constraints.maxWidth >= 1000,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                // A selected index of zero selects the first destination
                selectedIndex: selectedIndex,
                // defines what happens when the user selects one of the destinations
                onDestinationSelected: (value) {
                  // setState() is similar to the notifyListeners() method used
                  // previously—it makes sure that the UI updates.
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            // Expanded widgets are extremely useful in rows and columns—they let
            // you express layouts where some children take only as much space
            // as they need (we can call them greedy)
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favourites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavourite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
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

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    /* return Center(
        child: ListView.builder(
            itemCount: appState.favourites.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(appState.favourites[index].asLowerCase));
            }));
    */
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favourites.length} favorites:'),
        ),
        // Dart allows using for loops inside collection literals.
        for (var pair in appState.favourites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// Next:
// https://codelabs.developers.google.com/codelabs/flutter-codelab-first#8
// https://flutter.dev/learn