import 'package:flutter/material.dart';
import '../core/store_style.dart';
import '../models/product.dart';
import 'product_image.dart';

class ProductFacts {
  final int stars;
  final int reviews;
  final String place;
  final int units;
  final bool showStock;
  final String color;
  final String shipping;

  const ProductFacts({
    required this.stars,
    required this.reviews,
    required this.place,
    required this.units,
    required this.showStock,
    required this.color,
    required this.shipping,
  });

  String reviewLabel(bool english) {
    final suffix = english ? 'Reviews' : 'reseñas';
    final count = reviews >= 1000 ? '1000+' : '$reviews';
    return '$count $suffix';
  }

  String sideLabel(bool english) {
    if (showStock) {
      return english ? '$units in Stock' : '$units en stock';
    }
    return english ? '$units Sold' : '$units vendidos';
  }

  static const places = [
    'Colorado',
    'Texas',
    'Utah',
    'New York',
    'New Orleans',
    'Miami',
  ];

  static const colors = ['Black', 'Blue', 'Red', 'Orange'];
  static const shippings = ['Regular', 'Economic', 'Next Day', 'Instant'];

  factory ProductFacts.of(Product product) {
    final n = product.id.abs();
    final rawReviews = 6 + (n * 37 % 220);
    return ProductFacts(
      stars: n % 5 == 0 ? 4 : 5,
      reviews: rawReviews > 170 ? 1000 + (n % 500) : rawReviews,
      place: places[n % places.length],
      units: 40 + (n * 11 % 130),
      showStock: n.isEven,
      color: colors[n % colors.length],
      shipping: shippings[n % shippings.length],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final bool favorite;
  final bool english;
  final String addLabel;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.favorite,
    required this.english,
    required this.addLabel,
    required this.onTap,
    required this.onFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final facts = ProductFacts.of(product);
    final price = product.price == product.price.roundToDouble()
        ? '\$${product.price.toStringAsFixed(0)}'
        : '\$${product.price.toStringAsFixed(2)}';

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: StoreColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColoredBox(
                    color: StoreColors.well,
                    child: ProductImage(
                      imageUrl: product.imageUrl,
                      label: product.name,
                      iconSize: 42,
                      neutral: true,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: StoreColors.ink,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: onFavorite,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: favorite ? StoreColors.heart : StoreColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (var i = 0; i < 5; i++)
                        Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: i < facts.stars ? StoreColors.star : const Color(0xFFE4E7EC),
                        ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          facts.reviewLabel(english),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: StoreColors.muted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          facts.place,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: StoreColors.muted),
                        ),
                      ),
                      Text(
                        facts.sideLabel(english),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: facts.showStock ? StoreColors.teal : StoreColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: StoreColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      onPressed: onAddToCart,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: StoreColors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_outlined, size: 15),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              addLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
