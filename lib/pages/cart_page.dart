import 'package:flutter/material.dart';
import 'package:projectakhir_mobile/models/cart_item_model.dart';
import 'package:projectakhir_mobile/models/product_model.dart';
import 'package:projectakhir_mobile/services/cart_service.dart';
import 'package:projectakhir_mobile/services/product_service.dart';

class CartPage extends StatefulWidget {
  final String? token;
  final VoidCallback? onCheckoutDone;

  const CartPage({super.key, this.token, this.onCheckoutDone});

  @override
  State<CartPage> createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  bool isLoading = true;
  Set<int> selectedOrderIds = {};
  List<CartItem> items = [];

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.token != oldWidget.token) {
      loadCart();
    }
  }

  Future<void> loadCart() async {
    setState(() => isLoading = true);
    try {
      items = await CartService.getCartItems(widget.token!);
      selectedOrderIds.clear();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please login to view products"),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2)),
        );
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> _updateQuantity(CartItem item, int delta) async {
    final newQuantity = item.quantity + delta;

    try {
      if (newQuantity <= 0) {
        await CartService.deleteOrder(item.id, widget.token!);
        setState(() {
          items.removeWhere((e) => e.id == item.id);
          selectedOrderIds.remove(item.id);
        });
      } else {
        await CartService.updateQuantity(
            item.id, newQuantity, widget.token!, item.price);
        setState(() {
          item.quantity = newQuantity;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  double get selectedTotal {
    return items
        .where((item) => selectedOrderIds.contains(item.id))
        .fold(0.0, (sum, item) => sum + item.total);
  }

  Future<void> _checkout() async {
    try {
      final selectedIds = selectedOrderIds.toList();

      if (selectedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select items to checkout'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2)),
        );
        return;
      }

      // Cek apakah stok cukup untuk setiap item yang dipilih
      for (int id in selectedIds) {
        final item = items.firstWhere((element) => element.id == id);
        final product = await ProductService.getProductById(item.productId);

        // Jika jumlah item yang ingin di-checkout lebih besar dari stok
        if (item.quantity > product.stock) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Insufficient stock for ${item.productName}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2)),
          );
          return; // Hentikan checkout jika ada produk dengan stok kurang
        }
      }

      // Jika semua produk memiliki stok cukup, lanjutkan checkout
      await CartService.checkoutOrders(selectedIds, widget.token!);
      await loadCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Checkout successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2)),
        );
        widget.onCheckoutDone?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2)),
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
        title: const Text('Shopping Cart'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/emptycart.png',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                onRefresh: loadCart,
                child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = selectedOrderIds.contains(item.id);
                
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedOrderIds.add(item.id);
                                    } else {
                                      selectedOrderIds.remove(item.id);
                                    }
                                  });
                                },
                              ),
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.network(
                                  item.imageUrl.isNotEmpty
                                      ? item.imageUrl
                                      : 'https://th.bing.com/th/id/OIP.FPIFJ6xedtnTAxk0T7AKhwHaF9?rs=1&pid=ImgDetMain',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rp ${item.price}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Use FutureBuilder to load stock info
                                    FutureBuilder<Product>(
                                      future: ProductService.getProductById(
                                          item.productId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text("Error: ${snapshot.error}");
                                        } else if (snapshot.hasData) {
                                          final product = snapshot.data!;
                                          return Text(
                                            'Stock: ${product.stock}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          );
                                        } else {
                                          return const Text('No product data');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () async {
                                        await _updateQuantity(item, -1);
                                      }),
                                  Text('${item.quantity}',
                                      style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () async {
                                        await _updateQuantity(item, 1);
                                      }),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await CartService.deleteOrder(
                                      item.id, widget.token!);
                                  await loadCart();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ),
      bottomNavigationBar: items.isEmpty || selectedOrderIds.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Rp ${selectedTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() => isLoading = true);
                        await _checkout();
                        setState(() => isLoading = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Checkout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
