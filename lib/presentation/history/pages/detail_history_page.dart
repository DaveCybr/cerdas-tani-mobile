import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/constans/colors.dart';
import 'package:flutter/material.dart';

class DetailHistoryPage extends StatefulWidget {
  final List<dynamic> requiredFertilizers;
  final String name;
  final String liter;
  final String konsentrasi;
  const DetailHistoryPage({
    super.key,
    required this.requiredFertilizers,
    required this.name,
    required this.liter,
    required this.konsentrasi,
  });

  @override
  State<DetailHistoryPage> createState() => _DetailHistoryPageState();
}

class _DetailHistoryPageState extends State<DetailHistoryPage> {
  List<Map<String, dynamic>> fertilizers = [];

  @override
  void initState() {
    super.initState();
    // fetchFertilizers();
  }

  // Future<void> fetchFertilizers() async {
  //   final data =
  //       await ResultDatabase().getFertilizersByHistoryId(widget.historyId);
  //   setState(() {
  //     fertilizers = data;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center, // Tambahan opsional
                    ),
                  ),
                  const SpaceHeight(15),
                  Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.card
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Volume : ${widget.liter} Liter',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Konsentrasi : ${widget.konsentrasi}%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SpaceHeight(20),
                  Table(
                    border: TableBorder.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.card),
                    columnWidths: const {
                      0: FlexColumnWidth(2), // Pupuk
                      1: FlexColumnWidth(1), // Tipe
                      2: FlexColumnWidth(2), // Berat
                      3: FlexColumnWidth(2), // Biaya
                    },
                    children: [
                      // Header
                      const TableRow(
                        decoration: BoxDecoration(color: AppColors.green),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'Pupuk',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'Tipe',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                              'Berat\n(grams)',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.all(2.0),
                          //   child: Text(
                          //     'Biaya\n(Rp)',
                          //     style: TextStyle(color: Colors.white),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // ),
                        ],
                      ),
                      // Data Rows
                      ...widget.requiredFertilizers.map(
                        (fertilizer) => TableRow(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.card
                                    : Colors.white,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                fertilizer['Fertilizer'],
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                fertilizer['Type'],
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(
                                fertilizer['Weight (grams)'].toString(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(5.0),
                            //   child: Text(
                            //     fertilizer['price'].toString(),
                            //     textAlign: TextAlign.center,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SpaceHeight(10),
                  // Container(
                  //   decoration: BoxDecoration(
                  //       color: Theme.of(context).brightness == Brightness.dark
                  //           ? AppColors.card
                  //           : Colors.white),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Column(
                  //       children: [
                  //         const Text(
                  //           'NOTE:',
                  //           style: TextStyle(fontWeight: FontWeight.bold),
                  //         ),
                  //         const Text(
                  //             '- Total weight of fertilizer = 200.98 grams'),
                  //         const Text(
                  //             '- Weight of type A fertilizer = 82.27 grams'),
                  //         const Text(
                  //             '- Weight of type B fertilizer = 118.71 grams'),
                  //         const Text(
                  //             '- Total cost of fertilizer = Rp. 4517.43\n- Cost of type A fertilizer = Rp. 1323.00\n- Cost of type B fertilizer = Rp. 3194.43'),
                  //         const SizedBox(height: 16),
                  //         Center(
                  //           child: Container(
                  //             padding: const EdgeInsets.all(8.0),
                  //             decoration: BoxDecoration(
                  //               color: Colors.orange,
                  //               borderRadius: BorderRadius.circular(8.0),
                  //             ),
                  //             child: const Text(
                  //               'EC Value = 1.6 mS/cm (Hanna)',
                  //               style: TextStyle(
                  //                   fontSize: 16, color: Colors.white),
                  //             ),
                  //           ),
                  //         ),
                  //         const SizedBox(height: 16),
                  //         const Text(
                  //           '* Klik tombol di atas, untuk mengubah metode EC.\n* Untuk mendapatkan nilai EC yang lebih tinggi, naikkan nilai konsentrasinya.',
                  //           style: TextStyle(fontSize: 12),
                  //         ),
                  //         const SizedBox(height: 16),
                  //         Center(
                  //           child: TextButton(
                  //             onPressed: () {},
                  //             child: const Text(
                  //               'Tabel Tanaman, PH, EC\nKlik Disini, Cara Mencampur >>',
                  //               textAlign: TextAlign.center,
                  //               style: TextStyle(color: Colors.orange),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
