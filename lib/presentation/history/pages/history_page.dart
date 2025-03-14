import 'package:fertilizer_calculator/core/components/space.dart';
import 'package:fertilizer_calculator/core/extensions/build_context_ext.dart';
import 'package:fertilizer_calculator/presentation/calculator/provider/calculate_provider.dart';
import 'package:fertilizer_calculator/presentation/history/pages/detail_history_page.dart';
import 'package:fertilizer_calculator/presentation/history/widgets/history_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      'Riwayat Kalkulator',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SpaceHeight(15),
                  FutureBuilder(
                    future:
                        Provider.of<CalculateProvider>(context, listen: false)
                            .getCalculationsByGoogleAccountId(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Consumer<CalculateProvider>(
                          builder: (context, provider, child) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  provider.calculationDataFromFirebase.length,
                              itemBuilder: (context, index) {
                                // Mengakses data dari yang terbaru ke yang terlama
                                final history = provider
                                    .calculationDataFromFirebase.reversed
                                    .toList()[index];

                                return HistoryCard(
                                  action: () {
                                    print(history['result']
                                        ['required_fertilizers']);
                                    // return;
                                    context.push(
                                      DetailHistoryPage(
                                        requiredFertilizers: history['result']
                                            ['required_fertilizers'],
                                        name: history['recipe_name'],
                                        liter: history['volume'].toString(),
                                        konsentrasi:
                                            history['consentration'].toString(),
                                        // totalWeight: history['total_weight'],
                                        // totalPrice: history['total_price'],
                                      ),
                                    );
                                  },
                                  name: history['recipe_name'],
                                  liter: history['volume'].toString(),
                                  konsentrasi:
                                      history['consentration'].toString(),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
