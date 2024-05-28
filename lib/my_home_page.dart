import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  var CHANNEL = "com.videoplayer.native_in_flutter";

  void callNativeFunction(String videoUrl) async {
    final MethodChannel platformChannel = MethodChannel(CHANNEL);
    try {
      // final String result =
      //     await platformChannel.invokeMethod('goToNativeView');
      final String result = await platformChannel.invokeMethod('goToNativeView',
          {'videoUrl': videoUrl, 'videoText': 'Sourav Test Text'});
      print('Result from Native: $result');
    } on PlatformException catch (e) {
      print('Error: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Click forward to see the native video.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => callNativeFunction(
            "https://d33rgy2oqmippl.cloudfront.net/2/1712733524950-MZqKH4oxFyNsZAA2/1712733524950-MZqKH4oxFyNsZAA2-pl.m3u8"), // replace with your video URL
        tooltip: 'Forward',
        child: const Icon(Icons.arrow_forward_rounded),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
