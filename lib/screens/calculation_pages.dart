import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../utils/theme.dart';
import '../utils/ad_manager.dart';
import '../widgets/ad_widgets.dart';

class BaseCalcPage extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> fields;
  final String result;
  final String? resultSuffix;
  final String? subResult;
  final VoidCallback onCalculate;
  final VoidCallback onReset;

  const BaseCalcPage({
    super.key,
    required this.title,
    required this.description,
    required this.fields,
    required this.result,
    this.resultSuffix,
    this.subResult,
    required this.onCalculate,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final provider = Provider.of<CalculatorProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP: RESULT AREA ---
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 60 : 40,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Result',
                    style: TextStyle(
                      fontSize: isTablet ? 20 : 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$result${resultSuffix ?? ''}',
                      style: TextStyle(
                        fontSize: isTablet ? 80 : 54,
                        fontWeight: FontWeight.bold,
                        color: provider.isDarkMode
                            ? Colors.white
                            : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  if (subResult != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subResult!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result copied!')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    label: const Text('Copy'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 44),
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: AppTheme.primaryColor,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // --- BOTTOM: SCROLLABLE INPUTS ---
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? size.width * 0.15 : 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...fields,
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onCalculate,
                            child: const Text('Calculate'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: onReset,
                          icon: const Icon(Icons.refresh),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40), // Space before ads
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 60,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: provider.isDarkMode
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.05),
          ),
          child: const BannerAdWidget(),
        ),
      ),
    );
  }
}

// Helper Widget for Input
class CalcInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefixText;

  const CalcInput({
    super.key,
    required this.label,
    required this.controller,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }
}

// --- SPECIFIC PAGES ---

class PercentagePage extends StatefulWidget {
  const PercentagePage({super.key});
  @override
  State<PercentagePage> createState() => _PercentagePageState();
}

class _PercentagePageState extends State<PercentagePage> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  String _res = '0.00';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    return BaseCalcPage(
      title: 'Check Percentage',
      description:
          'Enter the percentage and the total number to find the value.',
      fields: [
        CalcInput(label: 'What is (%)', controller: _c1),
        CalcInput(label: 'Of (Total Value)', controller: _c2),
      ],
      result: _res,
      onCalculate: () {
        double p = double.tryParse(_c1.text) ?? 0;
        double v = double.tryParse(_c2.text) ?? 0;
        setState(
          () => _res = provider.calcPercentageOf(v, p).toStringAsFixed(2),
        );
        AdManager.showInterstitialIfNeeded(provider);
      },
      onReset: () => setState(() {
        _c1.clear();
        _c2.clear();
        _res = '0.00';
      }),
    );
  }
}

class ChangePage extends StatefulWidget {
  const ChangePage({super.key});
  @override
  State<ChangePage> createState() => _ChangePageState();
}

class _ChangePageState extends State<ChangePage> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  String _res = '0.00';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    return BaseCalcPage(
      title: 'Profit & Loss',
      description:
          'Find how much a price has increased or decreased in percentage.',
      fields: [
        CalcInput(
          label: 'Old / Original Price',
          controller: _c1,
          prefixText: '\$',
        ),
        CalcInput(
          label: 'New / Current Price',
          controller: _c2,
          prefixText: '\$',
        ),
      ],
      result: _res,
      resultSuffix: '%',
      onCalculate: () {
        double o = double.tryParse(_c1.text) ?? 0;
        double n = double.tryParse(_c2.text) ?? 0;
        setState(
          () => _res = provider.calcChangePercentage(o, n).toStringAsFixed(2),
        );
        AdManager.showInterstitialIfNeeded(provider);
      },
      onReset: () => setState(() {
        _c1.clear();
        _c2.clear();
        _res = '0.00';
      }),
    );
  }
}

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});
  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  String _res = '0.00';
  String _savings = '0.00';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    return BaseCalcPage(
      title: 'Sale & Discount',
      description: 'Calculate the final price after a discount.',
      fields: [
        CalcInput(label: 'Original Price', controller: _c1, prefixText: '\$'),
        CalcInput(label: 'Discount (%)', controller: _c2),
      ],
      result: _res,
      subResult: 'Total Savings: \$$_savings',
      onCalculate: () {
        double p = double.tryParse(_c1.text) ?? 0;
        double d = double.tryParse(_c2.text) ?? 0;
        setState(() {
          _res = provider.calcDiscount(p, d).toStringAsFixed(2);
          _savings = provider.calcSavings(p, d).toStringAsFixed(2);
        });
        AdManager.showInterstitialIfNeeded(provider);
      },
      onReset: () => setState(() {
        _c1.clear();
        _c2.clear();
        _res = '0.00';
        _savings = '0.00';
      }),
    );
  }
}

class ReversePage extends StatefulWidget {
  const ReversePage({super.key});
  @override
  State<ReversePage> createState() => _ReversePageState();
}

class _ReversePageState extends State<ReversePage> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  String _res = '0.00';
  bool _wasIncrease = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    return BaseCalcPage(
      title: 'Original Price',
      description:
          'Find the price before a tax or margin was added or removed.',
      fields: [
        CalcInput(label: 'Final Price', controller: _c1, prefixText: '\$'),
        CalcInput(label: 'Percentage (%)', controller: _c2),
        Row(
          children: [
            const Text('Was it an addition? (e.g. Tax)'),
            const Spacer(),
            Switch(
              value: _wasIncrease,
              onChanged: (val) => setState(() => _wasIncrease = val),
              activeTrackColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ],
      result: _res,
      onCalculate: () {
        double v = double.tryParse(_c1.text) ?? 0;
        double p = double.tryParse(_c2.text) ?? 0;
        setState(
          () => _res = provider
              .calcOriginalPrice(v, p, _wasIncrease)
              .toStringAsFixed(2),
        );
        AdManager.showInterstitialIfNeeded(provider);
      },
      onReset: () => setState(() {
        _c1.clear();
        _c2.clear();
        _res = '0.00';
      }),
    );
  }
}

class TipPage extends StatefulWidget {
  const TipPage({super.key});
  @override
  State<TipPage> createState() => _TipPageState();
}

class _TipPageState extends State<TipPage> {
  final _c1 = TextEditingController();
  final _c2 = TextEditingController();
  final _c3 = TextEditingController();
  String _res = '0.00';
  String _total = '0.00';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context, listen: false);
    return BaseCalcPage(
      title: 'Bill & Tip',
      description: 'Split the bill and add tips easily.',
      fields: [
        CalcInput(label: 'Bill Total', controller: _c1, prefixText: '\$'),
        CalcInput(label: 'Tip (%)', controller: _c2),
        CalcInput(label: 'Number of People', controller: _c3),
      ],
      result: _res,
      resultSuffix: ' / person',
      subResult: 'Final Total: \$$_total',
      onCalculate: () {
        double t = double.tryParse(_c1.text) ?? 0;
        double tp = double.tryParse(_c2.text) ?? 0;
        int p = int.tryParse(_c3.text) ?? 1;
        setState(() {
          _res = provider.calcPerPerson(t, tp, p).toStringAsFixed(2);
          _total = provider.calcTotalWithTip(t, tp).toStringAsFixed(2);
        });
        AdManager.showInterstitialIfNeeded(provider);
      },
      onReset: () => setState(() {
        _c1.clear();
        _c2.clear();
        _c3.clear();
        _res = '0.00';
        _total = '0.00';
      }),
    );
  }
}
