import 'package:beer_brewer/models/product.dart';
import 'package:flutter/cupertino.dart';

import '../util.dart';
import 'SpecToProducts.dart';
import 'cooking.dart';
import 'mashing.dart';

class Batch {
  String? id;
  String name;
  String recipeId;
  double amount;
  String? style;
  double? expStartSG;
  double? expFinalSG;
  double? color;
  double? bitter;
  Mashing mashing;
  double? rinsingWater;
  Cooking cooking;
  SpecToProducts? yeast;
  double? fermTempMin;
  double? fermTempMax;
  SpecToProducts? bottleSugar;
  String? remarks;
  DateTime? brewDate;
  DateTime? lagerDate;
  DateTime? bottleDate;
  Map<DateTime, double> sgMeasurements;

  Batch(
      this.id,
      this.name,
      this.recipeId,
      this.amount,
      this.style,
      this.expStartSG,
      this.expFinalSG,
      this.color,
      this.bitter,
      this.mashing,
      this.rinsingWater,
      this.cooking,
      this.yeast,
      this.fermTempMin,
      this.fermTempMax,
      this.bottleSugar,
      this.remarks,
      this.brewDate,
      this.lagerDate,
      this.bottleDate,
      this.sgMeasurements);

  static Batch create(String id, Map data) {
    Map<DateTime, double> sgMeasurements = {};
    if (data.containsKey("sgMeasurements")) {
      List sgData = data["sgMeasurements"];
      for (var sg in sgData) {
        sgMeasurements.putIfAbsent(sg["date"].toDate(), () => sg["SG"]);
      }
    }

    return Batch(
        id,
        data["name"],
        data["recipeId"],
        data["amount"],
        data["style"],
        data["expStartSG"],
        data["expFinalSG"],
        data["color"],
        data["bitter"],
        Mashing.create(data["mashing"]),
        data["rinsingWater"],
        Cooking.create(data["cooking"]),
        data["yeast"] != null ? SpecToProducts.create(data["yeast"]) : null,
        data["yeastTempMin"],
        data["yeastTempMax"],
        data["bottleSugar"] != null ? SpecToProducts.create(data["bottleSugar"]) : null,
        data["remarks"],
        data["brewDate"]?.toDate(),
        data["lagerDate"]?.toDate(),
        data["bottleDate"]?.toDate(),
        sgMeasurements);
  }

  double? getStartSG() {
    if (sgMeasurements.isEmpty) return null;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    return sgMeasurements[dates.first]!;
  }

  double? getEndSG() {
    if (sgMeasurements.length < 2) return null;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    return sgMeasurements[dates.last]!;
  }

  bool isReadyToBottle() {
    if (brewDate == null) return false;
    DateTime today = DateTime.now();
    return isSGSteady() || today.difference(brewDate!).inDays >= 21;
  }

  bool isSGSteady() {
    if (sgMeasurements.length < 2) return false;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    DateTime latestDate = dates.last;
    double lastValue = sgMeasurements[latestDate]!;
    DateTime prevDate = dates
        .where((date) =>
    !date.isAfter(dates.last.subtract(const Duration(days: 2))))
        .last;
    double diff = (sgMeasurements[prevDate]! - lastValue).abs();
    return diff < 1;
  }

  // For Brewing in a Bag
  String getBiabWater() {
    return Util.prettify(amount * 1.5) ?? "-";
  }

  Widget getMashingSchedule() {
    return mashing.steps.isEmpty
        ? const Text("Geen moutschema beschikbaar.",
        style: TextStyle(fontStyle: FontStyle.italic))
        : Table(
        border: TableBorder.all(),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          const TableRow(children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Temperatuur",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: Text("Tijd",
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ]),
          ...mashing.steps.map(
                (s) => TableRow(children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("${s.temp}ºC")),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text("${s.time} min"))
            ]),
          )
        ]);
  }

  Widget getCookingSchedule() {
    return cooking.steps.isEmpty
        ? const Text("Geen kookschema beschikbaar.",
        style: TextStyle(fontStyle: FontStyle.italic))
        : Table(
        border: TableBorder.all(),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          const TableRow(children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Tijd",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            Padding(
                padding: EdgeInsets.all(10),
                child: Text("Soort",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.all(10),
                child: Text("Gewicht",
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(
                padding: EdgeInsets.all(10),
                child: Text("α",
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ]),
          ...cooking.steps.expand((cs) => cs.products.expand(
                (stp) => stp.products!.map((pi) {
              Product p = pi.product;
              return TableRow(children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("${cs.time} min")),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(p.name)),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(Util.amountToString(pi.amount))),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(pi.product is Hop && (pi.product as Hop).alphaAcid != null
                        ? "${(pi.product as Hop).alphaAcid}%"
                        : "-"))
              ]);
            }),
          ))
        ]);
  }

  String getFermentationTemperature() {
    return "${fermTempMin ?? "?"} - ${fermTempMax ?? "?"}°C";
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "recipeId": recipeId,
      "amount": amount,
      "style": style,
      "expStartSG": expStartSG,
      "expFinalSG": expFinalSG,
      "color": color,
      "bitter": bitter,
      "mashing": mashing.toMap(),
      "rinsingWater": rinsingWater,
      "cooking": cooking.toMap(),
      "yeast": yeast?.toMap(),
      "yeastTempMin": fermTempMin,
      "yeastTempMax": fermTempMax,
      "bottleSugar": bottleSugar?.toMap(),
      "remarks": remarks,
      "brewDate": brewDate,
      "lagerDate": lagerDate,
      "bottleDate": bottleDate,
      "sgMeasurements": sgMeasurements.keys
          .map((e) => {"date": e, "SG": sgMeasurements[e]})
          .toList()
    };
  }
}