import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/api/enhanced_service_management_service.dart';

class OfferManagementDialog extends StatefulWidget {
  final ServiceDto service;
  final Function(ServiceDto) onOfferUpdated;

  const OfferManagementDialog({
    super.key,
    required this.service,
    required this.onOfferUpdated,
  });

  @override
  State<OfferManagementDialog> createState() => _OfferManagementDialogState();
}

class _OfferManagementDialogState extends State<OfferManagementDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Form controllers
  final _percentageController = TextEditingController();
  final _fixedAmountController = TextEditingController();
  
  // Form state
  DateTime? _selectedExpiryDate;
  bool _hasExpiry = false;
  bool _isLoading = false;
  
  // Calculated values
  double? _calculatedOfferPrice;
  double? _savingsAmount;
  double? _savingsPercentage;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeExistingOffer();
    
    // Listen to text changes for real-time calculations
    _percentageController.addListener(_calculateFromPercentage);
    _fixedAmountController.addListener(_calculateFromFixedAmount);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _percentageController.dispose();
    _fixedAmountController.dispose();
    super.dispose();
  }

  void _initializeExistingOffer() {
    if (widget.service.hasActiveOffer) {
      _calculatedOfferPrice = widget.service.offerPrice;
      
      // Calculate percentage if offer exists
      if (widget.service.offerPrice != null) {
        final percentage = ((widget.service.price - widget.service.offerPrice!) / widget.service.price) * 100;
        _percentageController.text = percentage.toStringAsFixed(1);
        _fixedAmountController.text = widget.service.offerPrice!.toStringAsFixed(0);
      }
      
      // Set expiry date if exists
      if (widget.service.offerExpiryDate != null) {
        _hasExpiry = true;
        _selectedExpiryDate = widget.service.offerExpiryDate;
      }
      
      _updateCalculations();
    }
  }

  void _calculateFromPercentage() {
    final percentageText = _percentageController.text;
    if (percentageText.isNotEmpty) {
      try {
        final percentage = double.parse(percentageText);
        if (percentage >= 0 && percentage <= 100) {
          final discount = widget.service.price * (percentage / 100);
          _calculatedOfferPrice = widget.service.price - discount;
          _fixedAmountController.text = _calculatedOfferPrice!.toStringAsFixed(0);
          _updateCalculations();
        }
      } catch (e) {
        // Invalid input, ignore
      }
    }
  }

  void _calculateFromFixedAmount() {
    final amountText = _fixedAmountController.text;
    if (amountText.isNotEmpty) {
      try {
        final amount = double.parse(amountText);
        if (amount >= 0 && amount <= widget.service.price) {
          _calculatedOfferPrice = amount;
          final percentage = ((widget.service.price - amount) / widget.service.price) * 100;
          _percentageController.text = percentage.toStringAsFixed(1);
          _updateCalculations();
        }
      } catch (e) {
        // Invalid input, ignore
      }
    }
  }

  void _updateCalculations() {
    if (_calculatedOfferPrice != null) {
      _savingsAmount = widget.service.price - _calculatedOfferPrice!;
      _savingsPercentage = (_savingsAmount! / widget.service.price) * 100;
    } else {
      _savingsAmount = null;
      _savingsPercentage = null;
    }
    setState(() {});
  }

  void _clearOffer() {
    _percentageController.clear();
    _fixedAmountController.clear();
    _calculatedOfferPrice = null;
    _savingsAmount = null;
    _savingsPercentage = null;
    _selectedExpiryDate = null;
    _hasExpiry = false;
    setState(() {});
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedExpiryDate ?? DateTime.now().add(const Duration(hours: 1))),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedExpiryDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveOffer() async {
    if (_calculatedOfferPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set an offer price'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_calculatedOfferPrice! >= widget.service.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offer price must be less than original price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final serviceService = ServiceManagementService();
      final updatedService = await serviceService.updateService(
        widget.service.salonId,
        UpdateServiceRequest(
          id: widget.service.id,
          offerPrice: _calculatedOfferPrice,
          offerExpiryDate: _hasExpiry ? _selectedExpiryDate : null,
        ),
      );

      widget.onOfferUpdated(updatedService);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating offer: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeOffer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final serviceService = ServiceManagementService();
      final updatedService = await serviceService.updateService(
        widget.service.salonId,
        UpdateServiceRequest(
          id: widget.service.id,
          offerPrice: null,
          offerExpiryDate: null,
        ),
      );

      widget.onOfferUpdated(updatedService);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Offer removed successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing offer: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              _buildHeader(),
              _buildServiceInfo(),
              _buildTabBar(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: _buildTabContent(),
                      ),
                      _buildCalculationSummary(),
                      _buildExpirySection(),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 28, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.local_offer_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Offer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Set special pricing for this service',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.spa_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Current Price: ₹${widget.service.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          if (widget.service.hasActiveOffer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade100, Colors.green.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'By Percentage'),
          Tab(text: 'Fixed Amount'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildPercentageTab(),
        _buildFixedAmountTab(),
      ],
    );
  }

  Widget _buildPercentageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Discount Percentage',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _percentageController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            decoration: InputDecoration(
              hintText: 'Enter discount percentage (0-100)',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              suffixText: '%',
              suffixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.percent_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Select',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [10, 15, 20, 25, 30, 50].map((percentage) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _percentageController.text = percentage.toString();
                    _calculateFromPercentage();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedAmountTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Offer Price',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A202C),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _fixedAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
            decoration: InputDecoration(
              hintText: 'Enter offer price',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              prefixText: '₹ ',
              prefixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.currency_rupee_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Quick Select',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A5568),
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _getQuickAmounts().map((amount) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _fixedAmountController.text = amount.toString();
                    _calculateFromFixedAmount();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '₹$amount',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<int> _getQuickAmounts() {
    final price = widget.service.price.toInt();
    return [
      (price * 0.7).round(), // 30% off
      (price * 0.75).round(), // 25% off
      (price * 0.8).round(), // 20% off
      (price * 0.85).round(), // 15% off
      (price * 0.9).round(), // 10% off
    ].where((amount) => amount > 0 && amount < price).toList();
  }

  Widget _buildCalculationSummary() {
    if (_calculatedOfferPrice == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(28, 8, 28, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50.withOpacity(0.8),
            Colors.green.shade100.withOpacity(0.4)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calculate_rounded,
                  color: Colors.green.shade700,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Pricing Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Original Price:',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹${widget.service.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Color(0xFF9CA3AF),
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Offer Price:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                ),
              ),
              Text(
                '₹${_calculatedOfferPrice!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF059669),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'You Save:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF047857),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '₹${_savingsAmount!.toStringAsFixed(0)} (${_savingsPercentage!.toStringAsFixed(1)}%)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF047857),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpirySection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 8, 28, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 1.0,
                child: Checkbox(
                  value: _hasExpiry,
                  onChanged: (value) {
                    setState(() {
                      _hasExpiry = value ?? false;
                      if (!_hasExpiry) {
                        _selectedExpiryDate = null;
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Set Expiry Date',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A202C),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (_hasExpiry) ...[
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _selectExpiryDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedExpiryDate != null ? 'Expiry Date & Time' : 'Select Expiry',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                                letterSpacing: -0.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _selectedExpiryDate != null
                                  ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year} at ${_selectedExpiryDate!.hour.toString().padLeft(2, '0')}:${_selectedExpiryDate!.minute.toString().padLeft(2, '0')}'
                                  : 'Tap to select date and time',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedExpiryDate != null ? const Color(0xFF1A202C) : Colors.grey.shade500,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearOffer,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveOffer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.3),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.save_rounded, size: 18),
                            const SizedBox(width: 6),
                            const Text(
                              'Save Offer',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          if (widget.service.hasActiveOffer) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : _removeOffer,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade600),
                    const SizedBox(width: 6),
                    const Text(
                      'Remove Offer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
