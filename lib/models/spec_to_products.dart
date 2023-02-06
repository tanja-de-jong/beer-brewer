import 'package:beer_brewer/models/product.dart';
import 'package:beer_brewer/models/product_spec.dart';

import '../data/store.dart';

class SpecToProducts {
  ProductSpec spec;
  List<ProductInstance>? products;

  SpecToProducts(this.spec, this.products);

  static SpecToProducts create(Map data) {
    ProductSpec spec = ProductSpec.create(data["spec"]);
    List productsData = data["products"];
    var result = SpecToProducts(
        spec,
        productsData
            .map((data) => ProductInstance.create(spec.category, data))
            .toList());
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      "spec": spec.toMap(),
      "products": products?.map((ProductInstance p) => p.toMap()).toList(),
    };
  }
}

class ProductInstance {
  Product product;
  num amount;
  String? explanation;

  ProductInstance(this.product, this.amount, this.explanation);

  static ProductInstance create(ProductSpecCategory category, Map data) {
    Product product = Store.products[category.product]!
        .firstWhere((p) => p.id == data["productId"]);
    return ProductInstance(product, data["amount"], data["explanation"]);
  }

  Map<String, dynamic> toMap() {
    return {"productId": product.id, "amount": amount, "explanation": explanation
    };
  }
}