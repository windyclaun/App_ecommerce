import 'package:flutter/material.dart';
import 'package:projectakhir_mobile/models/cart_item_model.dart';
import 'package:projectakhir_mobile/services/cart_service.dart';
import 'package:projectakhir_mobile/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final VoidCallback? onCartUpdated;
  final String? token;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onCartUpdated,
    this.token,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Initializing variables
  String selectedCurrency = 'IDR';
  final Map<String, double> currencyRates = {
    'IDR': 1.0, // IDR (Indonesian Rupiah) = 1.0
    'USD': 1 / 16275, // 1 USD = 16,275 IDR → 1 IDR = 1 / 16,275 USD
    'MYR': 1 / 3875, // 1 MYR = 3,875 IDR → 1 IDR = 1 / 3,875 MYR
    'AUD': 1 / 24000, // 1 AUD = 24,000 IDR → 1 IDR = 1 / 24,000 AUD (perkiraan)
    'GBP': 1 / 22000, // 1 GBP = 22,000 IDR → 1 IDR = 1 / 22,000 GBP (perkiraan)
    'THB': 1 / 2.1, // 1 THB (Baht Thailand) = 2,100 IDR → 1 IDR = 1 / 2.1 THB
    'EUR': 1 / 17860, // 1 EUR = 17,860 IDR → 1 IDR = 1 / 17,860 EUR
    'JPY': 1 / 118.74, // 1 JPY = 118.74 IDR → 1 IDR = 1 / 118.74 JPY
    'CNY': 1 / 2398.0, // 1 CNY = 2,398 IDR → 1 IDR = 1 / 2,398 CNY
  };

  @override
  void initState() {
    super.initState();
  }

  // Function to calculate price based on selected currency
  double getPriceInSelectedCurrency() {
    print(
        'Price in $selectedCurrency: ${double.parse(widget.product.price) * currencyRates[selectedCurrency]!}');
    return double.parse(widget.product.price) *
        currencyRates[selectedCurrency]!;
  }

  // Function to update selected currency
  void onCurrencyChanged(String? newCurrency) {
    setState(() {
      selectedCurrency = newCurrency!;
    });
  }

  void _addToCart(BuildContext context) async {
    try {
      final cartItem = CartItem(
        id: DateTime.now().millisecondsSinceEpoch,
        productId: widget.product.id,
        productName: widget.product.name,
        imageUrl: widget.product.imageUrl,
        price: double.parse(widget.product.price),
        quantity: 1,
      );

      await CartService.addToCart(cartItem, widget.token!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to cart'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCartUpdated?.call();
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Product Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.token == null ? null : () => _addToCart(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add to Cart',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: widget.product.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(child: FlutterLogo(size: 100)),
              ),
              const SizedBox(height: 24),
              Text(
                '$selectedCurrency ${getPriceInSelectedCurrency().toStringAsFixed(2)} ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              DropdownButton<String>(
                value: selectedCurrency,
                onChanged: onCurrencyChanged,
                items: const [
                  DropdownMenuItem(
                    value: 'IDR',
                    child: Text('IDR (Rupiah)'),
                  ),
                  DropdownMenuItem(
                    value: 'USD',
                    child: Text('USD (US Dollar)'),
                  ),
                  DropdownMenuItem(
                    value: 'MYR',
                    child: Text('MYR (Ringgit Malaysia)'),
                  ),
                  DropdownMenuItem(
                    value: 'AUD',
                    child: Text('AUD (Australian Dollar)'),
                  ),
                  DropdownMenuItem(
                    value: 'GBP',
                    child: Text('GBP (Pound Sterling)'),
                  ),
                  DropdownMenuItem(
                    value: 'THB',
                    child: Text('THB (Baht Thailand)'),
                  ),
                  DropdownMenuItem(
                    value: 'EUR',
                    child: Text('EUR (Euro)'),
                  ),
                  DropdownMenuItem(
                    value: 'JPY',
                    child: Text('JPY (Japanese Yen)'),
                  ),
                  DropdownMenuItem(
                    value: 'CNY',
                    child: Text('CNY (Chinese Yuan)'),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.inventory, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text("Stok: ${widget.product.stock}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.category, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Text("Kategori: ${widget.product.category}",
                      style: const TextStyle(fontSize: 16)),
                ],
              ),
              const Divider(height: 32),
              const Text("Deskripsi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                widget.product.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              // Currency Dropdown
            ],
          ),
        ),
      ),
    );
  }
}
