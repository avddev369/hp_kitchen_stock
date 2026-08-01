import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../api/api.dart';

const Color _kOrange = Color(0xFFFF6B35);
const Color _kTextPrimary = Color(0xFF1A1D23);
const Color _kTextSecondary = Color(0xFF9599B0);
const Color _kBorder = Color(0xFFEEEFF4);

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.poppins(color: _kTextSecondary, fontSize: 13),
    filled: true,
    fillColor: const Color(0xFFFFFBF8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _kOrange, width: 1.4),
    ),
  );
}

const String kGodownNamePrefix = 'HP-';

/// Opens the create-godown dialog. Reusable from anywhere in the app (login
/// prompt, empty godown pickers, Profile screen) so master users are never
/// stuck without a way to create their first godown.
Future<bool?> showCreateGodownDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const _CreateGodownDialog(),
  );
}

/// Opens the create-user dialog (master only). Godown access is assigned
/// automatically by the backend based on the isAdmin/isFix flags.
Future<bool?> showCreateUserDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const _CreateUserDialog(),
  );
}

class _CreateGodownDialog extends StatefulWidget {
  const _CreateGodownDialog();

  @override
  State<_CreateGodownDialog> createState() => _CreateGodownDialogState();
}

class _CreateGodownDialogState extends State<_CreateGodownDialog> {
  final _nameController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final suffix = _nameController.text.trim();
    if (suffix.isEmpty) {
      setState(() => _error = 'Godown name is required.');
      return;
    }
    final name = '$kGodownNamePrefix$suffix';

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final response = await Api.createGodown(name);
      if (response['errorStatus'] == false) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(
          () => _error =
              response['message']?.toString() ?? 'Failed to create godown',
        );
      }
    } catch (error) {
      setState(() => _error = 'Error: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Godown',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: GoogleFonts.poppins(fontSize: 14),
              decoration: _fieldDecoration('Godown name').copyWith(
                prefixText: kGodownNamePrefix,
                prefixStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kTextPrimary,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 12.5),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Create',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;
  bool _isFix = false;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || mobile.isEmpty || password.isEmpty) {
      setState(() => _error = 'Name, mobile and password are required.');
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      setState(() => _error = 'Mobile number must be exactly 10 digits.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final response = await Api.createSubUser(
        name: name,
        mobile: mobile,
        password: password,
        isAdmin: _isAdmin,
        isFix: _isFix,
      );
      if (response['errorStatus'] == false) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(
          () => _error =
              response['message']?.toString() ?? 'Failed to create user',
        );
      }
    } catch (error) {
      setState(() => _error = 'Error: $error');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create User',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _fieldDecoration('Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _fieldDecoration('Mobile number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: _fieldDecoration('Password'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeThumbColor: _kOrange,
                value: _isAdmin,
                onChanged: (value) {
                  setState(() {
                    _isAdmin = value;
                    if (value) _isFix = false;
                  });
                },
                title: Text(
                  'Admin',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Also gets every fixed-default godown automatically.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _kTextSecondary,
                  ),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeThumbColor: _kOrange,
                value: _isFix,
                onChanged: (value) {
                  setState(() {
                    _isFix = value;
                    if (value) _isAdmin = false;
                  });
                },
                title: Text(
                  'Fixed',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                subtitle: Text(
                  'Only ever gets the fixed-default godowns (AVD, AVD Cold Storage).',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _kTextSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Godown access is assigned automatically: same godowns as '
                'you, or the fixed-default godowns if Fixed is on (plus the '
                'fixed godowns too if Admin is on).',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: _kTextSecondary,
                  height: 1.4,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: GoogleFonts.poppins(color: Colors.red, fontSize: 12.5),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Create',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
