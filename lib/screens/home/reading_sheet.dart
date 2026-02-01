import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/services/calculation_service.dart';
import 'package:finalproject/utils/reading_utils.dart';

// ============= ADD READING SHEET =============
class AddReadingSheet extends StatefulWidget {
  final String month;
  const AddReadingSheet({super.key, required this.month});

  @override
  State<AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<AddReadingSheet> {
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();

  bool _isListeningOld = false;
  bool _isListeningNew = false;
  bool _isProcessingImageOld = false;
  bool _isProcessingImageNew = false;

  @override
  void initState() {
    super.initState();
    final readingsBox = Hive.box('readingsBox');
    final oldReading = readingsBox.get(widget.month);
    if (oldReading != null) {
      _oldController.text = oldReading.toString();
    }
  }

  // Voice Recognition
  void _listen(TextEditingController controller, bool isOld) {
    ReadingUtils.listen(
      controller: controller,
      isListening: isOld ? _isListeningOld : _isListeningNew,
      onStateChange: (v) {
        setState(() {
          if (isOld) {
            _isListeningOld = v;
          } else {
            _isListeningNew = v;
          }
        });
      },
    );
  }

  // OCR - Extract numbers from image
  Future<void> _extractNumbersFromImage(
    TextEditingController controller,
    bool isOld,
  ) {
    return ReadingUtils.extractNumbersFromImage(
      context: context,
      controller: controller,
      onProcessingChange: (v) {
        setState(() {
          if (isOld) {
            _isProcessingImageOld = v;
          } else {
            _isProcessingImageNew = v;
          }
        });
      },
    );
  }

  void _saveReading() {
    final oldReading = int.tryParse(_oldController.text);
    final newReading = int.tryParse(_newController.text);

    if (oldReading == null || newReading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid readings')),
      );
      return;
    }

    if (newReading < oldReading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New reading must be greater than old reading'),
        ),
      );
      return;
    }

    final consumption = newReading - oldReading;
    final bill = BillCalculator.calculateBill(consumption);
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final readingsBox = Hive.box('readingsBox');
    final historyBox = Hive.box('historyBox');

    if (readingsBox.get(widget.month) == null) {
      readingsBox.put(widget.month, oldReading);
    }

    final history = historyBox.get(widget.month, defaultValue: []);
    final List<Map<String, dynamic>> updatedHistory =
        List<Map<String, dynamic>>.from(
          history is List
              ? history.map((e) => Map<String, dynamic>.from(e as Map))
              : [],
        );

    updatedHistory.add({
      'oldReading': oldReading,
      'newReading': newReading,
      'consumption': consumption,
      'bill': bill,
      'date': date,
    });

    historyBox.put(widget.month, updatedHistory);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reading saved! Bill: EGP ${bill.toString()}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Reading for ${widget.month}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Old Reading Field
            TextField(
              controller: _oldController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Old Reading (Start of Month)',
                hintText: 'Enter old reading',
                prefixIcon: const Icon(Icons.history),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isListeningOld ? Icons.mic : Icons.mic_none,
                        color: _isListeningOld ? Colors.red : null,
                      ),
                      onPressed: () => _listen(_oldController, true),
                    ),
                    IconButton(
                      icon: _isProcessingImageOld
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                      onPressed: _isProcessingImageOld
                          ? null
                          : () =>
                                _extractNumbersFromImage(_oldController, true),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),

            // New Reading Field
            TextField(
              controller: _newController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'New Reading (End of Month)',
                hintText: 'Enter new reading',
                prefixIcon: const Icon(Icons.electric_meter),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isListeningNew ? Icons.mic : Icons.mic_none,
                        color: _isListeningNew ? Colors.red : null,
                      ),
                      onPressed: () => _listen(_newController, false),
                    ),
                    IconButton(
                      icon: _isProcessingImageNew
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                      onPressed: _isProcessingImageNew
                          ? null
                          : () =>
                                _extractNumbersFromImage(_newController, false),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveReading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Calculate & Save',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
