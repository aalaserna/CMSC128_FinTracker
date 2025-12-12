import 'package:flutter/material.dart';
import 'homepage.dart';

class CustomizationPage extends StatefulWidget {
  const CustomizationPage({super.key});

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  // State variables for customization options
  String _budgetAmount = ''; // Budget text input
  String _selectedBudgetFrequency = 'Weekly'; 
  String _selectedReminderFrequency = 'Daily';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0); // Default to 8:00 PM

  // Lists for dropdown options
  final List<String> _budgetFrequencies = ['Weekly', 'Monthly'];
  final List<String> _reminderFrequencies = ['Daily', 'Weekly', 'Monthly'];

  // Text controller for the budget input field
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  // Function to show the time picker dialog
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function called when the Done button is pressed
  void _saveCustomizations() {
    _budgetAmount = _budgetController.text;

    if (_budgetAmount.isNotEmpty) {
      double? newBudget = double.tryParse(_budgetAmount);
      if (newBudget != null) {
        HomePage.userBudget = newBudget;
      }
    }

    HomePage.homePageStateKey.currentState?.setState(() {});
    // 2. Output the current settings (You would replace this with saving logic)
    print('--- Customizations Saved ---');
    print('Budget Amount: \$$_budgetAmount');
    print('Budget Cycle: $_selectedBudgetFrequency');
    print('Reminder Frequency: $_selectedReminderFrequency');
    print('Reminder Time: ${_selectedTime.format(context)}');
    
    // In a real app, you would navigate away or save data to a database here.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customizations saved successfully!')),
    );

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 50),
              // --- Title Section ---
              const Text(
                'Customize your budget and notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // --- 1. Set Your Budget ---
              _buildSectionTitle('Set your budget'),
              _buildBudgetInputField(),
              const SizedBox(height: 20),

              // --- 2. Choose Your Budget Cycle ---
              _buildSectionTitle('Choose your budget cycle'),
              _buildDropdownSelector(
                value: _selectedBudgetFrequency,
                items: _budgetFrequencies,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBudgetFrequency = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // --- 3. Set Your Reminder Frequency ---
              _buildSectionTitle('Set your reminder frequency'),
              _buildReminderRow(context),
              const SizedBox(height: 40),

              // --- 4. Done Button ---
              ElevatedButton(
                onPressed: _saveCustomizations,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50), // Full width button
                  backgroundColor: Colors.blue[900], // Dark color from Figma
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }

  // Helper widget for the budget input field
  Widget _buildBudgetInputField() {
    return TextField(
      controller: _budgetController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Enter your budget here',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  // Helper widget for a generic dropdown selector
  Widget _buildDropdownSelector({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Helper widget for the reminder frequency and time row
  Widget _buildReminderRow(BuildContext context) {
    return Row(
      children: [
        // Dropdown for Frequency (e.g., Daily)
        Expanded(
          flex: 3,
          child: _buildDropdownSelector(
            value: _selectedReminderFrequency,
            items: _reminderFrequencies,
            onChanged: (newValue) {
              setState(() {
                _selectedReminderFrequency = newValue!;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        // Time Button (e.g., 8:00 PM)
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () => _selectTime(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              _selectedTime.format(context),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}