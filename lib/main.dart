import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();

  final registry = JsonWidgetRegistry.instance;
  registry.navigatorKey = navigatorKey;

  registry.registerFunctions({
    'getImageAsset': ({args, required registry}) =>
        'assets/images/image${args![0]}.jpg',
    'getImageId': ({args, required registry}) => 'image${args![0]}',
    'noop': ({args, required registry}) => () {},
    'validateForm': ({args, required registry}) => () {
          final BuildContext context = registry.getValue(args![0]);

          final valid = Form.of(context).validate();
          registry.setValue('form_validation', valid);
        },
    'updateCustomTextStyle': ({args, required registry}) => () {
          registry.setValue(
            'customTextStyle',
            const TextStyle(
              color: Colors.black,
            ),
          );
        },
    'getCustomTweenBuilder': ({args, required registry}) =>
        (BuildContext context, dynamic size, Widget? child) {
          return IconButton(
            icon: child!,
            iconSize: size,
            onPressed: () {
              final current = registry.getValue('customSize');
              final size = current == 50.0 ? 100.0 : 50.0;
              registry.setValue('customSize', size);
            },
          );
        },
    'getCustomTween': ({args, required registry}) {
      return Tween<double>(begin: 0, end: args![0]);
    },
    'setWidgetByKey': ({args, required registry}) => () {
          final replace = registry.getValue(args![1]);
          registry.setValue(args[0], replace);
        },
    'simplePrintMessage': ({args, required registry}) => () {
          var message = 'This is a simple print message';
          if (args?.isEmpty == false) {
            for (var arg in args!) {
              message += ' $arg';
            }
          }
          // ignore: avoid_print
          print(message);
        },
    'negateBool': ({args, required registry}) => () {
          final bool value = registry.getValue(args![0]);
          registry.setValue(args[0], !value);
        },
    'buildPopupMenu': ({args, required registry}) {
      const choices = ['First', 'Second', 'Third'];
      return (BuildContext context) {
        return choices
            .map(
              (choice) => PopupMenuItem(
                value: choice,
                child: Text(choice),
              ),
            )
            .toList();
      };
    },
    'setBooleanValue': ({args, required registry}) {
      return (bool? onChangedValue) {
        final variableName = args![0];
        registry.setValue(variableName, onChangedValue);
      };
    },
  });

  registry.setValue('customRect', Rect.largest);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Simple Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: DynamicText());
  }
}

class DynamicText extends StatefulWidget {
  final url = 'https://api.npoint.io/2d23c7fa93461cea9ca8';

  @override
  _DynamicTextState createState() => _DynamicTextState();
}

class _DynamicTextState extends State<DynamicText> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (snapshot.hasData) {
          var widgetJson = json.decode(snapshot.data?.body as String);
          var widget = JsonWidgetData.fromDynamic(
            widgetJson,
          );
          return widget.build(context: context);
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
      future: _getWidget(),
    );
  }

  Future<http.Response> _getWidget() async {
    return http.get(Uri.parse(widget.url));
  }
}
