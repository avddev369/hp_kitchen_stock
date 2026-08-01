import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../api/api.dart';
import '../../../widgets/customAlertDialog.dart';

const Color _kOrange = Color(0xFFFF6B35);
const Color _kOrangeLight = Color(0xFFFFF0EA);
const Color _kBackground = Color(0xFFF7F8FA);
const Color _kSurface = Colors.white;
const Color _kBorder = Color(0xFFEEEFF4);
const Color _kTextPrimary = Color(0xFF1A1D23);
const Color _kTextSecondary = Color(0xFF9599B0);

class Godown {
  final int id;
  final String name;

  const Godown({required this.id, required this.name});

  static Godown? fromJson(dynamic json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final rawId = map['id'] ?? map['godownId'] ?? map['godown_id'];
    final id = int.tryParse(rawId?.toString() ?? '');
    final name = (map['godown_name'] ?? map['godownName'] ?? map['name'] ?? '')
        .toString()
        .trim();
    if (id == null || name.isEmpty) return null;
    return Godown(id: id, name: name);
  }
}

class SubUser {
  final int id;
  final String name;
  final String mobile;
  final bool isAdmin;
  final bool isFix;
  Set<int> godownIds;

  SubUser({
    required this.id,
    required this.name,
    required this.mobile,
    required this.isAdmin,
    required this.isFix,
    required this.godownIds,
  });

  static SubUser? fromJson(dynamic json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    final rawId = map['userId'] ?? map['id'];
    final id = int.tryParse(rawId?.toString() ?? '');
    final name = (map['name'] ?? '').toString().trim();
    final mobile = (map['mobile'] ?? '').toString().trim();
    if (id == null || name.isEmpty) return null;

    final Set<int> godownIds = {};
    if (map['godownIds'] is List) {
      for (final entry in (map['godownIds'] as List)) {
        final gid = int.tryParse(entry.toString());
        if (gid != null) godownIds.add(gid);
      }
    }
    if (map['godowns'] is List) {
      for (final entry in (map['godowns'] as List)) {
        final godown = Godown.fromJson(entry);
        if (godown != null) godownIds.add(godown.id);
      }
    }

    return SubUser(
      id: id,
      name: name,
      mobile: mobile,
      isAdmin: map['isAdmin'] == true,
      isFix: map['isFix'] == true,
      godownIds: godownIds,
    );
  }
}

class ManageAccessScreen extends StatefulWidget {
  const ManageAccessScreen({Key? key}) : super(key: key);

  @override
  State<ManageAccessScreen> createState() => _ManageAccessScreenState();
}

class _ManageAccessScreenState extends State<ManageAccessScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _isLoading = true;
  String? _loadError;
  List<Godown> _godowns = [];
  List<SubUser> _subUsers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([_fetchGodowns(), _fetchSubUsers()]);
      if (!mounted) return;
      setState(() {
        _godowns = results[0] as List<Godown>;
        _subUsers = results[1] as List<SubUser>;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Godown>> _fetchGodowns() async {
    final response = await Api.getGodowns();
    if (response['errorStatus'] == false && response['data'] is List) {
      return (response['data'] as List)
          .map(Godown.fromJson)
          .whereType<Godown>()
          .toList();
    }
    throw Exception(response['message'] ?? 'Failed to load godowns');
  }

  Future<List<SubUser>> _fetchSubUsers() async {
    final response = await Api.getSubUsers();
    if (response['errorStatus'] == false && response['data'] is List) {
      return (response['data'] as List)
          .map(SubUser.fromJson)
          .whereType<SubUser>()
          .toList();
    }
    throw Exception(response['message'] ?? 'Failed to load users');
  }

  void _showSnack(String message, {bool error = true}) {
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

  Future<void> _openCreateGodownDialog() async {
    final created = await showCreateGodownDialog(context);
    if (created == true) {
      _showSnack('Godown created successfully!', error: false);
      await _loadAll();
    }
  }

  Future<void> _openCreateUserDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const _CreateUserDialog(),
    );
    if (created == true) {
      _showSnack('User created successfully!', error: false);
      await _loadAll();
    }
  }

  Future<void> _openAssignGodownsSheet(SubUser user) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _AssignGodownsSheet(user: user, allGodowns: _godowns),
    );
    if (changed == true) {
      await _loadAll();
    }
  }

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
          'Manage Access',
          style: GoogleFonts.poppins(
            color: _kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadAll,
            icon: const Icon(Icons.refresh_rounded, color: _kTextPrimary),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: _kOrange,
          unselectedLabelColor: _kTextSecondary,
          indicatorColor: _kOrange,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
          tabs: const [
            Tab(text: 'Godowns'),
            Tab(text: 'Users'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: SpinKitFadingCircle(color: _kOrange, size: 44))
          : _loadError != null
          ? _buildErrorState()
          : TabBarView(
              controller: _tabController,
              children: [_buildGodownsTab(), _buildUsersTab()],
            ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final isGodownTab = _tabController.index == 0;
          return FloatingActionButton.extended(
            backgroundColor: _kOrange,
            foregroundColor: Colors.white,
            onPressed: isGodownTab
                ? _openCreateGodownDialog
                : _openCreateUserDialog,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              isGodownTab ? 'Create Godown' : 'Create User',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              _loadError ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: _kTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAll,
              style: ElevatedButton.styleFrom(backgroundColor: _kOrange),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGodownsTab() {
    if (_godowns.isEmpty) {
      return _buildEmptyState(
        icon: Icons.warehouse_rounded,
        title: 'No godowns yet',
        subtitle: 'Tap "Create Godown" to add your first location.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: _godowns.length,
      itemBuilder: (context, index) {
        final godown = _godowns[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _kOrangeLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warehouse_rounded,
                  color: _kOrange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  godown.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _kTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    if (_subUsers.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_alt_rounded,
        title: 'No users yet',
        subtitle: 'Tap "Create User" to add a team member.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      itemCount: _subUsers.length,
      itemBuilder: (context, index) {
        final user = _subUsers[index];
        final assignedNames = _godowns
            .where((g) => user.godownIds.contains(g.id))
            .map((g) => g.name)
            .toList();
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _openAssignGodownsSheet(user),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _kOrangeLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: _kOrange,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: _kTextPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (user.isAdmin) ...[
                                const SizedBox(width: 6),
                                _buildRoleBadge('Admin'),
                              ],
                              if (user.isFix) ...[
                                const SizedBox(width: 6),
                                _buildRoleBadge('Fixed'),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.mobile,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: _kTextSecondary,
                            ),
                          ),
                          if (assignedNames.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: assignedNames
                                  .map(
                                    (name) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _kOrangeLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10.5,
                                          color: _kOrange,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _kTextSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _kTextPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: _kTextSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: _kOrangeLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _kOrange, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: _kTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

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
/// prompt, empty godown pickers, Manage Access screen) so master users are
/// never stuck without a way to create their first godown.
Future<bool?> showCreateGodownDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => const _CreateGodownDialog(),
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

class _AssignGodownsSheet extends StatefulWidget {
  final SubUser user;
  final List<Godown> allGodowns;

  const _AssignGodownsSheet({required this.user, required this.allGodowns});

  @override
  State<_AssignGodownsSheet> createState() => _AssignGodownsSheetState();
}

class _AssignGodownsSheetState extends State<_AssignGodownsSheet> {
  late Set<int> _assignedIds;
  final Set<int> _pendingIds = {};
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _assignedIds = {...widget.user.godownIds};
  }

  Future<void> _toggle(Godown godown, bool assign) async {
    setState(() => _pendingIds.add(godown.id));
    try {
      final response = assign
          ? await Api.assignGodown(widget.user.id, godown.id)
          : await Api.unassignGodown(widget.user.id, godown.id);

      if (response['errorStatus'] == false) {
        setState(() {
          if (assign) {
            _assignedIds.add(godown.id);
          } else {
            _assignedIds.remove(godown.id);
          }
          _changed = true;
        });
      } else if (mounted) {
        await CustomAlertDialog.showErrorDialog(
          context,
          response['message']?.toString() ??
              (assign
                  ? 'Failed to assign godown'
                  : 'Failed to unassign godown'),
        );
      }
    } catch (error) {
      if (mounted) {
        await CustomAlertDialog.showErrorDialog(context, 'Error: $error');
      }
    } finally {
      if (mounted) setState(() => _pendingIds.remove(godown.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              widget.user.name,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Toggle godowns to assign or unassign access',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: _kTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.allGodowns.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No godowns available.',
                  style: GoogleFonts.poppins(
                    color: _kTextSecondary,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: widget.allGodowns.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final godown = widget.allGodowns[index];
                    final assigned = _assignedIds.contains(godown.id);
                    final pending = _pendingIds.contains(godown.id);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        godown.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _kTextPrimary,
                        ),
                      ),
                      trailing: pending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kOrange,
                              ),
                            )
                          : Switch(
                              value: assigned,
                              activeThumbColor: _kOrange,
                              onChanged: (value) => _toggle(godown, value),
                            ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
