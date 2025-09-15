// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:valley_farm_store/main.dart';

void main() {
  testWidgets('renders Valley Farm store front UI scaffolding', (WidgetTester tester) async {
    await tester.pumpWidget(const ValleyFarmApp());
    await tester.pump();

    expect(find.text('Valley Farm Secrets Store'), findsOneWidget);
    expect(find.text('Special Offers'), findsOneWidget);
    expect(find.text('Shop by Category'), findsOneWidget);
    expect(find.text('Cart (0)'), findsOneWidget);
  });

  testWidgets('adding a product updates the cart count', (WidgetTester tester) async {
    await tester.pumpWidget(const ValleyFarmApp());
    await tester.pump();

    expect(find.text('Cart (0)'), findsOneWidget);

    final Finder addToCartButton = find.widgetWithText(FilledButton, 'Add to Cart').first;
    await tester.tap(addToCartButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Cart (1)'), findsOneWidget);
  });
}
