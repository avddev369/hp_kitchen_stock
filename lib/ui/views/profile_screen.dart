import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../helper/preferences.dart';
import 'admin/manage_access_screen.dart';
import 'auth/login.dart';

const Color _kOrange = Color(0xFFFF6B35);
const Color _kOrangeLight = Color(0xFFFFF0EA);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Colors.white;
const Color _kBorder = Color(0xFFEEEFF4);
const Color _kTextPrimary = Color(0xFF1A1D23);
const Color _kTextSecondary = Color(0xFF9599B0);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _mobile = '';
  bool _isMaster = false;
  bool _isAdmin = false;
  bool _isFix = false;
  List<Map<String, dynamic>> _godowns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final name = await Preferences.getUserName();
    final mobile = await Preferences.getMobile();
    final isMaster = await Preferences.getIsMaster();
    final isAdmin = await Preferences.getIsAdmin();
    final isFix = await Preferences.getIsFix();
    final godowns = await Preferences.getGodowns();
    if (!mounted) return;
    setState(() {
      _name = name ?? 'Unknown';
      _mobile = mobile ?? '';
      _isMaster = isMaster;
      _isAdmin = isAdmin;
      _isFix = isFix;
      _godowns = godowns;
      _isLoading = false;
    });
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: error ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _createGodown() async {
    final created = await showCreateGodownDialog(context);
    if (created == true) {
      _showSnack('Godown created successfully!');
      _loadProfile();
    }
  }

  Future<void> _createUser() async {
    final created = await showCreateUserDialog(context);
    if (created == true) {
      _showSnack('User created successfully!');
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade400,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _kTextSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _kBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: _kTextSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await Preferences.clearAll();
                          Get.offAll(() => LoginScreen());
                        },
                        child: Text(
                          'Logout',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String get _initial =>
      _name.trim().isNotEmpty ? _name.trim()[0].toUpperCase() : 'U';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: _kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kOrange))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                _buildProfileCard(),
                const SizedBox(height: 20),
                if (_godowns.isNotEmpty) ...[
                  _buildSectionLabel('Your Godowns'),
                  const SizedBox(height: 8),
                  _buildGodownsCard(),
                  const SizedBox(height: 20),
                ],
                if (_isMaster) ...[
                  _buildSectionLabel('Quick Actions'),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    icon: Icons.warehouse_rounded,
                    label: 'Create Godown',
                    onTap: _createGodown,
                  ),
                  const SizedBox(height: 8),
                  _buildActionTile(
                    icon: Icons.person_add_rounded,
                    label: 'Create User',
                    onTap: _createUser,
                  ),
                  const SizedBox(height: 20),
                ],
                _buildActionTile(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  iconColor: Colors.red.shade400,
                  labelColor: Colors.red.shade400,
                  onTap: _confirmLogout,
                ),
              ],
            ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF9A5A), Color(0xFFFF6B35)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initial,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _name,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          if (_mobile.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _mobile,
              style: GoogleFonts.poppins(fontSize: 13, color: _kTextSecondary),
            ),
          ],
          if (_isMaster || _isAdmin || _isFix) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                if (_isMaster) _buildRoleBadge('Master'),
                if (_isAdmin) _buildRoleBadge('Admin'),
                if (_isFix) _buildRoleBadge('Fixed'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _kOrangeLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _kOrange,
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: _kTextSecondary,
      ),
    );
  }

  Widget _buildGodownsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _godowns.map((g) {
          final name = (g['godown_name'] ?? '').toString();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _kOrangeLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warehouse_rounded, color: _kOrange, size: 14),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _kOrange,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return Material(
      color: _kSurface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? _kOrange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: labelColor ?? _kTextPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: labelColor ?? _kTextSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
