import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobgenfest/constants.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _registrations = [];
  Map<String, dynamic>? _selectedRegistration;
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _redirectToHome();
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      if (response['role'] == 'admin') {
        setState(() => _isAdmin = true);
        _fetchRegistrations();
      } else {
        _redirectToHome();
      }
    } catch (e) {
      _redirectToHome();
    }
  }

  void _redirectToHome() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  Future<void> _fetchRegistrations() async {
    try {
      final response = await Supabase.instance.client
          .from('registrations')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _registrations = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePaymentStatus(String id, bool currentStatus) async {
    final bool newStatus = !currentStatus;

    // Optimistic Update
    setState(() {
      // Update in the main list
      final index = _registrations.indexWhere((r) => r['id'].toString() == id);
      if (index != -1) {
        _registrations[index]['has_paid'] = newStatus;
      }
      // Update selected registration
      if (_selectedRegistration?['id'].toString() == id) {
        _selectedRegistration!['has_paid'] = newStatus;
      }
    });

    try {
      await Supabase.instance.client
          .from('registrations')
          .update({'has_paid': newStatus}).eq('id', id);

      // Verify with a fresh fetch in the background
      _fetchRegistrations();
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          final index =
              _registrations.indexWhere((r) => r['id'].toString() == id);
          if (index != -1) {
            _registrations[index]['has_paid'] = currentStatus;
          }
          if (_selectedRegistration?['id'].toString() == id) {
            _selectedRegistration!['has_paid'] = currentStatus;
          }
        });

        print('Toggle error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating payment: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final int total = _registrations.length;
    final int paid = _registrations.where((r) => r['has_paid'] == true).length;
    final int pending = total - paid;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('PANEL DE CONTROL ORG',
              style: TextStyle(fontFamily: 'Lab', letterSpacing: 2)),
          backgroundColor: AppConstants.brandDark,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'PENDIENTES'),
              Tab(text: 'PAGADOS'),
            ],
            indicatorColor: AppConstants.brandOrange,
            labelColor: AppConstants.brandOrange,
            unselectedLabelColor: Colors.white54,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchRegistrations,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildStatsBar(total, paid, pending),
                  const Divider(color: Colors.white10, height: 1),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          children: [
                            SizedBox(width: 400, child: _buildTabViews()),
                            const VerticalDivider(
                                color: Colors.white10, width: 1),
                            Expanded(child: _buildDetail()),
                          ],
                        );
                      }
                      return _selectedRegistration == null
                          ? _buildTabViews()
                          : _buildDetail();
                    }),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatsBar(int total, int paid, int pending) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      color: const Color(0xFF111111),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statCard('TOTAL', total.toString(), Colors.white),
          _statCard('PAGADOS', paid.toString(), Colors.green),
          _statCard('PENDIENTES', pending.toString(), AppConstants.brandOrange),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white24,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lab')),
      ],
    );
  }

  Widget _buildTabViews() {
    final pendingList =
        _registrations.where((r) => r['has_paid'] != true).toList();
    final paidList =
        _registrations.where((r) => r['has_paid'] == true).toList();

    return TabBarView(
      children: [
        _buildList(pendingList),
        _buildList(paidList),
      ],
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(
          child: Text('No se encontraron registros',
              style: TextStyle(color: Colors.white24)));
    }

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final reg = list[index];
        final bool hasPaid = reg['has_paid'] ?? false;

        return ListTile(
          selected: _selectedRegistration?['id'] == reg['id'],
          selectedTileColor: AppConstants.brandOrange.withOpacity(0.1),
          leading: CircleAvatar(
            backgroundColor: Colors.white10,
            backgroundImage: (reg['profile_picture_url'] != null &&
                    reg['profile_picture_url'].toString().isNotEmpty)
                ? NetworkImage(reg['profile_picture_url'])
                : null,
            child: (reg['profile_picture_url'] == null ||
                    reg['profile_picture_url'].toString().isEmpty)
                ? Icon(hasPaid ? Icons.check : Icons.person,
                    color: hasPaid ? Colors.green : Colors.white24, size: 16)
                : null,
          ),
          title: Row(
            children: [
              Expanded(
                  child: Text(reg['full_name'] ?? 'Desconocido',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (hasPaid ? Colors.green : AppConstants.brandOrange)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: (hasPaid ? Colors.green : AppConstants.brandOrange)
                          .withOpacity(0.3)),
                ),
                child: Text(hasPaid ? 'PAGADO' : 'PENDIENTE',
                    style: TextStyle(
                        color:
                            hasPaid ? Colors.green : AppConstants.brandOrange,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          subtitle: Text(reg['ticket_type'] ?? 'Sin tipo',
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
          onTap: () => setState(() => _selectedRegistration = reg),
        );
      },
    );
  }

  Widget _buildDetail() {
    if (_selectedRegistration == null) {
      return const Center(
          child: Text('Selecciona un registro para ver detalles',
              style: TextStyle(color: Colors.white24)));
    }

    final reg = _selectedRegistration!;
    final bool hasPaid = reg['has_paid'] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (MediaQuery.of(context).size.width <= 900)
            TextButton.icon(
              icon:
                  const Icon(Icons.arrow_back, color: AppConstants.brandOrange),
              label: const Text('VOLVER A LA LISTA',
                  style: TextStyle(color: AppConstants.brandOrange)),
              onPressed: () => setState(() => _selectedRegistration = null),
            ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reg['profile_picture_url'] != null &&
                  reg['profile_picture_url'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(reg['profile_picture_url'],
                      width: 150, height: 150, fit: BoxFit.cover),
                )
              else
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(15)),
                  child:
                      const Icon(Icons.person, size: 50, color: Colors.white10),
                ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reg['full_name']?.toUpperCase() ?? 'N/A',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    const SizedBox(height: 8),
                    Text(reg['email'] ?? 'N/A',
                        style: const TextStyle(
                            color: AppConstants.brandOrange, fontSize: 18)),
                    const SizedBox(height: 20),
                    _detailItem('ENTRADA', reg['ticket_type']),
                    _detailItem('TALLA', reg['tshirt_size']),
                    _detailItem('TELEFONO', reg['phone_number']),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white10),
          const SizedBox(height: 40),
          _detailItem('RESTRICCIONES ALIMENTICIAS',
              reg['dietary_restrictions'] ?? 'Ninguna'),
          const SizedBox(height: 20),
          _detailItem('SUGERENCIAS', reg['suggestions'] ?? 'Ninguna'),
          const SizedBox(height: 60),
          Card(
            color: hasPaid ? Colors.green.withOpacity(0.1) : Colors.white10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  Icon(hasPaid ? Icons.verified : Icons.warning_amber_rounded,
                      color: hasPaid ? Colors.green : AppConstants.brandOrange,
                      size: 40),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(hasPaid ? 'PAGO CONFIRMADO' : 'PAGO PENDIENTE',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text(
                            'Marca a este usuario como pagado una vez verificado el cargo.',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 14)),
                      ],
                    ),
                  ),
                  Switch(
                    value: hasPaid,
                    onChanged: (val) =>
                        _togglePaymentStatus(reg['id'].toString(), hasPaid),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(value ?? 'N/A',
              style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    );
  }
}
