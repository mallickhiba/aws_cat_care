// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aws_app/app.dart';
import 'package:aws_app/app_view.dart';
import 'package:mockito/mockito.dart';
import 'package:user_repository/user_repository.dart';
import 'package:aws_app/screens/home/incidents/add_incident_page.dart';

// class MockUserRepository extends Mock implements UserRepository {}

void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });
  // Create a mock UserRepository instance
  // final mockUserRepository = MockUserRepository();

  // testWidgets('MyApp initializes correctly with UserRepository',
  //     (WidgetTester tester) async {
  //   await tester.pumpWidget(MyApp(mockUserRepository));
  // });
  testWidgets('AddIncidentPage shows necessary UI elements',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AddIncidentPage(catId: '123')),
    );

    // Verify description text field exists
    expect(find.byType(TextField), findsOneWidget);

    // Verify switches exist
    expect(find.byType(SwitchListTile), findsNWidgets(2));

    // Verify dropdowns exist
    expect(find.byType(DropdownButtonFormField), findsNWidgets(1));

    // Verify submit button exists
    expect(find.text("Submit"), findsOneWidget);
  });
}
