import 'package:flutter/material.dart';

import '../models/reclamation.dart';
import '../services/reclamation_service.dart';


class ReclamationsScreen extends StatefulWidget {
  static const routeName = '/reclamations';

  @override
  _ReclamationsScreenState createState() => _ReclamationsScreenState();
}

class _ReclamationsScreenState extends State<ReclamationsScreen> {
  final ReclamationService _reclamationService = ReclamationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Réclamations'),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder<List<Reclamation>>(
        stream: _reclamationService.getReclamations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Aucune réclamation disponible'),
            );
          }

          List<Reclamation> reclamations = snapshot.data!;

          return ListView.builder(
            itemCount: reclamations.length,
            itemBuilder: (ctx, index) {
              final reclamation = reclamations[index];
              return ReclamationItem(
                reclamation: reclamation,
                onUpdate: () => _updateReclamation(reclamation),
                onAddComment: (comment) => _addComment(reclamation.id, comment),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[700],
        child: Icon(Icons.add),
        onPressed: _addReclamation,
      ),
    );
  }

  void _addReclamation() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ReclamationFormScreen(
          onSave: (Reclamation reclamation) async {
            await _reclamationService.ajouterReclamation(reclamation);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Réclamation ajoutée avec succès')),
            );
          },
        ),
      ),
    );
  }

  void _updateReclamation(Reclamation reclamation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ReclamationFormScreen(
          reclamation: reclamation,
          onSave: (Reclamation updatedReclamation) async {
            await _reclamationService.mettreAJourReclamation(updatedReclamation);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Réclamation mise à jour avec succès')),
            );
          },
        ),
      ),
    );
  }

  void _addComment(String id, String comment) {
    _reclamationService.ajouterCommentaire(id, comment);
  }
}

class ReclamationItem extends StatelessWidget {
  final Reclamation reclamation;
  final VoidCallback onUpdate;
  final Function(String) onAddComment;

  const ReclamationItem({
    Key? key,
    required this.reclamation,
    required this.onUpdate,
    required this.onAddComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reclamation.clientName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              reclamation.clientEmail,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              reclamation.description,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Statut: ${reclamation.statut}',
              style: TextStyle(
                color: reclamation.statut == 'Résolu' ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Commentaires:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            ...reclamation.commentaires.map((comment) {
              return Text(
                '- $comment',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              );
            }).toList(),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Modifier'),
                  onPressed: onUpdate,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[700],
                  ),
                ),
                SizedBox(width: 8),
                TextButton.icon(
                  icon: Icon(Icons.comment, size: 16),
                  label: Text('Ajouter un commentaire'),
                  onPressed: () {
                    final commentController = TextEditingController();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Ajouter un commentaire'),
                        content: TextField(
                          controller: commentController,
                          decoration: InputDecoration(labelText: 'Commentaire'),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Annuler'),
                            onPressed: () => Navigator.of(ctx).pop(),
                          ),
                          TextButton(
                            child: Text('Ajouter'),
                            onPressed: () {
                              if (commentController.text.isNotEmpty) {
                                onAddComment(commentController.text);
                                Navigator.of(ctx).pop();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReclamationFormScreen extends StatefulWidget {
  final Reclamation? reclamation;
  final Function(Reclamation) onSave;

  const ReclamationFormScreen({
    Key? key,
    this.reclamation,
    required this.onSave,
  }) : super(key: key);

  @override
  _ReclamationFormScreenState createState() => _ReclamationFormScreenState();
}

class _ReclamationFormScreenState extends State<ReclamationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _statut = 'Ouvert';

  @override
  void initState() {
    super.initState();
    if (widget.reclamation != null) {
      final r = widget.reclamation!;
      _clientNameController.text = r.clientName;
      _clientEmailController.text = r.clientEmail;
      _descriptionController.text = r.description;
      _statut = r.statut;
    }
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveReclamation() {
    if (_formKey.currentState!.validate()) {
      final reclamation = Reclamation(
        id: widget.reclamation?.id ?? '',
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        description: _descriptionController.text,
        statut: _statut,
        commentaires: widget.reclamation?.commentaires ?? [],
      );

      widget.onSave(reclamation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reclamation != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Center(
              child: Text(
                isEditing ? 'Modifier la réclamation' : 'Ajouter une nouvelle réclamation',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _clientNameController,
              decoration: InputDecoration(
                labelText: 'Nom du client',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du client';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _clientEmailController,
              decoration: InputDecoration(
                labelText: 'Email du client',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer l\'email du client';
                }
                if (!value.contains('@')) {
                  return 'Veuillez entrer un email valide';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer la description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _statut,
              decoration: InputDecoration(
                labelText: 'Statut',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ['Ouvert', 'En cours', 'Résolu'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _statut = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReclamation,
              child: Text(isEditing ? 'Mettre à jour' : 'Ajouter'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}