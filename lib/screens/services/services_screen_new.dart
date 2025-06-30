import 'package:flutter/material.dart';
import 'package:stibe_partner/constants/app_theme.dart';
import 'package:stibe_partner/widgets/custom_app_bar.dart';
import 'package:stibe_partner/api/salon_service.dart';
import 'package:stibe_partner/screens/services/enhanced_services_screen.dart';

// NOTE: This screen is deprecated and replaced by the Services tab in SalonDetailScreen
// Services functionality is now integrated into individual salon management

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final SalonService _salonService = SalonService();
  List<SalonDto> _activeSalons = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActiveSalons();
  }

  Future<void> _loadActiveSalons() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final salons = await _salonService.getMySalons();
      final activeSalons = salons.where((salon) => salon.isActive).toList();
      
      setState(() {
        _activeSalons = activeSalons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Services',
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading salons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadActiveSalons,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_activeSalons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Salons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need to have at least one active salon to manage services.',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              },
              child: const Text('Go to Salons'),
            ),
          ],
        ),
      );
    }

    if (_activeSalons.length == 1) {
      // Auto-navigate to the single salon's services
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EnhancedServicesScreen(
              salonId: _activeSalons.first.id,
              salonName: _activeSalons.first.name,
            ),
          ),
        );
      });
      return const Center(child: CircularProgressIndicator());
    }

    // Multiple salons - show salon selection
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Salon',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose which salon you want to manage services for:',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _activeSalons.length,
              itemBuilder: (context, index) {
                final salon = _activeSalons[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: salon.profilePictureUrl != null && 
                                      salon.profilePictureUrl!.isNotEmpty
                          ? NetworkImage(salon.profilePictureUrl!)
                          : null,
                      child: salon.profilePictureUrl == null || 
                             salon.profilePictureUrl!.isEmpty
                          ? Icon(
                              Icons.store,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    title: Text(
                      salon.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text('${salon.address}, ${salon.city}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EnhancedServicesScreen(
                            salonId: salon.id,
                            salonName: salon.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
