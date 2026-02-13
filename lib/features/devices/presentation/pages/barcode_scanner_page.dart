import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/features/devices/data/product_api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final ProductApiService _apiService = ProductApiService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "مسح باركود الجهاز",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgBlack,
        iconTheme: const IconThemeData(color: AppColors.royalGold),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              facing: CameraFacing.back,
            ),
            onDetect: (capture) async {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes; // Corrected type
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                if (barcode.rawValue != null) {
                  setState(() => _isProcessing = true);
                  // Fetch product
                  final product = await _apiService.fetchProductByBarcode(
                    barcode.rawValue!,
                  );
                  if (!mounted) return;
                  Navigator.pop(context, product);
                }
              }
            },
          ),

          // Scanning Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.royalGold, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          if (_isProcessing)
            const Center(
              child: CircularProgressIndicator(color: AppColors.royalGold),
            ),

          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "ضع الباركود داخل الإطار",
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
