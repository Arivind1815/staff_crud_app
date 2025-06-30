import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/firestore_service.dart';

class AddStaffPage extends StatefulWidget {
  final Staff? staffToEdit;
  const AddStaffPage({super.key, this.staffToEdit});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.staffToEdit != null) {
      _idController.text = widget.staffToEdit!.id;
      _nameController.text = widget.staffToEdit!.name;
      _ageController.text = widget.staffToEdit!.age.toString();
    }
  }

  void _saveStaff() async {
    if (_formKey.currentState!.validate()) {
      if (widget.staffToEdit == null) {
        final isDuplicate = await _service.isDuplicateId(_idController.text.trim());
        if (isDuplicate) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Staff ID already exists')),
          );
          return;
        }
      }

      final staff = Staff(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        docId: widget.staffToEdit?.docId,
      );

      widget.staffToEdit == null
          ? await _service.addStaff(staff)
          : await _service.updateStaff(staff);

      if (context.mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.staffToEdit == null ? 'Staff added' : 'Staff updated')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.staffToEdit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Staff' : 'Add Staff')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'Staff ID', prefixIcon: Icon(Icons.badge)),
              validator: (v) => v!.isEmpty ? 'Please enter ID' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
              validator: (v) {
                if (v!.isEmpty) return 'Please enter name';
                if (v.length < 3) return 'Name must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.calendar_today)),
              keyboardType: TextInputType.number,
              validator: (v) {
                final age = int.tryParse(v ?? '');
                if (v!.isEmpty) return 'Please enter age';
                if (age == null || age < 18 || age > 65) return 'Age must be between 18–65';
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: Text(isEditing ? 'Update Staff' : 'Save Staff'),
              onPressed: _saveStaff,
            ),
          ]),
        ),
      ),
    );
  }
}
