import 'package:flutter/material.dart';
import 'inventory_panti_stokmasuk.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STOK KELUAR MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class StokKeluarScreen extends StatelessWidget {
  final int? userId;
  final int? pantiId;

  const StokKeluarScreen({super.key, this.userId, this.pantiId});

  @override
  Widget build(BuildContext context) => StokDetailScreen(
        title: 'Stok Keluar',
        userId: userId,
        pantiId: pantiId,
        isKeluar: true,
      );
}
