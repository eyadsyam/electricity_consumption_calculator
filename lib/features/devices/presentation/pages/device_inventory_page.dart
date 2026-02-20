import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/features/devices/presentation/cubit/device_cubit.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'add_device_page.dart';
import 'package:animate_do/animate_do.dart';

class DeviceInventoryPage extends StatelessWidget {
  const DeviceInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      appBar: AppBar(
        title: Text(
          "أجهزتي الكهربائية",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            Colors.transparent, // Transparent for gradient bg effect if needed
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.electricBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.electricBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDevicePage()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<DeviceCubit, DeviceState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.electricBlue),
              );
            }

            if (state.error != null) {
              return Center(
                child: Text(
                  "حدث خطأ: ${state.error}",
                  style: GoogleFonts.cairo(color: AppColors.error),
                ),
              );
            }

            if (state.devices.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                final device = state.devices[index];
                return FadeInLeft(
                  delay: Duration(milliseconds: index * 100),
                  child: _buildDeviceCard(context, device),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: AppColors.electricBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "لا توجد أجهزة مسجلة",
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "أضف أجهزتك لمتابعة استهلاكها",
            style: GoogleFonts.cairo(color: Colors.white30, fontSize: 14),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddDevicePage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
            icon: const Icon(Icons.add),
            label: Text(
              "إضافة جهاز جديد",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, UserDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _getIcon(device.iconName),
              color: AppColors.electricBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${device.powerWatts.toInt()} وات",
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _translateCategory(device.category),
                      style: GoogleFonts.cairo(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () {
              // Show confirmation dialog before delete
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.deepSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  title: Text(
                    "حذف الجهاز؟",
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  content: Text(
                    "هل أنت متأكد من حذف ${device.deviceName}؟",
                    style: GoogleFonts.cairo(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        "إلغاء",
                        style: GoogleFonts.cairo(color: Colors.white54),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<DeviceCubit>().removeDevice(device);
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "تم حذف الجهاز",
                              style: GoogleFonts.cairo(),
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      },
                      child: Text(
                        "حذف",
                        style: GoogleFonts.cairo(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _translateCategory(String category) {
    if (category.toLowerCase().contains('kitchen')) return 'مطبخ';
    if (category.toLowerCase().contains('living')) return 'معيشة';
    if (category.toLowerCase().contains('bed')) return 'غرفة نوم';
    if (category.toLowerCase().contains('office')) return 'مكتب';
    return category;
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'tv':
        return Icons.tv;
      case 'kitchen':
        return Icons.kitchen;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'microwave':
        return Icons.microwave;
      case 'laptop':
        return Icons.laptop;
      case 'wind_power':
        return Icons.wind_power;
      case 'wash':
        return Icons.local_laundry_service;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'iron':
        return Icons.iron;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.electrical_services;
    }
  }
}
