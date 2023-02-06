import 'package:flutter/foundation.dart';

class Product {
  String id;
  String name;
  String brand;
  Map<String, Map<String, dynamic>>?
  stores; // Brouwstore => {url: www.brouwstore.com, variants: {1kg: www.bla.com}}
  num? amountInStock;

  Product(this.id, this.name, this.brand, this.stores, this.amountInStock);

  String getStoreUrl(String storeName) {
    return stores?[storeName]?["url"] ?? "-";
  }

  String storesToString() {
    return stores?.keys.join(", ") ?? "-";
  }

  String getProductString() {
    return "${amountToString()} $name";
  }

  String amountToString() {
    return amountInStock == null
        ? "-"
        : amountInStock! >= 1000
        ? "${(amountInStock! / 1000).toString().replaceAll(RegExp(r'\.'), ",")} kg"
        : "$amountInStock g";
  }

  static Product create(String id, Map data) {
    String cat = data["category"];
    switch (cat) {
      case "malt":
        return Malt.create(id, data);
      case "hop":
        return Hop.create(id, data);
      case "sugar":
        return Sugar.create(id, data);
      case "yeast":
        return Yeast.create(id, data);
      default:
        return Product(id, data["name"], data["brand"] ?? "-", data["stores"],
            data["amount"]);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "category": describeEnum(ProductCategory.other),
      "name": name,
      "brand": brand,
      "stores": stores,
      "amount": amountInStock,
    };
  }
}

class Malt extends Product {
  String? type;
  num? ebcMin;
  num? ebcMax;

  Malt(super.id, super.name, this.type, super.brand, super.stores, super.amount,
      this.ebcMin, this.ebcMax);

  @override
  static Malt create(String id, Map data) {
    return Malt(id, data["name"], data["type"], data["brand"] ?? "-",
        data["stores"], data["amount"], data["ebcMin"], data["ebcMax"]);
  }

  String ebcToString() {
    if (ebcMin == null && ebcMax == null) return "-";
    if (ebcMin == ebcMax || ebcMin == null) return "$ebcMin EBC";
    if (ebcMax == null) return "$ebcMax EBC";
    return "$ebcMin - $ebcMax EBC";
  }

  String typeToString() {
    return type ?? "-";
  }

  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "category": describeEnum(ProductCategory.malt),
      "type": type,
      "ebcMin": ebcMin,
      "ebcMax": ebcMax
    };
  }
}

class Hop extends Product {
  String? type;
  num? alphaAcid;
  HopShape shape;

  Hop(super.id, super.name, this.type, super.brand, super.stores, super.amount,
      this.alphaAcid, this.shape);

  static Hop create(String id, Map data) {
    return Hop(
        id,
        data["name"],
        data["type"],
        data["brand"] ?? "-",
        data["stores"],
        data["amount"],
        data["alphaAcid"],
        data["shape"] == "korrels" ? HopShape.korrels : HopShape.bellen);
  }

  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "category": describeEnum(ProductCategory.hop),
      "type": type,
      "alphaAcid": alphaAcid,
      "shape": describeEnum(shape)
    };
  }
}

class Sugar extends Product {
  Sugar(super.id, super.name, super.brand, super.stores, super.amount);

  static Sugar create(String id, Map data) {
    return Sugar(
        id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"]);
  }

  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "category": describeEnum(ProductCategory.sugar),
    };
  }
}

class Yeast extends Product {
  Yeast(super.id, super.name, super.brand, super.stores, super.amount);

  static Yeast create(String id, Map data) {
    return Yeast(
        id, data["name"], data["brand"] ?? "-", data["stores"], data["amount"]);
  }

  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      "category": describeEnum(ProductCategory.yeast),
    };
  }
}

enum HopShape { korrels, bellen }

enum ProductCategory { malt, hop, sugar, yeast, other }

extension ProductName on ProductCategory {
  String get name {
    switch (this) {
      case ProductCategory.malt:
        return "Mout";
      case ProductCategory.hop:
        return "Hop";
      case ProductCategory.yeast:
        return "Gist";
      case ProductCategory.sugar:
        return "Suiker";
      default:
        return "Overige";
    }
  }
}

extension ProductCategoryToProduct on ProductCategory {
  Type get productType {
    switch (this) {
      case ProductCategory.malt:
        return Malt;
      case ProductCategory.hop:
        return Hop;
      case ProductCategory.sugar:
        return Sugar;
      case ProductCategory.yeast:
        return Yeast;
      default:
        return Product;
    }
  }
}
