import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';

enum DeliveryMethod { collect, delivery }
enum PaymentMethod { payNow, payOnDelivery }

class CheckoutDialog extends StatefulWidget {
  const CheckoutDialog({super.key, required this.items, required this.subtotal});

  final List<CartItem> items;
  final double subtotal;

  @override
  State<CheckoutDialog> createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isGift = false;
  DeliveryMethod _deliveryMethod = DeliveryMethod.collect;
  PaymentMethod _paymentMethod = PaymentMethod.payNow;
  bool _isSubmitting = false;

  double get _deliveryFee =>
      !_isGift && _deliveryMethod == DeliveryMethod.delivery ? bikerDeliveryFee : 0;

  double get _total => widget.subtotal + _deliveryFee;

  Product? get _referenceProduct =>
      widget.items.isNotEmpty ? widget.items.first.product : null;

  String _formatCurrency(double amount) {
    final Product? reference = _referenceProduct;
    if (reference != null) {
      return reference.formatPrice(amount);
    }
    return 'US\$ ${amount.toStringAsFixed(2)}';
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Checkout',
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Gift for someone in Zimbabwe'),
                    value: _isGift,
                    onChanged: _isSubmitting
                        ? null
                        : (bool value) {
                            setState(() {
                              _isGift = value;
                              if (_isGift) {
                                _deliveryMethod = DeliveryMethod.delivery;
                                _paymentMethod = PaymentMethod.payNow;
                              }
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  if (_isGift) ...<Widget>[
                    _buildTextField(
                      controller: _recipientNameController,
                      label: 'Recipient Name',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _recipientPhoneController,
                      label: 'Recipient Phone',
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator,
                    ),
                  ] else ...<Widget>[
                    Text('Fulfilment', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    RadioListTile<DeliveryMethod>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Collect from Valley Farm'),
                      subtitle: const Text('We will prepare your order for pickup at the farm shop.'),
                      value: DeliveryMethod.collect,
                      groupValue: _deliveryMethod,
                      onChanged: _isSubmitting
                          ? null
                          : (DeliveryMethod? value) {
                              if (value != null) {
                                setState(() {
                                  _deliveryMethod = value;
                                  if (_deliveryMethod == DeliveryMethod.collect) {
                                    _paymentMethod = PaymentMethod.payNow;
                                  }
                                });
                              }
                            },
                    ),
                    RadioListTile<DeliveryMethod>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Deliver with Valley Farm Biker'),
                      subtitle: Text(
                        'Available in Harare. A ${_formatCurrency(bikerDeliveryFee)} biker fee applies.',
                      ),
                      value: DeliveryMethod.delivery,
                      groupValue: _deliveryMethod,
                      onChanged: _isSubmitting
                          ? null
                          : (DeliveryMethod? value) {
                              if (value != null) {
                                setState(() {
                                  _deliveryMethod = value;
                                });
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _customerNameController,
                      label: 'Your Name',
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _customerPhoneController,
                      label: 'Your Phone',
                      keyboardType: TextInputType.phone,
                      validator: _requiredValidator,
                    ),
                    if (_deliveryMethod == DeliveryMethod.delivery) ...<Widget>[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Delivery Address',
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 3,
                        validator: _requiredValidator,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text('Payment Method', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    RadioListTile<PaymentMethod>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Pay Full Amount Now'),
                      value: PaymentMethod.payNow,
                      groupValue: _paymentMethod,
                      onChanged: _isSubmitting
                          ? null
                          : (PaymentMethod? value) {
                              if (value != null) {
                                setState(() => _paymentMethod = value);
                              }
                            },
                    ),
                    RadioListTile<PaymentMethod>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Pay Biker on Delivery'),
                      value: PaymentMethod.payOnDelivery,
                      groupValue: _paymentMethod,
                      onChanged: _isSubmitting || _deliveryMethod != DeliveryMethod.delivery
                          ? null
                          : (PaymentMethod? value) {
                              if (value != null) {
                                setState(() => _paymentMethod = value);
                              }
                            },
                    ),
                  ],
                  const SizedBox(height: 24),
                    _OrderSummary(
                      subtotal: widget.subtotal,
                      deliveryFee: _deliveryFee,
                      total: _total,
                      formatAmount: _formatCurrency,
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(_isSubmitting ? 'Submitting...' : 'Submit Order'),
                        onPressed: _isSubmitting ? null : _submit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final Map<String, dynamic> customer = <String, dynamic>{
      'isGift': _isGift,
      'subtotal': widget.subtotal,
      'total': _total,
      'deliveryFee': _deliveryFee,
    };

    if (_isGift) {
      customer['recipientName'] = _recipientNameController.text.trim();
      customer['recipientPhone'] = _recipientPhoneController.text.trim();
      customer['deliveryMethod'] = 'delivery';
      customer['paymentMethod'] = PaymentMethod.payNow.name;
    } else {
      customer['deliveryMethod'] = _deliveryMethod.name;
      customer['paymentMethod'] = _paymentMethod.name;
      customer['customerName'] = _customerNameController.text.trim();
      customer['customerPhone'] = _customerPhoneController.text.trim();
      if (_deliveryMethod == DeliveryMethod.delivery) {
        customer['address'] = _addressController.text.trim();
      }
    }

    final OrderService service = OrderService();
    final bool success = await service.submitOrder(
      items: widget.items,
      customer: customer,
      subtotal: widget.subtotal,
      deliveryFee: _deliveryFee,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      context.read<CartProvider>().clear();
      Navigator.of(context).pop(true);
    } else {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong sending your order. Please try again.')),
      );
    }
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.formatAmount,
  });

  final double subtotal;
  final double deliveryFee;
  final double total;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Order Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Subtotal', value: subtotal, formatter: formatAmount),
          _SummaryRow(label: 'Biker Delivery Fee', value: deliveryFee, formatter: formatAmount),
          const Divider(),
          _SummaryRow(label: 'Total', value: total, formatter: formatAmount, emphasize: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.formatter,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final String Function(double) formatter;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? style = emphasize
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label),
          Text(formatter(value), style: style),
        ],
      ),
    );
  }
}
