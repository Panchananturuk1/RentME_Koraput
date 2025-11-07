import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:form_validator/form_validator.dart';
import '../../providers/car_provider.dart';
import '../../models/car.dart';

class CarBookingScreen extends StatefulWidget {
  const CarBookingScreen({super.key});

  @override
  State<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CarProvider>(context, listen: false).loadCars();
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final provider = Provider.of<CarProvider>(context, listen: false);
    final initial = isStart
        ? (provider.startDate ?? DateTime.now())
        : (provider.endDate ?? DateTime.now().add(const Duration(days: 1)));
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
      appBar: AppBar(title: const Text('Rent a Car')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CarProvider>(
          builder: (context, provider, _) {
            if (provider.loading && provider.cars.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Text('Choose a car'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Car>(
                    isExpanded: true,
                    value: provider.selectedCar,
                    items: provider.cars.map((c) {
                      final subtitle = [
                        if (c.brand != null) c.brand!,
                        if (c.model != null) c.model!,
                        if (c.seats != null) '${c.seats} seats',
                        if (c.transmission != null) c.transmission!,
                        '₹${c.basePrice.toStringAsFixed(2)}/day',
                      ].join(' • ');
                      return DropdownMenuItem<Car>(
                        value: c,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${c.name} • $subtitle',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: provider.setSelectedCar,
                    validator: (val) => val == null ? 'Select a car' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start date'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _pickDate(context, true),
                              child: Text(provider.startDate == null
                                  ? 'Select'
                                  : provider.startDate!.toIso8601String().substring(0, 10)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End date'),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () => _pickDate(context, false),
                              child: Text(provider.endDate == null
                                  ? 'Select'
                                  : provider.endDate!.toIso8601String().substring(0, 10)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: provider.quantity.toString(),
                    decoration: const InputDecoration(labelText: 'Quantity (number of cars)'),
                    keyboardType: TextInputType.number,
                    validator: ValidationBuilder().minLength(1).build(),
                    onChanged: (v) {
                      final q = int.tryParse(v) ?? 1;
                      provider.setQuantity(q);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Days'),
                    trailing: Text('${provider.days}'),
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
                                SnackBar(content: Text('Car rental created: $id')),
                              );
                            }
                          },
                    child: provider.loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Confirm Rental'),
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