import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from calculator screen
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final recipe = args['recipe'];
    // final nutrients = args['nutrients'] as List;
    final volume = args['volume'] as double;
    final concentration = args['concentration'] as double;
    // final targetPPM = args['target_ppm'] as Map<String, double>;
    // final resultPPM = args['result_ppm'] as Map<String, double>;
    // final fertilizerAmounts =
    //     args['fertilizer_amounts'] as List<Map<String, dynamic>>;
    // final totalCost = args['total_cost'] as double;
    // final ecEstimate = args['ec_estimate'] as double;
    final apiResponse = args['api_response'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hasil Perhitungan'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.mainText,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Recipe Info Card
              _buildRecipeInfoCard(recipe, volume, concentration),
              const SizedBox(height: 16),

              // Substances/Fertilizer Requirements Card
              _buildSubstancesCard(apiResponse),
              const SizedBox(height: 16),

              // Elements Analysis Card
              _buildElementsAnalysisCard(apiResponse),
              const SizedBox(height: 16),

              // Summary Card (Cost, EC, etc.)
              _buildSummaryCard(apiResponse),
              const SizedBox(height: 16),

              // Instructions Card
              _buildInstructionsCard(volume, concentration),
              const SizedBox(height: 24),

              // Action buttons
              // _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeInfoCard(
    dynamic recipe,
    double volume,
    double concentration,
  ) {
    return Card(
      elevation: 2,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.science,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informasi Perhitungan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Resep', recipe?.name ?? 'Unknown'),
            _buildInfoRow('Volume', '${volume.toStringAsFixed(1)} Liter'),
            _buildInfoRow(
              'Konsentrasi',
              '${concentration.toStringAsFixed(0)}x',
            ),
            _buildInfoRow(
              'Status',
              'Perhitungan Selesai',
              valueColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubstancesCard(Map<String, dynamic>? apiResponse) {
    if (apiResponse == null || apiResponse['data'] == null) {
      return const SizedBox.shrink();
    }

    final data = apiResponse['data'];
    final substances = List<Map<String, dynamic>>.from(
      data['substances'] ?? [],
    );

    return Card(
      elevation: 2,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Kebutuhan Pupuk',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Pupuk',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Formula',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Massa (g)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  // Expanded(
                  //   child: Text(
                  //     'Biaya',
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 12,
                  //     ),
                  //     textAlign: TextAlign.right,
                  //   ),
                  // ),
                ],
              ),
            ),

            // Substance rows
            ...substances.map((substance) => _buildSubstanceRow(substance)),

            const Divider(height: 16),

            // Total row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'TOTAL',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // const Expanded(flex: 2, child: SizedBox()),
                  Expanded(
                    // flex: 1,
                    child: Text(
                      _getTotalMass(substances).toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  // Expanded(
                  //   flex: 3,
                  //   child: Text(
                  //     'Rp. ${_getTotalCost(substances).toStringAsFixed(0)}',
                  //     style: GoogleFonts.poppins(
                  //       fontWeight: FontWeight.w400,
                  //       fontSize: 12,
                  //     ),
                  //     textAlign: TextAlign.right,
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubstanceRow(Map<String, dynamic> substance) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outline.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              substance['substance_name'] ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              substance['formula'] ?? '',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              (substance['amount_g'] ?? 0.0).toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          // Expanded(
          //   child: Text(
          //     'Rp ${(substance['preparation_cost'] ?? 0.0).toStringAsFixed(0)}',
          //     style: const TextStyle(fontSize: 13, color: AppColors.primary),
          //     textAlign: TextAlign.right,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildElementsAnalysisCard(Map<String, dynamic>? apiResponse) {
    if (apiResponse == null || apiResponse['data'] == null) {
      return const SizedBox.shrink();
    }

    final data = apiResponse['data'];
    final elements = List<Map<String, dynamic>>.from(data['elements'] ?? []);

    return Card(
      elevation: 2,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analisis Unsur Hara',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Header row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Element',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Result PPM',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'GE',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Element rows
            ...elements
            // .where(
            //   (element) =>
            //       // element['result_ppm'] != null &&
            //       // element['result_ppm'] > 0,
            // // )
            .map((element) => _buildElementRow(element)),
          ],
        ),
      ),
    );
  }

  Widget _buildElementRow(Map<String, dynamic> element) {
    final resultPpm = (element['result_ppm'] ?? 0.0).toDouble();
    final grossError = element['ge']?.toString() ?? '0%';
    // final instrumentalError = element['ie']?.toString() ?? '0%';

    // Color coding based on gross error
    Color errorColor = AppColors.primary;
    if (grossError.contains('-')) {
      errorColor = Colors.red;
    } else if (grossError != '0%' && !grossError.contains('0.')) {
      errorColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.outline.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              element['element'] ?? 'Unknown',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              resultPpm.toStringAsFixed(2),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                grossError,
                style: TextStyle(
                  fontSize: 11,
                  color: errorColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic>? apiResponse) {
    if (apiResponse == null || apiResponse['data'] == null) {
      return const SizedBox.shrink();
    }

    final data = apiResponse['data'];
    final totalCost = (data['total_cost'] ?? 0.0).toDouble();
    final predictedEC = (data['predicted_ec'] ?? 0.0).toDouble();
    final volumeLiters = (data['volume_liters'] ?? 0.0).toDouble();

    return Card(
      elevation: 2,
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.summarize,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ringkasan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.account_balance_wallet,
                    title: 'Total Biaya',
                    value: 'Rp ${totalCost.toStringAsFixed(0)}',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.electrical_services,
                    title: 'Predicted EC',
                    value: '${predictedEC.toStringAsFixed(3)} mS/cm',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildSummaryItem(
              icon: Icons.water_drop,
              title: 'Volume Larutan',
              value: '${volumeLiters.toStringAsFixed(1)} Liter',
              color: Colors.cyan,
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child:
          fullWidth
              ? Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: AppColors.lightText),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildInstructionsCard(double volume, double cf) {
    final amountMix = 1000 / cf;
    return Card(
      elevation: 2,
      color: AppColors.primaryLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Instruksi Penggunaan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Catatan Penting:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jangan pernah mencampur larutan A dan B secara langsung, Selalu tambahkan pupuk ke dalam air, bukan sebaliknya, Gunakan sarung tangan dan masker saat menimbang pupuk Simpan di tempat sejuk dan kering',
                    // 'Perhitungan ini menggunakan Laravel implementation dengan optimizer yang telah ditingkatkan untuk mencocokkan perilaku Python fallback.',
                    style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              '📝 Langkah Penggunaan:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.mainText,
              ),
            ),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  [
                    '1. Timbang semua pupuk sesuai dengan massa yang tertera di atas',
                    '2. Larutkan dalam air bersih dengan ${amountMix.toStringAsFixed(1)} liter',
                    '3. Aduk hingga semua pupuk larut sempurna',
                    '4. Periksa pH larutan dan sesuaikan jika diperlukan (pH ideal: 5.5-6.5)',
                    '5. Periksa EC menggunakan EC meter untuk memastikan konsentrasi yang tepat',
                  ].length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        [
                          'Timbang semua pupuk sesuai dengan massa yang tertera di tabel',
                          'Siapkan wadah terpisah untuk larutan A dan larutan B',
                          'Gunakan ${amountMix} mL larutan A dan B untuk setiap 1 liter air bersih',
                          'Simpan larutan stok A dan B dalam wadah tertutup dan beri label yang jelas',
                          'Periksa pH larutan akhir dan sesuaikan jika diperlukan (pH ideal: 5.5-6.5)',
                          'Periksa EC menggunakan EC meter untuk memastikan konsentrasi yang tepat',
                        ][index],
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.lightText,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.mainText,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _getTotalMass(List<Map<String, dynamic>> substances) {
    return substances.fold(
      0.0,
      (sum, substance) => sum + (substance['amount_g'] ?? 0.0).toDouble(),
    );
  }
}
