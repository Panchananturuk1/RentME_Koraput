import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/package_provider.dart';
import '../../models/tour_package.dart';
import '../../utils/ui_feedback.dart';

class PackageBookingScreen extends StatefulWidget {
  const PackageBookingScreen({super.key});

  @override
  State<PackageBookingScreen> createState() => _PackageBookingScreenState();
}

class _PackageBookingScreenState extends State<PackageBookingScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PackageProvider>(context, listen: false).loadPackages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All-in-One Packages'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Consumer<PackageProvider>(
            builder: (context, provider, child) {
              if (provider.loading && provider.packages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.error != null) {
                return Center(child: Text('Error: ${provider.error}'));
              }

              if (provider.packages.isEmpty) {
                 return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Text('No packages available yet.', style: TextStyle(fontSize: 16)),
                       const SizedBox(height: 16),
                       ElevatedButton(
                         onPressed: () {
                            // This will trigger the service to seed packages if empty
                            provider.loadPackages();
                         },
                         child: const Text('Refresh Packages'),
                       ),
                     ],
                   ),
                 );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.packages.length,
                itemBuilder: (context, index) {
                  final package = provider.packages[index];
                  return _buildPackageCard(context, package);
                },
              );
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, TourPackage package) {
    // Fallback for known broken URL
    String imageUrl = package.imageUrl;
    if (imageUrl.contains('odishatourism.gov.in')) {
      imageUrl = 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?q=80&w=1000&auto=format&fit=crop';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Package Image (Placeholder or Network)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl.isNotEmpty 
                  ? imageUrl 
                  : 'https://via.placeholder.com/400x200?text=Koraput+Tour',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.landscape, size: 50, color: Colors.grey)),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Text(
                        '₹${package.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                Text(
                  package.description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                
                const SizedBox(height: 16),
                
                // Places
                const Text(
                  'Places Covered:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: package.places.map((place) {
                    return Chip(
                      label: Text(place),
                      backgroundColor: Colors.blue[50],
                      labelStyle: const TextStyle(color: Colors.blue),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Inclusions
                const Text(
                  'Included in Package:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...package.inclusions.map((inclusion) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text(inclusion),
                      ],
                    ),
                  );
                }),
                
                const SizedBox(height: 20),
                
                // Book Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showBookingDialog(context, package);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext parentContext, TourPackage package) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    int persons = 1;
    
    showDialog(
      context: parentContext,
      builder: (dialogContext) => StatefulBuilder(
        builder: (sbContext, setState) {
          return AlertDialog(
            title: Text('Book ${package.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Travel Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: sbContext,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(selectedDate.toIso8601String().substring(0, 10)),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Number of Persons:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: persons > 1 ? () => setState(() => persons--) : null,
                    ),
                    Text('$persons', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => persons++),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₹${(package.price * persons).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9)),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(sbContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                   Navigator.pop(sbContext);
                   _processBooking(package, selectedDate, persons);
                },
                child: const Text('Confirm Booking'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _processBooking(TourPackage package, DateTime date, int persons) async {
    if (!mounted) return;

    setState(() {
      _isProcessing = true;
    });

    bool success = false;
    String? errorMessage;

    try {
      success = await Provider.of<PackageProvider>(context, listen: false)
          .bookPackage(package, date, persons);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }

    if (mounted) {
      if (success) {
        UIFeedback.showSuccess(context, 'Booking confirmed! Check your dashboard.');
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        UIFeedback.showError(context, errorMessage ?? 'Booking failed. Please try again.');
      }
    }
  }
}
