import 'package:image_picker/image_picker.dart';
import 'package:receipt_recognition/receipt_recognition.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptData {
  final String? storeName;
  final String? total;
  final List<String> items;
  final bool isValid;
  final bool isConfirmed;

  ReceiptData({
    required this.storeName,
    required this.total,
    required this.items,
    required this.isValid,
    required this.isConfirmed,
  });
}

class ReceiptScannerService {
  static late ReceiptRecognizer _recognizer;
  static final ImagePicker _picker = ImagePicker();
  static bool _isInitialized = false;

  /// Initialize the receipt recognizer with default settings
  static void initialize() {
    if (_isInitialized) return;

    _recognizer = ReceiptRecognizer(
      options: ReceiptOptions.fromLayeredJson({
        "extend": {
          "storeNames": {
            "JOLLIBEE": "Jollibee",
            "SM MARKET": "SM",
            "PUREGOLD": "Puregold",
            "7-ELEVEN": "7-Eleven",
            "PRINCE": "Prince Hypermart",
          },
          "totalLabels": {
            "TOTAL": "Total",
            "TOTAL DUE": "Total",
            "AMOUNT DUE": "Amount Due",
            "AMT DUE": "Amount Due",
            "GRAND TOTAL": "Total",
            "CASH": "Cash"
          }
        }
      }),
      onScanComplete: (receipt) {
        print("Scan complete: ${receipt.total?.formattedValue}");
      },
    );
    _isInitialized = true;
  }

  /// Scan an image from the specified source and return receipt data
  static Future<ReceiptData?> scanImage(ImageSource source) async {
    if (!_isInitialized) initialize();

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);
      textRecognizer.close();

      // Get first meaningful line as store name
      String? rawStoreName;
      for (final block in recognizedText.blocks) {
        final line = block.text.trim();
        if (line.isNotEmpty && line.length > 2) {
          rawStoreName = line;
          break;
        }
      }

      final snapshot = await _recognizer.processImage(inputImage);

      // Extract items
      List<String> items = [];
      if (snapshot.positions.isNotEmpty) {
        items = snapshot.positions
            .map((pos) => "${pos.product.formattedValue} - ${pos.price.formattedValue}")
            .toList();
      }

      final storeName = (snapshot.store?.value != null && snapshot.store!.value.length > 3)
        ? snapshot.store!.value
        : rawStoreName;

      return ReceiptData(
        storeName: storeName,
        total: snapshot.total?.formattedValue,
        items: items,
        isValid: snapshot.isValid,
        isConfirmed: snapshot.isConfirmed,
      );
    } catch (e) {
      print("Error scanning receipt: $e");
      return null;
    }
  }

  /// Clean up resources
  static void dispose() {
    if (_isInitialized) {
      _recognizer.close();
      _isInitialized = false;
    }
  }
}
