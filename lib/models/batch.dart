import 'package:beer_brewer/models/product.dart';
import 'package:flutter/cupertino.dart';

import '../util.dart';
import 'spec_to_products.dart';
import 'cooking.dart';
import 'mashing.dart';

class Batch {
  String? id;
  String name;
  String recipeId;
  num amount;
  String? style;
  num? expStartSG;
  num? expFinalSG;
  num? color;
  num? bitter;
  Mashing mashing;
  num? rinsingWater;
  Cooking cooking;
  SpecToProducts? yeast;
  num? fermTempMin;
  num? fermTempMax;
  SpecToProducts? bottleSugar;
  String? remarks;
  DateTime? brewDate;
  DateTime? lagerDate;
  DateTime? bottleDate;
  Map<DateTime, num> sgMeasurements;
  Map<NotificationType, num> notifications;

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
      this.sgMeasurements,
      this.notifications);

  static Batch create(String id, Map data) {
    Map<DateTime, num> sgMeasurements = {};
    if (data.containsKey("sgMeasurements")) {
      List sgData = data["sgMeasurements"];
      for (var sg in sgData) {
        sgMeasurements.putIfAbsent(sg["date"].toDate(), () => sg["SG"]);
      }
    }

    Map<NotificationType, num> notifications = {};
    if (data.containsKey("notifications")) {
      List notificationData = data["notifications"];
      for (var n in notificationData) {
        NotificationType type = NotificationType.values.firstWhere((e) => e.name == n["type"]);
        notifications[type] = n["id"];
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
        sgMeasurements,
        notifications
    );
  }

  num? getStartSG() {
    if (sgMeasurements.isEmpty) return null;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    return sgMeasurements[dates.first]!;
  }

  num? getEndSG() {
    if (sgMeasurements.length < 2) return null;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    return sgMeasurements[dates.last]!;
  }

  bool isReadyToBottle() {
    if (lagerDate == null) return false;
    DateTime today = DateTime.now();
    return today.difference(lagerDate!).inDays >= 7;
  }

  bool isReadyToLager() {
    if (brewDate == null) return false;
    DateTime today = DateTime.now();
    return isSGSteady() || today.difference(brewDate!).inDays >= 21;
  }

  bool isReadyToDrinkEarly() {
    if (bottleDate == null) return false;
    DateTime today = DateTime.now();
    int diff = today.difference(bottleDate!).inDays;
    return diff >= 14 && diff < 21;
  }

  bool isReadyToDrink() {
    if (bottleDate == null) return false;
    DateTime today = DateTime.now();
    return today.difference(bottleDate!).inDays >= 21;
  }

  bool isSGSteady() {
    if (sgMeasurements.length < 2) return false;
    List<DateTime> dates = sgMeasurements.keys.toList();
    dates.sort();
    DateTime latestDate = dates.last;
    num lastValue = sgMeasurements[latestDate]!;
    List<DateTime> prevDates = dates
        .where((date) =>
    !date.isAfter(dates.last.subtract(const Duration(days: 2)))).toList();
    if (prevDates.isEmpty) return false;
    DateTime prevDate = prevDates.last;
    num diff = (sgMeasurements[prevDate]! - lastValue).abs();
    return diff < 0.005;
  }

  BatchStatus getStatus() {
    if (brewDate == null) {
      if (mashing.steps.isNotEmpty && mashing.malts.isNotEmpty && cooking.steps.isNotEmpty) {
        return BatchStatus.readyToBrew;
      } else {
        return BatchStatus.completeBrewPlan;
      }
    } else if (lagerDate == null) {
      if (isReadyToLager()) {
        return BatchStatus.readyToLager;
      } else {
        return BatchStatus.waitingForFermentation;
      }
    } else if (bottleDate == null) {
      if (isReadyToBottle()) {
        return BatchStatus.readyToBottle;
      } else {
        return BatchStatus.waitingForLagering;
      }
    } else if (isReadyToDrinkEarly()) {
      return BatchStatus.readyToTaste;
    } else if (isReadyToDrink()) {
      return BatchStatus.ready;
    } else {
      return BatchStatus.waitingForAfterFermentation;
    }
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

  List<SpecToProducts> getAllSpecToProducts() {
    List<SpecToProducts> allStps = [...mashing.malts, ...(cooking.steps.expand((e) => e.products))];
    if (bottleSugar != null) allStps.add(bottleSugar!);
    if (yeast != null) allStps.add(yeast!);
    return allStps;
  }

  Map<Product, num> getShoppingList() {
    Map<Product, num> shoppingList = {};

    if (brewDate == null) {
      for (SpecToProducts stp in getAllSpecToProducts()) {
        if (stp.products != null) {
          for (ProductInstance pi in stp.products!) {
            Product p = pi.product;
            num shortage = pi.amount -
                (p.amountInStock == null || p.amountInStock! < 0 ? 0 : p
                    .amountInStock!);
            if (shortage > 0) {
              shoppingList[p] = (shoppingList[p] ?? 0) + shortage;
            }
          }
        }
      }
    }
    return shoppingList;
  }

  void addNotification(int id, NotificationType type) {
    notifications[type] = id; // TODO
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
          .toList(),
      "notifications": notifications.keys.map((e) => {"type": e.name, "id": notifications[e]}).toList()
    };
  }
}

enum BatchStatus { readyToBrew, completeBrewPlan, readyToLager, waitingForFermentation,
  readyToBottle, waitingForLagering, readyToTaste, ready, waitingForAfterFermentation }

extension BatchStatusText on BatchStatus {
  String get text {
    switch (this) {
      case BatchStatus.readyToBrew: return "Klaar om te brouwen";
      case BatchStatus.completeBrewPlan: return "Vul het brouwplan aan";
      case BatchStatus.readyToLager: return "Klaar om te lageren";
      case BatchStatus.waitingForFermentation: return "Wachten op vergisting";
      case BatchStatus.readyToBottle: return "Klaar om te bottelen";
      case BatchStatus.waitingForLagering: return "Wachten op lageren";
      case BatchStatus.readyToTaste: return "Klaar om te proeven.";
      case BatchStatus.ready: return "Klaar!";
      case BatchStatus.waitingForAfterFermentation: return "Wachten op nagisting";
      default: return "-";
    }
  }
}

enum BatchPhase {
  brewing,
  lagering,
  bottling
}

enum NotificationType {
  fermentationPossiblyDone,
  fermentationDone,
  lageringDone,
  bottlingDone,
  done
}