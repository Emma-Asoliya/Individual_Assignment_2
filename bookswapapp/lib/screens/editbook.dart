import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class EditBookScreen extends StatefulWidget {
  final String bookId;
  final Map<String, dynamic> bookData;

  const EditBookScreen({
    super.key,
    required this.bookId,
    required this.bookData,
  });

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _selectedCondition = 'Like New';
  String _selectedPriceType = 'free';
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];

  final List<String> _priceTypes = [
    'free',
    'swap',
    'price',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with existing data
    _titleController.text = widget.bookData['title'] ?? '';
    _authorController.text = widget.bookData['author'] ?? '';
    _subjectController.text = widget.bookData['subject'] ?? '';
    _descriptionController.text = widget.bookData['description'] ?? '';
    _selectedCondition = widget.bookData['condition'] ?? 'Like New';
    _selectedPriceType = widget.bookData['priceType'] ?? 'free';
    
    if (widget.bookData['priceType'] == 'price') {
      _priceController.text = widget.bookData['price']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Book'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _saveChanges,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Image
                    _buildImageSection(),
                    SizedBox(height: 24),

                    // Book Title
                    _buildTextField(
                      controller: _titleController,
                      label: 'Book Title *',
                      hintText: 'Enter book title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter book title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Author
                    _buildTextField(
                      controller: _authorController,
                      label: 'Author *',
                      hintText: 'Enter author name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter author name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Subject
                    _buildTextField(
                      controller: _subjectController,
                      label: 'Subject/Field *',
                      hintText: 'e.g., Computer Science, Mathematics, Literature',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter subject';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Description
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hintText: 'Describe the book condition, edition, or any details...',
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),

                    // Condition
                    _buildDropdown(
                      label: 'Condition *',
                      value: _selectedCondition,
                      items: _conditions,
                      onChanged: (value) {
                        setState(() {
                          _selectedCondition = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16),

                    // Price Type
                    _buildPriceTypeSection(),
                    SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Cover Image',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade50,
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : widget.bookData['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(widget.bookData['imageUrl']!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 40, color: Colors.grey.shade400),
                          SizedBox(height: 8),
                          Text(
                            'Tap to change book cover',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing *',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        // Price Type Selection
        Wrap(
          spacing: 8,
          children: _priceTypes.map((type) {
            final isSelected = _selectedPriceType == type;
            return ChoiceChip(
              label: Text(
                type == 'free' ? 'Free' : type == 'swap' ? 'Swap' : 'Set Price',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedPriceType = type;
                  if (type != 'price') {
                    _priceController.clear();
                  }
                });
              },
              selectedColor: Colors.red,
              backgroundColor: Colors.grey.shade200,
            );
          }).toList(),
        ),
        SizedBox(height: 12),
        // Price Input (only shown when price type is 'price')
        if (_selectedPriceType == 'price')
          _buildTextField(
            controller: _priceController,
            label: 'Price (\$) *',
            hintText: 'Enter price',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (_selectedPriceType == 'price' && (value == null || value.isEmpty)) {
                return 'Please enter price';
              }
              if (value != null && value.isNotEmpty) {
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
              }
              return null;
            },
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: SizedBox(),
            onChanged: onChanged,
            items: items.map((String condition) {
              return DropdownMenuItem<String>(
                value: condition,
                child: Text(condition),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Upload new image if selected
        String? imageUrl = widget.bookData['imageUrl'];
        if (_selectedImage != null) {
          imageUrl = await _uploadImage(_selectedImage!);
        }

        // Generate search keywords
        final searchKeywords = _generateSearchKeywords(
          _titleController.text,
          _authorController.text,
          _subjectController.text,
        );

        // Update book in Firestore
        await _firestore.collection('books').doc(widget.bookId).update({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'subject': _subjectController.text.trim(),
          'description': _descriptionController.text.trim(),
          'condition': _selectedCondition,
          'priceType': _selectedPriceType,
          'price': _selectedPriceType == 'price' ? double.parse(_priceController.text) : null,
          'imageUrl': imageUrl,
          'searchKeywords': searchKeywords,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Show success message and return to previous page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Book updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final fileName = 'book_${DateTime.now().millisecondsSinceEpoch}_${user.uid}';
      final ref = FirebaseStorage.instance.ref().child('book_covers/$fileName');
      
      final uploadTask = await ref.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  List<String> _generateSearchKeywords(String title, String author, String subject) {
    final keywords = <String>[];
    
    // Add individual words from title, author, and subject
    keywords.addAll(title.toLowerCase().split(' '));
    keywords.addAll(author.toLowerCase().split(' '));
    keywords.addAll(subject.toLowerCase().split(' '));
    
    // Remove empty strings and duplicates
    return keywords.where((word) => word.length > 2).toSet().toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}