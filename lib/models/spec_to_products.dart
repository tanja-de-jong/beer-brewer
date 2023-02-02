import 'package:beer_brewer/models/product.dart';
import 'package:beer_brewer/models/product_spec.dart';

import '../data/store.dart';

class SpecToProducts {
  ProductSpec spec;
  List<ProductInstance>? products;
  String? explanation;

  SpecToProducts(this.spec, this.products, this.explanation);

  static SpecToProducts create(Map data) {
    ProductSpec spec = ProductSpec.create(data["spec"]);
    List productsData = data["products"];
    var result = SpecToProducts(
        spec,
        productsData
            .map((data) => ProductInstance.create(spec.category, data))
            .toList(),
        data["explanation"]);
    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      "spec": spec.toMap(),
      "products": products?.map((ProductInstance p) => p.toMap()).toList(),
      "explanation": explanation
    };
  }
}

class ProductInstance {
  Product product;
  num amount;

  ProductInstance(this.product, this.amount);

  static ProductInstance create(ProductSpecCategory category, Map data) {
    Product product = Store.products[category.product]!
        .firstWhere((p) => p.id == data["productId"]);
    return ProductInstance(product, data["amount"]);
  }

  Map<String, dynamic> toMap() {
    return {"productId": product.id, "amount": amount};
  }
}