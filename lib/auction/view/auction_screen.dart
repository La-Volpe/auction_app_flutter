import 'package:flutter/material.dart';

class AuctionScreen extends StatefulWidget {
  final String uuid;
  final String model;
  final num? initialPrice;

  const AuctionScreen({
    super.key,
    required this.uuid,
    required this.model,
    this.initialPrice,
  });

  @override
  State<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends State<AuctionScreen> {
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.initialPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _submitBid() {
    final price = num.tryParse(_priceController.text);
    if (price != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bid submitted: \$${price.toStringAsFixed(2)}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UUID: ${widget.uuid}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Model: ${widget.model}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitBid,
              child: const Text('Place Bid'),
            ),
          ],
        ),
      ),
    );
  }
}