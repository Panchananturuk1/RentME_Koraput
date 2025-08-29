import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cash',
      'name': 'Cash',
      'icon': Icons.money,
      'isSelected': true,
    },
    {
      'id': 'upi',
      'name': 'UPI Payment',
      'icon': Icons.qr_code,
      'isSelected': false,
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'isSelected': false,
    },
    {
      'id': 'wallet',
      'name': 'Digital Wallet',
      'icon': Icons.account_balance_wallet,
      'isSelected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimary,
          ),
        ),
        title: Text(
          'Payment Methods',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Payment Methods List
            ...List.generate(
              _paymentMethods.length,
              (index) => _buildPaymentMethodCard(_paymentMethods[index], index),
            ),
            
            SizedBox(height: 30.h),
            
            // Add New Payment Method
            _buildAddPaymentMethodCard(),
            
            SizedBox(height: 30.h),
            
            // Recent Transactions
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            _buildTransactionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: method['isSelected'] 
              ? AppTheme.primaryColor 
              : Colors.grey[200]!,
          width: method['isSelected'] ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: method['isSelected'] 
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            method['icon'],
            color: method['isSelected'] 
                ? AppTheme.primaryColor 
                : AppTheme.textSecondary,
            size: 24.sp,
          ),
        ),
        title: Text(
          method['name'],
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: method['isSelected']
            ? Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24.sp,
              )
            : Icon(
                Icons.radio_button_unchecked,
                color: AppTheme.textSecondary,
                size: 24.sp,
              ),
        onTap: () {
          setState(() {
            for (var i = 0; i < _paymentMethods.length; i++) {
              _paymentMethods[i]['isSelected'] = i == index;
            }
          });
        },
      ),
    );
  }

  Widget _buildAddPaymentMethodCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.w),
        leading: Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.add,
            color: AppTheme.primaryColor,
            size: 24.sp,
          ),
        ),
        title: Text(
          'Add New Payment Method',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.primaryColor,
          size: 16.sp,
        ),
        onTap: () {
          _showAddPaymentMethodDialog();
        },
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactions = [
      {
        'id': 'TXN001',
        'date': '2024-01-15',
        'amount': 120,
        'type': 'Ride Payment',
        'status': 'Success',
        'method': 'UPI',
      },
      {
        'id': 'TXN002',
        'date': '2024-01-14',
        'amount': 80,
        'type': 'Ride Payment',
        'status': 'Success',
        'method': 'Cash',
      },
      {
        'id': 'TXN003',
        'date': '2024-01-13',
        'amount': 150,
        'type': 'Ride Payment',
        'status': 'Failed',
        'method': 'Card',
      },
    ];

    return Column(
      children: transactions.map((transaction) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: transaction['status'] == 'Success'
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  transaction['status'] == 'Success'
                      ? Icons.check
                      : Icons.close,
                  color: transaction['status'] == 'Success'
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                  size: 20.sp,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['type'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${transaction['date']} • ${transaction['method']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${transaction['amount']}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    transaction['status'] as String,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: transaction['status'] == 'Success'
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Add Credit/Debit Card'),
              onTap: () {
                Navigator.pop(context);
                _showAddCardDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('Add UPI ID'),
              onTap: () {
                Navigator.pop(context);
                _showAddUPIDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Link Digital Wallet'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Digital wallet linking coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry',
                        hintText: 'MM/YY',
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Cardholder Name',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Card added successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  void _showAddUPIDialog() {
    final upiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add UPI ID'),
        content: TextField(
          controller: upiController,
          decoration: const InputDecoration(
            labelText: 'UPI ID',
            hintText: 'example@upi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('UPI ID added successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Add UPI'),
          ),
        ],
      ),
    );
  }
}