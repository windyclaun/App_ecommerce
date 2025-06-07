// import 'package:flutter/material.dart';
// import 'package:projectakhir_mobile/models/cart_item_model.dart';

// class CheckoutBottomSheet extends StatelessWidget {
//   final List<CartItem> items;
//   final double totalPrice;
//   final double shippingCost;
//   final VoidCallback onCheckoutConfirmed;
//   final VoidCallback onMapPage;

//   const CheckoutBottomSheet({
//     Key? key,
//     required this.items,
//     required this.totalPrice,
//     required this.shippingCost,
//     required this.onCheckoutConfirmed,
//     required this.onMapPage,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 400,
//       padding: const EdgeInsets.all(8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Checkout Summary',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 16),
//           // Display the items in the cart
//           Expanded(
//             child: ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (context, index) {
//                 final item = items[index];
//                 return ListTile(
//                   title: Text(item.productName),
//                   subtitle: Text('Rp ${item.price} x ${item.quantity}'),
//                   trailing: Text(
//                     'Rp ${(item.price * item.quantity).toStringAsFixed(2)}',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 );
//               },
//             ),
//           ),
//           // Total Price & Shipping
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Total Price:'),
//                     Text('Rp ${totalPrice.toStringAsFixed(2)}'),
//                   ],
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Shipping Cost:'),
//                     Text('Rp ${shippingCost.toStringAsFixed(2)}'),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Button to go to map page to choose delivery location
//           ElevatedButton(
//             onPressed: onMapPage,
//             child: const Text('Select Delivery Location'),
//           ),
//           // Confirm Checkout Button
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             child: ElevatedButton(
//               onPressed: shippingCost == 0.0
//                   ? null
//                   : onCheckoutConfirmed,
//               child: const Text('Confirm Checkout'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
