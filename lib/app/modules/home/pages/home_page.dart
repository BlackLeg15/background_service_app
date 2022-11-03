import 'dart:async';

import 'package:background_service_app/app/modules/home/method_channels/keep_app_on_channel.dart';
import 'package:background_service_app/app/modules/home/services/counter_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  Future<SharedPreferences> sharedPreferencesFuture = SharedPreferences.getInstance();
  late KeepAppOnChannel keepAppOnChannel;
  late Future initializers;
  late CounterService counterService;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    keepAppOnChannel = KeepAppOnChannel();
    initializers = Future.wait<dynamic>([
      initializeNotificationsChannel(),
      sharedPreferencesFuture.then((value) {
        counterService = CounterService('test', value);
      })
    ]);
  }

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late NotificationDetails platformChannelSpecifics;

  Future<bool> initializeNotificationsChannel() async {
    try {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      const androidInitializationSettings = AndroidInitializationSettings('app_icon');
      const initializationSettings = InitializationSettings(android: androidInitializationSettings);

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      const androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '493de931f3c92df6084ac2b3238ed309',
        'BATTERY_NOTIFICATION',
        importance: Importance.max,
        priority: Priority.high,
      );
      platformChannelSpecifics = const NotificationDetails(android: androidPlatformChannelSpecifics);
      return true;
    } catch (error) {
      onErrorWhenInitializingNotificationsChannel();
      return false;
    }
  }

  var notificationsChannelInitializationError = '';

  void onErrorWhenInitializingNotificationsChannel() {
    notificationsChannelInitializationError = 'Não foi possível inicializar o canal de notificações';
  }

  void showSnackBar({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> showNotification(String description) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Counter: ',
        description,
        platformChannelSpecifics,
      );
    } catch (e) {
      onErrorWhenRequestingNotifications();
    }
  }

  void onErrorWhenRequestingNotifications() {
    const notificationRequestError = 'Não foi possível lançar uma notificação';
    showSnackBar(message: notificationRequestError);
  }

  var notificationRequestError = '';

  var isRequestingNotification = false;

  bool isLoading = false;

  bool isCounterServiceInitialized = false;

  Timer? timer;

  Future<void> initCounterService() async {
    setState(() {
      isLoading = true;
    });
    try {
      await keepAppOnChannel.initService();
      timer = Timer.periodic(const Duration(seconds: 15), (_) {
        final value = counterService.get();
        counterService.save(value + 1).then((_) {
          showNotification('saved value is ${value + 1}');
          if (value + 1 == 50) {
            stopCounterService();
          }
        });
      });
      isCounterServiceInitialized = true;
    } catch (e) {
      showSnackBar(message: "Não foi possível iniciar o serviço de notificações de bateria");
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> stopCounterService() async {
    setState(() {
      isLoading = true;
    });
    try {
      timer?.cancel();
      await keepAppOnChannel.stopService();
      isCounterServiceInitialized = false;
    } catch (e) {
      showSnackBar(message: "Não foi possível parar o serviço de notificações de bateria");
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : FutureBuilder<dynamic>(
                future: initializers,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'You have pushed the button this many times:',
                      ),
                      Text(
                        '$_counter',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Status do serviço de bateria:"),
                          Switch(
                            value: isCounterServiceInitialized,
                            onChanged: (value) => value ? initCounterService() : stopCounterService(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
