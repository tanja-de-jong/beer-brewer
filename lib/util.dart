import 'package:flutter/material.dart';

class Util {
  static String capitalize(String input) {
    String output = input[0].toUpperCase();
    return output + input.substring(1);
  }

  static String amountToString(double? amount) {
    return amount == null
        ? "-"
        : amount >= 1000
            ? "${(amount / 1000).toString().replaceAll(RegExp(r'\.'), ",")} kg"
            : "${amount} g";
  }

  static String? prettify(double? d) {
    return d?.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0*$'), '');
  }

  static void showDeleteDialog(
      BuildContext context, String subject, void Function()? onConfirm) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              title: SelectableText('${capitalize(subject)} verwijderen'),
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: SelectableText(
                          'Weet je zeker dat je dit ${subject.toLowerCase()} wil verwijderen?')),
                  const SizedBox(height: 20),
                  Center(
                      child: Wrap(spacing: 10, children: [
                    OutlinedButton(
                        onPressed: onConfirm, child: const Text('Ja')),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Nee')),
                  ]))
                ])
              ]);
        });
  }
}
