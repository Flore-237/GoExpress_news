import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/models/agenceModel.dart';
import '../data/repositories/agenceRepositorie.dart';


class ImageUploadService {
  Future<String?> uploadImage(XFile file) async {
    // Implementation for uploading the image and returning the URL
    return 'uploaded_image_url'; // Replace with actual upload logic
  }
}

class EditAgencyScreen extends StatefulWidget {
  final String agencyId;

  const EditAgencyScreen({Key? key, required this.agencyId}) : super(key: key);

  @override
  State<EditAgencyScreen> createState() => _EditAgencyScreenState();
}

class _EditAgencyScreenState extends State<EditAgencyScreen> {
  final _formKey = GlobalKey<FormState>();
  late Future<AgencyModel?> _agencyFuture;
  final AgencyRepository _agencyRepo = AgencyRepository();
  final ImageUploadService _imageService = ImageUploadService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();

  List<String> _supportedRoutes = [];
  String? _logoUrl;
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _agencyFuture = _agencyRepo.getAgencyById(widget.agencyId);
    _agencyFuture.then((agency) {
      if (agency != null) {
        _nameController.text = agency.name;
        _descController.text = agency.description;
        _phoneController.text = agency.contactPhone;
        _emailController.text = agency.contactEmail;
        _addressController.text = agency.address;
        _supportedRoutes = List.from(agency.supportedRoutes);
        _logoUrl = agency.logoUrl;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier l\'agence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: FutureBuilder<AgencyModel?>(
        future: _agencyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          return _buildEditForm();
        },
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLogoSection(),
            const SizedBox(height: 24),
            _buildInfoSection(),
            const SizedBox(height: 24),
            _buildRoutesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[200],
            backgroundImage: _selectedImage != null
                ? FileImage(File(_selectedImage!.path)) as ImageProvider
                : (_logoUrl != null ? NetworkImage(_logoUrl!) : null),
            child: _selectedImage == null && _logoUrl == null
                ? const Icon(Icons.add_a_photo, size: 40)
                : null,
          ),
        ),
        TextButton(
          onPressed: _pickImage,
          child: const Text('Changer le logo'),
        ),
        if (_selectedImage != null)
          TextButton(
            onPressed: _removeLogo,
            child: const Text('Supprimer le logo', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      'Informations de l\'agence',
      style: Theme.of(context).textTheme.titleLarge,
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(
    labelText: 'Nom de l\'agence',
    border: OutlineInputBorder(),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer un nom';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _descController,
    decoration: const InputDecoration(
    labelText: 'Description',
    border: OutlineInputBorder(),
    ),
    maxLines: 3,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer une description';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _phoneController,
    decoration: const InputDecoration(
    labelText: 'Téléphone',
    border: OutlineInputBorder(),
    ),
    keyboardType: TextInputType.phone,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Veuillez entrer un numéro de téléphone';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _emailController,
    decoration: const InputDecoration(
    labelText:'Email',
      border: OutlineInputBorder(),
    ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un email';
        }
        if (!value.contains('@')) {
          return 'Email invalide';
        }
        return null;
      },
    ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Adresse',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer une adresse';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoutesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Routes desservies',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _supportedRoutes
              .map((route) => Chip(
            label: Text(route),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => _removeRoute(route),
          ))
              .toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Ajouter une route',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addRoute,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _removeLogo() {
    setState(() {
      _selectedImage = null;
      _logoUrl = null;
    });
  }

  void _addRoute() {
    if (_routeController.text.isNotEmpty) {
      setState(() {
        _supportedRoutes.add(_routeController.text);
        _routeController.clear();
      });
    }
  }

  void _removeRoute(String route) {
    setState(() {
      _supportedRoutes.remove(route);
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload new image if selected
      String? newLogoUrl = _logoUrl;
      if (_selectedImage != null) {
        newLogoUrl = await _imageService.uploadImage(_selectedImage!);
      } else if (_logoUrl != null && _selectedImage == null) {
        // Keep existing logo
      } else {
        // No logo (was removed)
        newLogoUrl = null;
      }

      final updatedAgency = AgencyModel(
        id: widget.agencyId,
        name: _nameController.text,
        logoUrl: newLogoUrl ?? '',
        imageUrl: newLogoUrl ?? '',
        description: _descController.text,
        contactPhone: _phoneController.text,
        contactEmail: _emailController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        supportedRoutes: _supportedRoutes,
        createdAt: DateTime.now(), // Use existing date in production
        updatedAt: DateTime.now(),
      );

      await _agencyRepo.updateAgency(updatedAgency);

      if (mounted) {
        Navigator.pop(context, true); // Return with success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
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
}