import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobgenfest/constants.dart';
import 'package:image/image.dart' as img;
import 'package:mobgenfest/registration_success_screen.dart';
import 'package:mobgenfest/legal_screen.dart';

class TicketFormScreen extends StatefulWidget {
  final String initialTicketType;
  final String ticketPrice;

  const TicketFormScreen({
    super.key,
    required this.initialTicketType,
    required this.ticketPrice,
  });

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dietaryController = TextEditingController();
  final _suggestionsController = TextEditingController();

  String _selectedTicketType = '';
  String _selectedTshirtSize = 'M';
  XFile? _profileImage;
  bool _isLoading = false;
  User? _user;
  late final StreamSubscription<AuthState> _authSubscription;
  int _vipCount = 0;
  bool _isCheckingAvailability = true;
  String? _googleImageUrl;
  bool _acceptedTerms = false;

  final List<String> _tshirtSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];
  List<String> _availableTicketTypes = [];

  @override
  void initState() {
    super.initState();
    _selectedTicketType = widget.initialTicketType;
    _user = Supabase.instance.client.auth.currentUser;
    _fillUserInfo();
    _fetchAvailability();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _user = data.session?.user;
          _fillUserInfo();
        });
      }
    });
  }

  Future<void> _fetchAvailability() async {
    try {
      final response = await Supabase.instance.client
          .from('registrations')
          .select('id')
          .eq('ticket_type', 'VIP EXPERIENCE');

      if (mounted) {
        setState(() {
          _vipCount = (response as List).length;
          _updateAvailableTickets();
          _isCheckingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _updateAvailableTickets();
        setState(() => _isCheckingAvailability = false);
      }
    }
  }

  void _updateAvailableTickets() {
    final List<String> types = [];

    // Early Bird check
    if (AppConstants.isEarlyBirdAvailable ||
        widget.initialTicketType == 'EARLY BIRD') {
      types.add('EARLY BIRD');
    }

    types.add('GENERAL PASS');

    // VIP check
    if (_vipCount < AppConstants.vipTicketLimit ||
        widget.initialTicketType == 'VIP EXPERIENCE') {
      types.add('VIP EXPERIENCE');
    }

    _availableTicketTypes = types;

    // Fallback if current selected is not in list (shouldn't happen)
    if (!_availableTicketTypes.contains(_selectedTicketType)) {
      _selectedTicketType = 'GENERAL PASS';
    }
  }

  void _fillUserInfo() {
    if (_user != null) {
      final name = _user!.userMetadata?['full_name'] ??
          _user!.userMetadata?['name'] ??
          '';
      final email = _user!.email ?? '';
      _googleImageUrl =
          _user!.userMetadata?['avatar_url'] ?? _user!.userMetadata?['picture'];

      if (_nameController.text.isEmpty) _nameController.text = name;
      if (_emailController.text.isEmpty) _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dietaryController.dispose();
    _suggestionsController.dispose();
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_profileImage == null && _googleImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Por favor, sube una foto de perfil para completar el registro.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Debes aceptar los terminos y condiciones para continuar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl = _googleImageUrl;

      if (_profileImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        Uint8List bytes = await _profileImage!.readAsBytes();

        // Compression logic
        if (bytes.length > 1024 * 1024) {
          final decodedImage = img.decodeImage(bytes);
          if (decodedImage != null) {
            // Resize if too large
            img.Image resized = decodedImage;
            if (decodedImage.width > 2000 || decodedImage.height > 2000) {
              resized = img.copyResize(decodedImage, width: 1024);
            }
            // Compress
            bytes = Uint8List.fromList(img.encodeJpg(resized, quality: 75));
          }
        }

        await Supabase.instance.client.storage
            .from('profile_pictures')
            .uploadBinary(fileName, bytes);

        imageUrl = Supabase.instance.client.storage
            .from('profile_pictures')
            .getPublicUrl(fileName);
      }

      await Supabase.instance.client.from('registrations').insert({
        'full_name': _nameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'dietary_restrictions': _dietaryController.text,
        'tshirt_size': _selectedTshirtSize,
        'ticket_type': _selectedTicketType,
        'profile_picture_url': imageUrl,
        'suggestions': _suggestionsController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro completado con exito!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const RegistrationSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.mobgenfest://login-callback/',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('REGISTRO DE ENTRADA'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Cerrar Sesion',
            ),
        ],
      ),
      body: _user == null ? _buildLoginView() : _buildFormView(),
    );
  }

  Widget _buildLoginView() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.brandOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline,
                  size: 40, color: AppConstants.brandOrange),
            ),
            const SizedBox(height: 30),
            const Text(
              "AUTENTICACION REQUERIDA",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Para asegurar un registro seguro y simplificar el proceso, por favor inicia sesion con tu cuenta de Google.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, height: 1.5),
            ),
            const SizedBox(height: 40),
            Center(
              child: GestureDetector(
                onTap: _signInWithGoogle,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: SvgPicture.asset(
                    'assets/images/web_light_rd_ctn.svg',
                    height: 50, // Standard button height
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    color: AppConstants.brandOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppConstants.brandOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ENTRADA SELECCIONADA",
                            style: TextStyle(
                              color: AppConstants.brandOrange.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.initialTicketType,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.ticketPrice,
                        style: const TextStyle(
                          color: AppConstants.brandOrange,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lab',
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white10,
                      backgroundImage: _profileImage != null
                          ? (kIsWeb
                              ? NetworkImage(_profileImage!.path)
                              : FileImage(File(_profileImage!.path))
                                  as ImageProvider)
                          : (_googleImageUrl != null
                              ? NetworkImage(_googleImageUrl!)
                              : null),
                      child: _profileImage == null && _googleImageUrl == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.white30)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                    child: Text('Añadir foto de perfil',
                        style: TextStyle(color: Colors.white54))),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Como cada vez somos más, empiezan a bailarnos las caras, por favor, sube una foto tuya donde salgas reconocible",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white38, fontSize: 24, height: 1.4),
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                    'Nombre Completo', _nameController, Icons.person),
                const SizedBox(height: 20),
                _buildTextField('Email', _emailController, Icons.email,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildTextField('Telefono', _phoneController, Icons.phone,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                _buildDropdown(
                    'Talla de camiseta',
                    _selectedTshirtSize,
                    _tshirtSizes,
                    (val) => setState(() => _selectedTshirtSize = val!)),
                const SizedBox(height: 20),
                _buildTextField('Restricciones alimenticias (Opcional)',
                    _dietaryController, Icons.restaurant,
                    maxLines: 3),
                const SizedBox(height: 20),
                _buildTextField('Sugerencias (Opcional)',
                    _suggestionsController, Icons.lightbulb_outline,
                    maxLines: 3),
                const SizedBox(height: 30),
                _buildLegalCheckbox(),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.brandOrange,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _isLoading || _isCheckingAvailability
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('ENVIAR REGISTRO',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18, letterSpacing: 1.2),
        prefixIcon: Icon(icon, color: AppConstants.brandOrange),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppConstants.brandOrange)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red)),
      ),
      validator: (val) => maxLines == 1 && (val == null || val.isEmpty)
          ? 'Field required'
          : null,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1A1A1A),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 18, letterSpacing: 1.2),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white10)),
      ),
    );
  }

  Widget _buildLegalCheckbox() {
    return Theme(
      data: ThemeData(unselectedWidgetColor: Colors.white24),
      child: CheckboxListTile(
        value: _acceptedTerms,
        onChanged: (val) => setState(() => _acceptedTerms = val!),
        title: Wrap(
          children: [
            const Text("I accept the ",
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LegalScreen(showPrivacy: false)),
              ),
              child: const Text("Terms & Conditions",
                  style: TextStyle(
                      color: AppConstants.brandOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ),
            const Text(" and the ",
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const LegalScreen(showPrivacy: true)),
              ),
              child: const Text("Privacy Policy",
                  style: TextStyle(
                      color: AppConstants.brandOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppConstants.brandOrange,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
