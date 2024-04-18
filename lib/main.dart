import 'package:flutter/material.dart';
import 'models.dart';
import 'pose_detector_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.black, brightness: Brightness.dark),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Maa.Health'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _setCounter(int value) {
    setState(() {
      _counter = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            _setCounter(index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Exercise',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_food_beverage),
              label: 'Diet',
            ),
            NavigationDestination(
                icon: Icon(Icons.pie_chart), label: 'Diet Info'),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          indicatorColor: Theme.of(context).colorScheme.inversePrimary,
          selectedIndex: _counter),
      body: <Widget>[
        Column(
          children: [
            //list of exercises in Card form
            ListTile(
                title: Text("Exercise 1"),
                subtitle: Text("Description 1"),
                trailing: IconButton(
                  icon: const Icon(Icons.turn_right),
                  color: Theme.of(context).colorScheme.inversePrimary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ExerciseScreen(exerciseName: "Exercise 1")),
                    );
                  },
                )),
            ListTile(
                title: Text("Exercise 2"),
                subtitle: Text("Description 2"),
                trailing: IconButton(
                  icon: const Icon(Icons.turn_right),
                  color: Theme.of(context).colorScheme.inversePrimary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ExerciseScreen(exerciseName: "Exercise 2")),
                    );
                  },
                )),
          ],
        ),
        const DietSearchTab(),
        const DietInfoTab(),
        const SettingsTab(),
      ][_counter],
    );
  }
}

class DietSearchTab extends StatefulWidget {
  const DietSearchTab({super.key});
  @override
  State<DietSearchTab> createState() => _DietSearchTabState();
}

class _DietSearchTabState extends State<DietSearchTab> {
  String searchQuery = "";
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(children: [
          SearchBar(
            onChanged: (query) {
              setState(() {
                searchQuery = query;
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<Food>>(
              future: searchQuery.isEmpty ? foods_all() : foods(searchQuery),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index].name),
                        subtitle:
                            Text("Calories: ${snapshot.data![index].calories}"),
                        trailing: Column(children: [
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                addEatenFoodItem(snapshot.data![index].name);
                              }),
                          IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                reduceEatenFoodQuantity(
                                    snapshot.data![index].name);
                              }),
                        ]),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ]));
  }
}

class ExerciseScreen extends StatelessWidget {
  final String exerciseName;
  const ExerciseScreen({super.key, required this.exerciseName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //  title: Text(exerciseName),
      //),
      body: Column(
        children: [
          Expanded(child: PoseDetectorView()),
          Card(
            child: Column(
              children: [
                Text(exerciseName),
                const Text("The video would be here"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DietInfoTab extends StatelessWidget {
  const DietInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: FutureBuilder(
            future: eatenFoods(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].name),
                      subtitle: Text(
                          "Calories: ${snapshot.data![index].calories * snapshot.data![index].quantity}"),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            }));
  }
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String lang = "English";
  @override
  Widget build(BuildContext context) {
    return Center(
        child: DropdownButton<String>(
      value: lang,
      onChanged: (String? newValue) {
        setState(() {
          lang = newValue!;
        });
      },
      items: <String>["English", "Nepali", "Hindi"]
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ));
  }
}
