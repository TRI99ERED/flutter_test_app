import 'package:flutter/material.dart';
import 'package:test_app/src/widgets/common/app_number_input.dart';
import 'package:test_app/src/widgets/common/styles.dart';

class AppShoppingCartItem extends StatelessWidget {
  final Widget image;
  final String productName;
  final String details;
  final int quantity;
  final String price;
  final int? maxQuantity;
  final VoidCallback? onPressed;
  final ValueChanged<int>? onQuantityChanged;

  const AppShoppingCartItem({
    super.key,
    required this.image,
    required this.productName,
    required this.details,
    required this.quantity,
    required this.price,
    this.maxQuantity,
    this.onPressed,
    this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: LightColor.lightest.color,
          padding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: image,
              ),
            ),
            const SizedBox(width: spacing12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: spacing12),
                  Text(
                    productName,
                    style: TextStyle(
                      fontSize: h5Size,
                      fontWeight: h5Weight,
                      color: DarkColor.darkest.color,
                    ),
                  ),
                  Text(
                    details,
                    style: TextStyle(
                      fontSize: bSSize,
                      fontWeight: bSWeight,
                      color: DarkColor.dark.color,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      AppNumberInput(
                        value: quantity,
                        onChanged: (value) {
                          onQuantityChanged?.call(value);
                        },
                        min: 1,
                        max: maxQuantity,
                      ),
                      const Spacer(),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: h4Size,
                          fontWeight: h4Weight,
                          color: DarkColor.darkest.color,
                        ),
                      ),
                      const SizedBox(width: spacing12),
                    ],
                  ),
                  const SizedBox(height: spacing12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
