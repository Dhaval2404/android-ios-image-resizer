import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en')],
      path: 'assets/translations', // <-- change patch to your
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Resizer',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}
