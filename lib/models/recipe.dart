import 'package:beer_brewer/models/product_spec.dart';

import 'cooking.dart';
import 'mashing.dart';

class Recipe {
  String? id;
  String name;
  String? style;
  String? source;
  double? amount;
  double? expStartSG;
  double? expFinalSG;
  double? efficiency;
  double? color;
  double? bitter;
  late Mashing mashing;
  double? rinsingWater;
  late Cooking cooking;
  YeastSpec? yeast;
  double? fermTempMin;
  double? fermTempMax;
  BottleSugarSpec? bottleSugar;
  String? remarks;

  Recipe(
      this.id,
      this.name,
      this.style,
      this.source,
      this.amount,
      this.expStartSG,
      this.expFinalSG,
      this.efficiency,
      this.color,
      this.bitter,
      mashing,
      this.rinsingWater,
      cooking,
      this.yeast,
      this.fermTempMin,
      this.fermTempMax,
      this.bottleSugar,
      this.remarks) {
    this.mashing = mashing ?? Mashing([], [], 0);
    this.cooking = cooking ?? Cooking([]);
  }

  static Recipe create(String id, Map data) {
    return Recipe(
      id,
      data["name"],
      data["style"],
      data["source"],
      data["amount"],
      data["expStartSG"],
      data["expFinalSG"],
      data["efficiency"],
      data["color"],
      data["bitter"],
      Mashing.create(data["mashing"]),
      data["rinsingWater"],
      Cooking.create(data["cooking"]),
      data["yeast"] == null ? null : YeastSpec.create(data["yeast"]),
      data["yeastTempMin"],
      data["yeastTempMax"],
      data["bottleSugar"] == null
          ? null
          : BottleSugarSpec.create(data["bottleSugar"]),
      data["remarks"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "style": style,
      "source": source,
      "amount": amount,
      "expStartSG": expStartSG,
      "expFinalSG": expFinalSG,
      "efficiency": efficiency,
      "color": color,
      "bitter": bitter,
      "mashing": mashing.toMap(),
      "rinsingWater": rinsingWater,
      "cooking": cooking.toMap(),
      "yeast": yeast?.toMap(),
      "yeastTempMin": fermTempMin,
      "yeastTempMax": fermTempMax,
      "bottleSugar": bottleSugar?.toMap(),
      "remarks": remarks
    };
  }
}