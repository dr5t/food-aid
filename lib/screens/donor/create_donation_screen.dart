import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../models/donation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/common/app_app_bar.dart';

class CreateDonationScreen extends StatefulWidget {
  const CreateDonationScreen({super.key});

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();

  FoodType _foodType = FoodType.cookedMeal;
  MealType _mealType = MealType.veg;
  DateTime _expiryDate = DateTime.now().add(const Duration(hours: 6));
  GeoPoint? _location;
  bool _isLoading = false;
  bool _isLocating = false;
  bool _locationVerified = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Donate Food',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _SectionLabel('What are you donating?'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Food Title',
                hintText: 'e.g. Rajma Chawal, Wedding Buffet Leftovers',
                prefixIcon: Icon(Icons.fastfood_outlined, size: 20),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a title' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Additional details about the food',
                prefixIcon: Icon(Icons.notes, size: 20),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.xl),

            _SectionLabel('Food Type'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _SelectCard(
                  label: 'Cooked',
                  icon: Icons.restaurant,
                  isSelected: _foodType == FoodType.cookedMeal,
                  onTap: () => setState(() => _foodType = FoodType.cookedMeal),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SelectCard(
                  label: 'Raw',
                  icon: Icons.grain,
                  isSelected: _foodType == FoodType.rawGroceries,
                  onTap: () =>
                      setState(() => _foodType = FoodType.rawGroceries),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SelectCard(
                  label: 'Packaged',
                  icon: Icons.inventory_2,
                  isSelected: _foodType == FoodType.packedFood,
                  onTap: () => setState(() => _foodType = FoodType.packedFood),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _SelectCard(
                  label: 'Bakery',
                  icon: Icons.bakery_dining,
                  isSelected: _foodType == FoodType.bakeryItems,
                  onTap: () =>
                      setState(() => _foodType = FoodType.bakeryItems),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SelectCard(
                  label: 'Fruits',
                  icon: Icons.apple,
                  isSelected: _foodType == FoodType.fruits,
                  onTap: () => setState(() => _foodType = FoodType.fruits),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SelectCard(
                  label: 'Other',
                  icon: Icons.more_horiz,
                  isSelected: _foodType == FoodType.other,
                  onTap: () => setState(() => _foodType = FoodType.other),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            _SectionLabel('Meal Type'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _SelectCard(
                  label: 'Veg',
                  icon: Icons.eco,
                  color: AppColors.success,
                  isSelected: _mealType == MealType.veg,
                  onTap: () => setState(() => _mealType = MealType.veg),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SelectCard(
                  label: 'Non-Veg',
                  icon: Icons.restaurant,
                  color: AppColors.accentDark,
                  isSelected: _mealType == MealType.nonVeg,
                  onTap: () => setState(() => _mealType = MealType.nonVeg),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SelectCard(
                  label: 'Both',
                  icon: Icons.dining,
                  isSelected: _mealType == MealType.both,
                  onTap: () => setState(() => _mealType = MealType.both),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            _SectionLabel('Quantity (Optional)'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Approx. meals / servings',
                prefixIcon: Icon(Icons.people, size: 20),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _SectionLabel('Expiry Date & Time *', isRequired: true),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: _pickExpiry,
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: _formatDate(_expiryDate),
                    prefixIcon:
                        const Icon(Icons.schedule_outlined, size: 20),
                    suffixIcon:
                        const Icon(Icons.arrow_drop_down, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Food must be consumed before this time',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextHint
                    : AppColors.textHint,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            _SectionLabel('Pickup Location'),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                hintText: 'e.g. Rajpur Road, Dehradun',
                prefixIcon:
                    const Icon(Icons.location_on_outlined, size: 20),
                suffixIcon: _isLocating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.my_location, size: 20),
                        onPressed: _getCurrentLocation,
                      ),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter address' : null,
              onChanged: (_) =>
                  setState(() => _locationVerified = false),
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _verifyLocation,
                    icon: Icon(
                      _locationVerified
                          ? Icons.check_circle
                          : Icons.verified_outlined,
                      size: 18,
                      color: _locationVerified
                          ? AppColors.success
                          : null,
                    ),
                    label: Text(
                      _locationVerified
                          ? 'Location Verified'
                          : 'Verify Location',
                    ),
                  ),
                ),
              ],
            ),

            if (_locationVerified && _location != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16,
                        color: AppColors.success),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Lat: ${_location!.latitude.toStringAsFixed(4)}, Lng: ${_location!.longitude.toStringAsFixed(4)}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitDonation,
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Donation',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_expiryDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _expiryDate = DateTime(
        date.year, date.month, date.day,
        time.hour, time.minute,
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final loc = LocationService();
      final pos = await loc.getCurrentPosition();
      if (pos == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not get current location')),
          );
        }
        setState(() => _isLocating = false);
        return;
      }
      final geoPoint = GeoPoint(pos.latitude, pos.longitude);
      final address = await loc.reverseGeocode(geoPoint);
      setState(() {
        _location = geoPoint;
        _addressController.text = address ?? '';
        _locationVerified = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }
    setState(() => _isLocating = false);
  }

  Future<void> _verifyLocation() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;

    setState(() => _isLocating = true);
    try {
      final loc = LocationService();
      final geoPoint = await loc.geocodeAddress(address);
      if (geoPoint != null) {
        setState(() {
          _location = geoPoint;
          _locationVerified = true;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Could not verify this address')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification error: $e')),
        );
      }
    }
    setState(() => _isLocating = false);
  }

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isLoading = true);

    final donation = DonationModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      donorId: user.uid,
      donorName: user.name,
      donorType: user.donorType?.name,
      foodType: _foodType,
      mealType: _mealType,
      quantity: int.tryParse(_quantityController.text.trim()),
      unit: 'servings',
      expiryDate: _expiryDate,
      pickupAddress: _addressController.text.trim(),
      pickupLocation: _location ?? const GeoPoint(28.6139, 77.2090),
      status: DonationStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<DonationProvider>().createDonation(donation);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const _SectionLabel(this.text, {this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired)
          const Text(' *', style: TextStyle(color: AppColors.error)),
      ],
    );
  }
}

class _SelectCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectCard({
    required this.label,
    required this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? c.withValues(alpha: 0.08) : null,
            borderRadius:
                BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? c : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? c : null, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? c : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
