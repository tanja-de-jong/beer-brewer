import 'package:beer_brewer/models/product.dart';
import 'package:flutter/foundation.dart';

import '../util.dart';

class ProductSpec {
  String? name;
  num? amount;
  ProductSpecCategory category;

  ProductSpec(this.name, this.amount,
      {this.category = ProductSpecCategory.other});

  String getName() {
    return name ?? "";
  }

  String getAmount() {
    return amount == null ? "-" : ("${Util.prettify(amount)}g");
  }

  String getProductString() {
    return "${getAmount()} ${name ?? "-"}";
  }

  static ProductSpec create(Map data) {
    String cat = data["category"];
    switch (cat) {
      case "malt":
        return MaltSpec.create(data);
      case "hop":
        return HopSpec.create(data);
      case "cookingSugar":
        return CookingSugarSpec.create(data);
      case "bottleSugar":
        return BottleSugarSpec.create(data);
      case "yeast":
        return YeastSpec.create(data);
      default:
        return ProductSpec(data["name"], data["amount"],
            category: ProductSpecCategory.other);
    }
  }

  Map<String, dynamic> toMap() {
    return {"name": name, "amount": amount, "category": describeEnum(category)};
  }
}

class MaltSpec extends ProductSpec {
  num? ebcMin;
  num? ebcMax;

  MaltSpec(name, this.ebcMin, this.ebcMax, amount) : super(name, amount) {
    category = ProductSpecCategory.malt;
  }

  static MaltSpec create(Map data) {
    return MaltSpec(
        data["name"], data["ebcMin"], data["ebcMax"], data["amount"]);
  }

  String ebcToString({num? min, num? max}) {
    num? minEbc = min ?? ebcMin;
    num? maxEbc = max ?? ebcMax;
    if (minEbc == null && ebcMax == null) return "-";
    if (minEbc == maxEbc || minEbc == null) return "$maxEbc EBC";
    if (maxEbc == null) return "$minEbc EBC";
    return "$minEbc - $maxEbc EBC";
  }

  static String getEbcToString(num? min, num? max) {
    if (min == null && max == null) return "-";
    if (min == max || min == null) return "$max EBC";
    if (max == null) return "$min EBC";
    return "$min - $max EBC";
  }

  @override
  String getProductString() {
    return "${getAmount()} $name (${ebcToString()})";
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "ebcMin": ebcMin,
      "ebcMax": ebcMax,
      "category": "malt"
    };
  }
}

class HopSpec extends ProductSpec {
  num? alphaAcid;

  HopSpec(name, this.alphaAcid, amount) : super(name, amount) {
    category = ProductSpecCategory.hop;
  }

  static HopSpec create(Map data) {
    return HopSpec(data["name"], data["alphaAcid"], data["amount"]);
  }

  @override
  String getProductString() {
    return "${getAmount()} $name ($alphaAcid%)";
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "alphaAcid": alphaAcid, "category": "hop"};
  }
}

class SugarSpec extends ProductSpec {
  SugarSpec(super.name, super.amount);
}

class CookingSugarSpec extends SugarSpec {
  CookingSugarSpec(name, amount) : super(name, amount) {
    category = ProductSpecCategory.cookingSugar;
  }

  static CookingSugarSpec create(Map data) {
    return CookingSugarSpec(data["name"], data["amount"]);
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "category": "cookingSugar"};
  }
}

class BottleSugarSpec extends SugarSpec {
  BottleSugarSpec(name, amount) : super(name, amount) {
    category = ProductSpecCategory.bottleSugar;
  }

  @override
  String getProductString() {
    return "${amount == null ? "- " : getAmount()}/L ${name == null ? "-" : name!}";
  }

  static BottleSugarSpec create(Map data) {
    return BottleSugarSpec(data["name"], data["amount"]);
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "category": "bottleSugar"};
  }
}

class YeastSpec extends ProductSpec {
  YeastSpec(name, amount) : super(name, amount) {
    category = ProductSpecCategory.yeast;
  }

  static YeastSpec create(Map data) {
    return YeastSpec(data["name"], data["amount"]);
  }

  @override
  Map<String, dynamic> toMap() {
    return {...super.toMap(), "category": "yeast"};
  }
}

enum ProductSpecCategory { malt, hop, cookingSugar, bottleSugar, yeast, other }

extension ProductSpecName on ProductSpecCategory {
  String get name {
    switch (this) {
      case ProductSpecCategory.malt:
        return "Mout";
      case ProductSpecCategory.hop:
        return "Hop";
      case ProductSpecCategory.cookingSugar:
        return "Kooksuiker";
      case ProductSpecCategory.bottleSugar:
        return "Bottelsuiker";
      case ProductSpecCategory.yeast:
        return "Gist";
      default:
        return "Overige";
    }
  }
}

extension ProductSpecCategoryToProduct on ProductSpecCategory {
  Type get product {
    switch (this) {
      case ProductSpecCategory.malt:
        return Malt;
      case ProductSpecCategory.hop:
        return Hop;
      case ProductSpecCategory.cookingSugar:
        return Sugar;
      case ProductSpecCategory.bottleSugar:
        return Sugar;
      case ProductSpecCategory.yeast:
        return Yeast;
      default:
        return Product;
    }
  }
}
