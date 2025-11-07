import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';
import '../../providers/tent_provider.dart';
import '../../models/tent.dart';

class CampingBookingScreen extends StatefulWidget {
  const CampingBookingScreen({super.key});

  @override
  State<CampingBookingScreen> createState() => _CampingBookingScreenState();
}

class _CampingBookingScreenState extends State<CampingBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TentProvider>(context, listen: false).loadTents();
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final provider = Provider.of<TentProvider>(context, listen: false);
    final initial = isStart ? (provider.startDate ?? DateTime.now()) : (provider.endDate ?? DateTime.now().add(const Duration(days: 1)));
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 365));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      if (isStart) {
        provider.setDates(picked, provider.endDate);
      } else {
        provider.setDates(provider.startDate, picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camping Tent Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<TentProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.tents.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text('Choose a tent type'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Tent>(
                    value: provider.selectedTent,
                    items: provider.tents.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text('${t.name} • ${t.capacity}p • ₹${t.basePrice.toStringAsFixed(2)}'),
                      );
                    }).toList(),
                    onChanged: provider.setSelectedTent,
                    validator: (val) => val == null ? 'Select a tent type' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Check-in'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _pickDate(context, true),
                              child: Text(provider.startDate == null ? 'Select' : provider.startDate!.toIso8601String().substring(0, 10)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Check-out'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _pickDate(context, false),
                              child: Text(provider.endDate == null ? 'Select' : provider.endDate!.toIso8601String().substring(0, 10)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: provider.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Quantity (number of tents)'),
                    keyboardType: TextInputType.number,
                    validator: ValidationBuilder().minLength(1).build(),
                    onChanged: (v) {
                      final q = int.tryParse(v) ?? 1;
                      provider.setQuantity(q);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Nights'),
                    trailing: Text('${provider.nights}'),
                  ),
                  ListTile(
                    title: const Text('Total price'),
                    trailing: Text('₹${provider.totalPrice.toStringAsFixed(2)}'),
                  ),
                  const SizedBox(height: 8),
                  if (provider.error != null)
                    Text(provider.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: provider.loading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            final id = await provider.createBooking();
                            if (id != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Booking created: $id')),
                              );
                            }
                          },
                    child: provider.loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Confirm Booking'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}