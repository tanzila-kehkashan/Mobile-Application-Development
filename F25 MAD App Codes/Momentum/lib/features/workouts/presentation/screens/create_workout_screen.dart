import 'package:flutter/material.dart';
import 'package:momentum/core/models/models.dart';
import 'package:momentum/core/state/app_state.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedLevel = 'Basic';
  final List<ExerciseModel> _exercises = [];
  bool _isLoading = false;

  final List<String> _levels = ['Basic', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _addExercise() {
    final nameController = TextEditingController();
    final durationController = TextEditingController(text: '60');
    final setsController = TextEditingController();
    final repsController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF4A3D7E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Exercise',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: nameController,
                label: 'Exercise Name',
                hint: 'e.g., Push-ups',
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: durationController,
                label: 'Duration (seconds)',
                hint: '60',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: setsController,
                      label: 'Sets (optional)',
                      hint: '3',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: repsController,
                      label: 'Reps (optional)',
                      hint: '10',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: descriptionController,
                label: 'Description (optional)',
                hint: 'Brief description of the exercise',
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      final exercise = ExerciseModel(
                        id: 'custom_ex_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        durationSeconds: int.tryParse(durationController.text) ?? 60,
                        sets: int.tryParse(setsController.text),
                        reps: int.tryParse(repsController.text),
                        description: descriptionController.text.isNotEmpty
                            ? descriptionController.text
                            : null,
                      );
                      setState(() => _exercises.add(exercise));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8FF78),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Add Exercise',
                    style: TextStyle(
                      color: Color(0xFF201A3F),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF201A3F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
      validator: (value) {
        if (label == 'Workout Title' && (value == null || value.isEmpty)) {
          return 'Please enter a workout title';
        }
        if (label == 'Duration (minutes)' && (value == null || value.isEmpty)) {
          return 'Please enter duration';
        }
        return null;
      },
    );
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final workout = WorkoutModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text,
      duration: '${_durationController.text} min',
      level: _selectedLevel,
      image: 'assets/images/Workout_1.png', // Default image for custom workouts
      exercises: _exercises,
      caloriesPerMinute: _selectedLevel == 'Advanced' ? 8 : (_selectedLevel == 'Intermediate' ? 6 : 4),
    );

    final appState = AppStateProvider.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    await appState.addCustomWorkout(workout);

    setState(() => _isLoading = false);

    if (mounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Custom workout created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201A3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF201A3F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Create Workout', style: TextStyle(color: Colors.white)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Workout Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                label: 'Workout Title',
                hint: 'e.g., Morning Routine',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _durationController,
                label: 'Duration (minutes)',
                hint: '30',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'Difficulty Level',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3D7E),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLevel,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF4A3D7E),
                    style: const TextStyle(color: Colors.white),
                    items: _levels.map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLevel = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Exercises',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addExercise,
                    icon: const Icon(Icons.add, color: Color(0xFFE8FF78)),
                    label: const Text(
                      'Add Exercise',
                      style: TextStyle(color: Color(0xFFE8FF78)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_exercises.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A3D7E),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(Icons.fitness_center, color: Colors.white54, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'No exercises added yet',
                          style: TextStyle(color: Colors.white54),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap "Add Exercise" to get started',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _exercises.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3D7E),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8FF78),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF201A3F),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${exercise.durationSeconds}s${exercise.sets != null ? ' • ${exercise.sets} sets' : ''}${exercise.reps != null ? ' x ${exercise.reps} reps' : ''}',
                                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => _exercises.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveWorkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8FF78),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Create Workout',
                          style: TextStyle(
                            color: Color(0xFF201A3F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
