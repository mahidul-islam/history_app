import 'timeline/timeline_widget.dart';
import 'main_menu/main_menu.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static final Animatable<Offset> _slideTween = Tween<Offset>(
    begin: const Offset(0.0, 0.0),
    end: const Offset(-1.0, 0.0),
  ).chain(CurveTween(
    curve: Curves.fastOutSlowIn,
  ));

  Animation<Offset>? _menuOffset;
  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _menuOffset = _controller.drive(_slideTween);
  }

  void _onHideMenu() {
    _controller.forward();
  }

  void _onShowMenu() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: const <Widget>[
          Positioned.fill(
            child: TimelineWidget(
                // showMenu: _onShowMenu,
                ),
          ),
          // Positioned.fill(
          //   child: SlideTransition(
          //     position: _menuOffset!,
          //     child: MainMenuWidget(selectItem: _onHideMenu),
          //   ),
          // ),
        ],
      ),
    );
  }
}
