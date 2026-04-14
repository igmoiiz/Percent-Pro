import 'package:flutter/material.dart';

class CalculatorProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  int _calcCount = 0;
  DateTime? _adsRemovedUntil;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  bool get areAdsRemoved => 
      _adsRemovedUntil != null && DateTime.now().isBefore(_adsRemovedUntil!);

  void removeAdsFor(int minutes) {
    _adsRemovedUntil = DateTime.now().add(Duration(minutes: minutes));
    notifyListeners();
  }

  int get calcCount => _calcCount;

  void incrementCalcCount() {
    _calcCount++;
    notifyListeners();
  }

  void resetCalcCount() {
    _calcCount = 0;
    notifyListeners();
  }

  // Common Calculations
  
  // 1. Percentage of a number (X% of Y = Z)
  double calcPercentageOf(double number, double percent) {
    return (percent / 100) * number;
  }

  // 2. Percentage Increase/Decrease
  // Change = ((New - Original) / Original) * 100
  double calcChangePercentage(double original, double newValue) {
    if (original == 0) return 0;
    return ((newValue - original) / original) * 100;
  }
  
  // 3. Discount Calculator
  // Final Price = Original - (Original * (Discount / 100))
  double calcDiscount(double price, double discount) {
    return price - (price * (discount / 100));
  }
  
  double calcSavings(double price, double discount) {
    return price * (discount / 100);
  }

  // 4. Reverse Percentage (Find Original Price)
  // Original = Final / (1 + (Percent / 100)) for increase
  // Original = Final / (1 - (Percent / 100)) for decrease
  double calcOriginalPrice(double finalValue, double percent, bool wasIncrease) {
    if (wasIncrease) {
      return finalValue / (1 + (percent / 100));
    } else {
      double factor = 1 - (percent / 100);
      return factor == 0 ? 0 : finalValue / factor;
    }
  }

  // 5. Tip Calculator
  double calcTipAmount(double total, double tipPercent) {
    return total * (tipPercent / 100);
  }
  
  double calcTotalWithTip(double total, double tipPercent) {
    return total + calcTipAmount(total, tipPercent);
  }
  
  double calcPerPerson(double total, double tipPercent, int people) {
    if (people <= 0) return 0;
    return calcTotalWithTip(total, tipPercent) / people;
  }
}
