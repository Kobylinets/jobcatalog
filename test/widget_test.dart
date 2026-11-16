import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_catalog/lab5/widgets/design_system.dart';

void main() {
  testWidgets('Повідомлення валідації з’являється під полем', (tester) async {
    final form = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: makeJobTheme(Brightness.light),
        home: Scaffold(
          body: Form(
            key: form,
            child: ListView(
              children: [
                TextFormField(
                  validator: emailValidator,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                ElevatedButton(
                  onPressed: () => form.currentState!.validate(),
                  child: const Text('Перевірити'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Перевірити'));
    await tester.pump();
    expect(find.text('Введіть електронну пошту.'), findsOneWidget);
  });
}
