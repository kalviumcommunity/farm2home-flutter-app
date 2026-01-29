Concept 1

Flutter Widget Architecture & Performance

Flutter uses a widget-based architecture and Dart’s reactive rendering model to deliver smooth UI performance across Android and iOS. Instead of redrawing the entire screen, Flutter rebuilds only the widgets that change, ensuring fast and consistent performance on both platforms.

StatelessWidget vs StatefulWidget (App Example)

StatelessWidget
Used for static UI that doesn’t change, such as headers or labels.

Text("Farm2Home")


These widgets are built once and reused, making them lightweight and efficient.

StatefulWidget
Used for dynamic UI, such as cart count or task list updates.

setState(() {
  itemCount++;
});


Calling setState() rebuilds only the affected widget subtree, not the whole screen.

Case Study: “The Laggy To-Do App”

The app lagged because setState() was called at a high-level widget, causing unnecessary rebuilds of deeply nested widgets, especially noticeable on iOS.

Solution

By managing state locally and updating only specific widgets (like the task list), Flutter avoids full UI redraws and maintains a smooth frame rate.

Why Flutter Stays Smooth

Reactive rendering updates only what changes

Dart async model prevents UI blocking

Single UI codebase ensures consistent performance on Android and iOS

Each UI interaction feels instant because Flutter rebuilds only what’s necessary, not everything.





Concept 2 
Learnings:

## Firebase Setup
- Created Firebase project
- Connected Flutter using FlutterFire CLI
- Added firebase_core, firebase_auth, cloud_firestore

## Features Implemented
- Email/Password Authentication
- Real-time Firestore database
- Live task updates across devices

## Real-Time Sync
Firestore streams update UI instantly without manual refresh.

## Reflection
Firebase simplified backend logic by providing authentication,
database, and storage without custom servers.

