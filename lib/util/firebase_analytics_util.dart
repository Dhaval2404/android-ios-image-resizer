import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class FirebaseAnalyticsUtil {
  static logAppOpen() {
    analytics.logAppOpen();
  }

  static logEvent({@required String name, Map<String, dynamic> parameters}) {
    analytics.logEvent(name: name);
  }

  static FirebaseAnalyticsObserver getObserver() {
    return FirebaseAnalyticsObserver(analytics: analytics);
  }
}
