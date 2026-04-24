import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../services/location_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_input.dart';
import '../../widgets/common/theme_toggle_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  UserRole? _selectedRole;
  late TabController _tabController;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLocating = false;
  DonorType? _selectedDonorType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _orgNameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (ok && mounted) {
      final user = auth.user;
      if (user != null) {
        
        bool roleMatches = false;
        if (_selectedRole == UserRole.admin) {
          roleMatches = user.role == UserRole.admin || user.role == UserRole.superAdmin;
        } else {
          roleMatches = user.role == _selectedRole;
        }

        if (!roleMatches) {
          await auth.signOut();
          _error('This account is not registered as a ${_selectedRole!.name.toUpperCase()}.');
          return;
        }
      }
    } else if (!ok && mounted) {
      _error(auth.error ?? 'Login Failed');
    }
  }

  Future<void> _signUp() async {
    if (_selectedRole == UserRole.donor && _selectedDonorType == null) {
      _error('Please select a donor category');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _selectedRole!,
      phone: _phoneCtrl.text.trim(),
      donorType: _selectedDonorType,
      address: _addressCtrl.text.trim(),
      organizationName: _orgNameCtrl.text.trim(),
    );
    if (!ok && mounted) _error(auth.error ?? 'Registration Failed');
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedRole == null ? _buildRoleSelection() : _buildAuthForm(),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            top: 10,
            right: 10,
            child: SafeArea(child: ThemeToggleButton()),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      key: const ValueKey('role_selection'),
      children: [
        Image.asset('assets/images/app_logo.png', width: 100, height: 100),
        const SizedBox(height: 16),
        const Text('Food-Aid', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const Text('Select your role to continue', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 40),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _RoleCard(
              role: UserRole.donor,
              icon: Icons.volunteer_activism_rounded,
              label: 'Donor',
              color: Colors.orange,
              onTap: () => setState(() {
                _selectedRole = UserRole.donor;
                _selectedDonorType = null;
              }),
            ),
            _RoleCard(
              role: UserRole.ngo,
              icon: Icons.diversity_3_rounded,
              label: 'NGO',
              color: Colors.teal,
              onTap: () => setState(() {
                _selectedRole = UserRole.ngo;
              }),
            ),
            _RoleCard(
              role: UserRole.logisticsEmployee,
              icon: Icons.delivery_dining_rounded,
              label: 'Delivery',
              color: Colors.deepOrange,
              onTap: () => setState(() {
                _selectedRole = UserRole.logisticsEmployee;
              }),
            ),
            _RoleCard(
              role: UserRole.admin,
              icon: Icons.admin_panel_settings_rounded,
              label: 'Admin',
              color: Colors.deepPurple,
              onTap: () => setState(() {
                _selectedRole = UserRole.admin;
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    final hasTabs = _selectedRole != UserRole.admin && _selectedRole != UserRole.superAdmin;
    final isRegister = hasTabs && _tabController.index == 1;
    final color = _roleColor(_selectedRole!);

    return Column(
      key: ValueKey(_selectedRole),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => setState(() {
                _selectedRole = null;
                _selectedDonorType = null;
                _tabController.index = 0; 
              }),
            ),
            const SizedBox(width: 8),
            Text(_selectedRole!.name.toUpperCase(), 
                style: TextStyle(color: color, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              if (hasTabs)
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Register'),
                  ],
                  indicatorColor: color,
                  labelColor: color,
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('Sign In to Account', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  child: isRegister ? _buildRegisterFields() : _buildLoginFields(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        AppInput(label: 'Email', controller: _emailCtrl, prefixIcon: Icons.email_outlined),
        const SizedBox(height: 16),
        AppInput(
          label: 'Password',
          controller: _passCtrl,
          prefixIcon: Icons.lock_outline,
          obscureText: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Sign In', onPressed: _signIn, backgroundColor: _roleColor(_selectedRole!)),
      ],
    );
  }

  Widget _buildRegisterFields() {
    return Column(
      children: [
        AppInput(label: 'Full Name', controller: _nameCtrl, prefixIcon: Icons.person_outline),
        const SizedBox(height: 16),
        AppInput(label: 'Email', controller: _emailCtrl, prefixIcon: Icons.email_outlined),
        const SizedBox(height: 16),
        AppInput(
          label: 'Password',
          controller: _passCtrl,
          prefixIcon: Icons.lock_outline,
          obscureText: _obscure,
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        const SizedBox(height: 16),
        if (_selectedRole == UserRole.donor) ...[
          const Text('Donor Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DonorType.values.map((t) => ChoiceChip(
              label: Text(
                t.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _selectedDonorType == t ? Colors.white : Colors.grey[700],
                ),
              ),
              selected: _selectedDonorType == t,
              selectedColor: Colors.orange,
              backgroundColor: Colors.grey[100],
              showCheckmark: false,
              onSelected: (selected) {
                setState(() => _selectedDonorType = selected ? t : null);
              },
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (_selectedRole == UserRole.ngo) ...[
          AppInput(label: 'Organization Name', controller: _orgNameCtrl, prefixIcon: Icons.business),
          const SizedBox(height: 16),
        ],
        Row(
          children: [
            Expanded(child: AppButton(
              label: _isLocating ? '...' : 'GPS', 
              onPressed: _isLocating ? null : _detectLocation,
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
            )),
            const SizedBox(width: 8),
            Expanded(child: AppInput(label: 'Address', controller: _addressCtrl)),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(label: 'Register', onPressed: _signUp, backgroundColor: _roleColor(_selectedRole!)),
      ],
    );
  }

  Future<void> _detectLocation() async {
    setState(() => _isLocating = true);
    final loc = LocationService();
    final pos = await loc.getCurrentPosition();
    if (pos != null) {
      final addr = await loc.reverseGeocode(GeoPoint(pos.latitude, pos.longitude));
      if (mounted) setState(() => _addressCtrl.text = addr ?? '${pos.latitude}, ${pos.longitude}');
    }
    setState(() => _isLocating = false);
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin: return const Color(0xFF10B981);
      case UserRole.ngo: return Colors.teal;
      case UserRole.donor: return Colors.orange;
      case UserRole.logisticsEmployee: return Colors.deepOrange;
      default: return AppColors.primary;
    }
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({required this.role, required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
