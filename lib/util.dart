import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Util {
  static String capitalize(String input) {
    String output = input[0].toUpperCase();
    return output + input.substring(1);
  }

  static String amountToString(num? amount) {
    return amount == null
        ? "-"
        : amount >= 1000
            ? "${(amount / 1000).toString().replaceAll(RegExp(r'\.'), ",")} kg"
            : "$amount g";
  }

  static String? prettify(num? d) {
    return d?.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0*$'), '');
  }

  static bool search(String parent, String child) {
    return removeDiacritics(parent.toLowerCase()).contains(removeDiacritics(child.toLowerCase()));
  }

  static void showDeleteDialog(
      BuildContext context, String subject, void Function()? onConfirm, { deze: false }) {
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
                          'Weet je zeker dat je ${deze ? "deze" : "dit"} ${subject.toLowerCase()} wil verwijderen?')),
                  const SizedBox(height: 20),
                  Center(
                      child: Wrap(spacing: 10, children: [
                    OutlinedButton(
                        onPressed: () {
                          if (onConfirm != null) onConfirm();
                        }, child: const Text('Ja')),
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

extension DateFormatTryParse on DateFormat {
  DateTime? tryParse(String inputString, [bool utc = false]) {
    try {
      return parseStrict(inputString, utc);
    } on FormatException {
      return null;
    }
  }
}
