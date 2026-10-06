import 'package:flutter/material.dart';
import 'currency_service.dart';

class ConverterScreen extends StatefulWidget {
  const ConverterScreen({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

  final bool isEnglish;
  final ValueChanged<bool> onLanguageChanged;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _oldLiraController = TextEditingController();
  final TextEditingController _newLiraController = TextEditingController();
  final TextEditingController _usdController = TextEditingController();

  final CurrencyService _currencyService = CurrencyService();

  Map<int, int> _suggestedNotes = {500: 0, 200: 0, 100: 0, 50: 0, 10: 0};
  String dollarBuy = '...';
  String dollarSell = '...';
  bool isLoadingPrices = true;
  bool isBuyMode = true; // true تعني شراء، false تعني مبيع

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    if (!mounted) return;
    setState(() => isLoadingPrices = true);

    final prices = await _currencyService.fetchDamascusDollarPrices();

    if (!mounted) return;
    // حماية تامة من الـ Null واستخدام القيم الافتراضية الآمنة '...' في حال الفشل
    setState(() {
      dollarBuy = prices?['buy'] ?? '...';
      dollarSell = prices?['sell'] ?? '...';
      isLoadingPrices = false;
    });

    _refreshCalculations();
  }

  double _getCurrentRate() {
    final rateStr = isBuyMode ? dollarBuy : dollarSell;
    return double.tryParse(rateStr) ?? 0.0;
  }

  void _refreshCalculations() {
    if (_usdController.text.isNotEmpty) {
      _onUsdChanged(_usdController.text);
    } else if (_oldLiraController.text.isNotEmpty) {
      _onOldLiraChanged(_oldLiraController.text);
    }
  }

  void _calculateSuggestedNotes(double newAmount) {
    int remainingAmount = newAmount.floor();
    List<int> denominations = [500, 200, 100, 50, 10];
    Map<int, int> tempNotes = {500: 0, 200: 0, 100: 0, 50: 0, 10: 0};

    for (int denomination in denominations) {
      if (remainingAmount >= denomination) {
        tempNotes[denomination] = remainingAmount ~/ denomination;
        remainingAmount = remainingAmount % denomination;
      }
    }
    setState(() => _suggestedNotes = tempNotes);
  }

  void _onOldLiraChanged(String value) {
    if (value.isEmpty) {
      _clearAllFields();
      return;
    }
    double? oldAmount = double.tryParse(value.replaceAll(',', ''));
    if (oldAmount != null) {
      double newAmount = oldAmount / 100;
      double rate = _getCurrentRate();
      // حماية من القسمة على صفر إذا كان السيرفر لم يحمل بعد
      double usdAmount = rate > 0 ? oldAmount / rate : 0.0;

      _newLiraController.value = TextEditingValue(
        text: newAmount.toStringAsFixed(0),
      );
      _usdController.value = TextEditingValue(
        text: usdAmount.toStringAsFixed(2),
      );
      _calculateSuggestedNotes(newAmount);
    }
  }

  void _onNewLiraChanged(String value) {
    if (value.isEmpty) {
      _clearAllFields();
      return;
    }
    double? newAmount = double.tryParse(value.replaceAll(',', ''));
    if (newAmount != null) {
      double oldAmount = newAmount * 100;
      double rate = _getCurrentRate();
      // حماية من القسمة على صفر إذا كان السيرفر لم يحمل بعد
      double usdAmount = rate > 0 ? oldAmount / rate : 0.0;

      _oldLiraController.value = TextEditingValue(
        text: oldAmount.toStringAsFixed(0),
      );
      _usdController.value = TextEditingValue(
        text: usdAmount.toStringAsFixed(2),
      );
      _calculateSuggestedNotes(newAmount);
    }
  }

  void _onUsdChanged(String value) {
    if (value.isEmpty) {
      _clearAllFields();
      return;
    }
    double? usdAmount = double.tryParse(value.replaceAll(',', ''));
    if (usdAmount != null) {
      double rate = _getCurrentRate();
      double oldAmount = usdAmount * rate;
      double newAmount = oldAmount / 100;

      _oldLiraController.value = TextEditingValue(
        text: oldAmount.toStringAsFixed(0),
      );
      _newLiraController.value = TextEditingValue(
        text: newAmount.toStringAsFixed(0),
      );
      _calculateSuggestedNotes(newAmount);
    }
  }

  void _clearAllFields() {
    _oldLiraController.clear();
    _newLiraController.clear();
    _usdController.clear();
    setState(() => _suggestedNotes.updateAll((key, val) => 0));
  }

  @override
  void dispose() {
    _oldLiraController.dispose();
    _newLiraController.dispose();
    _usdController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      fillColor: const Color(0xFF1E293B).withOpacity(0.6),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildTextFieldWithShadow({
    required TextEditingController controller,
    required String hint,
    required String label,
    required ValueChanged<String> onChanged,
    bool isDecimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        FocusScope(
          child: Focus(
            onFocusChange: (hasFocus) {
              setState(() {});
            },
            child: Builder(
              builder: (context) {
                final hasFocus = Focus.of(context).hasFocus;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasFocus ? Colors.purpleAccent : Colors.white10,
                      width: hasFocus ? 1.8 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: hasFocus
                            ? Colors.purpleAccent.withOpacity(0.25)
                            : Colors.transparent,
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: isDecimal
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: _buildInputDecoration(hint),
                    onChanged: onChanged,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeNotes = _suggestedNotes.entries
        .where((entry) => entry.value > 0)
        .toList();

    // 🛡️ حماية التطبيق من الإغلاق عند إغلاق الكيبورد أو ضغط زر الرجوع
    return PopScope(
      canPop: false, // نمنع الخروج التلقائي الفوري للتطبيق
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // إذا كان الكيبورد مفتوحاً، نقوم بإغلاقه فقط عند ضغط سهم النظام
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              title: Text(
                widget.isEnglish
                    ? 'Syrian Lira Converter'
                    : 'محول الليرة السورية',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                //Text(widget.isEnglish ? 'EN' : 'عربي'),
                Transform.scale(
                  scale: 0.7,
                  child: Switch(
                    key: const ValueKey('languageSwitch'),
                    value: widget.isEnglish,
                    onChanged: widget.onLanguageChanged,
                    activeThumbColor: Colors.greenAccent,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadPrices,
                ),
              ],
            ),
          ),
        ),
        body: Container(
          color: const Color(0xFF0F172A).withOpacity(0.8),
          child: SafeArea(
            child: GestureDetector(
              // ✨ ميزة إضافية: عند الضغط في أي مكان فارغ بالشبكة يتم إغلاق الكيبورد بسلاسة
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildPriceCard(
                          widget.isEnglish
                              ? 'Dollar sell (Damascus)'
                              : 'مبيع الدولار (دمشق)',
                          dollarSell,
                          Colors.redAccent,
                        ),
                        _buildPriceCard(
                          widget.isEnglish
                              ? 'Dollar buy (Damascus)'
                              : 'شراء الدولار (دمشق)',
                          dollarBuy,
                          Colors.greenAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: Container(
                        height: 60,
                        width: 180,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isBuyMode
                                ? Colors.greenAccent.withOpacity(0.8)
                                : Colors.purpleAccent.withOpacity(0.8),
                            width: 1.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isBuyMode
                                          ? Colors.greenAccent
                                          : Colors.purpleAccent)
                                      .withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.isEnglish ? 'Sell' : 'بيع',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isBuyMode,
                                activeThumbColor: Colors.greenAccent,
                                activeTrackColor: Colors.greenAccent
                                    .withOpacity(0.3),
                                inactiveThumbColor: Colors.redAccent,
                                inactiveTrackColor: Colors.redAccent
                                    .withOpacity(0.3),
                                trackOutlineColor: WidgetStateColor.transparent,
                                onChanged: (value) {
                                  setState(() {
                                    isBuyMode = value;
                                  });
                                  _refreshCalculations();
                                },
                              ),
                            ),
                            Text(
                              widget.isEnglish ? 'Buy' : 'شراء',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildTextFieldWithShadow(
                      controller: _oldLiraController,
                      label: widget.isEnglish
                          ? 'Amount in old Syrian lira'
                          : 'المبلغ بالليرة السورية القديمة',
                      hint: widget.isEnglish
                          ? 'Enter the amount in old lira'
                          : 'أدخل المبلغ بالليرة القديمة',
                      onChanged: _onOldLiraChanged,
                    ),
                    const SizedBox(height: 16),

                    _buildTextFieldWithShadow(
                      controller: _newLiraController,
                      label: widget.isEnglish
                          ? 'Amount in new Syrian lira'
                          : 'المبلغ بالليرة السورية الجديدة',
                      hint: widget.isEnglish
                          ? 'Enter the amount in new lira'
                          : 'أدخل المبلغ بالليرة الجديدة',
                      onChanged: _onNewLiraChanged,
                    ),
                    const SizedBox(height: 16),

                    _buildTextFieldWithShadow(
                      controller: _usdController,
                      label: isBuyMode
                          ? (widget.isEnglish
                                ? 'Amount in US dollars (buy)'
                                : 'المبلغ بالدولار الأمريكي (شراء)')
                          : (widget.isEnglish
                                ? 'Amount in US dollars (sell)'
                                : 'المبلغ بالدولار الأمريكي (مبيع)'),
                      hint: widget.isEnglish
                          ? 'Enter the amount in US dollars'
                          : 'أدخل المبلغ بالدولار الأمريكي',
                      isDecimal: true,
                      onChanged: _onUsdChanged,
                    ),
                    const SizedBox(height: 30),

                    Text(
                      widget.isEnglish
                          ? 'Suggested banknotes:'
                          : 'الأوراق النقدية المقترحة:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (activeNotes.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: activeNotes.length,
                        itemBuilder: (context, index) {
                          int denomination = activeNotes[index].key;
                          int count = activeNotes[index].value;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.purpleAccent.withOpacity(0.9),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/note_$denomination.jpeg',
                                  height: 90,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/note_$denomination.jpg',
                                      height: 90,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error2, stackTrace2) {
                                            return const Icon(
                                              Icons.account_balance_wallet,
                                              size: 50,
                                              color: Colors.greenAccent,
                                            );
                                          },
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'x $count',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  widget.isEnglish
                                      ? '$denomination new SYP'
                                      : '$denomination ل.س جديدة',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Text(
                        widget.isEnglish
                            ? 'Enter an amount above to see suggested banknotes'
                            : 'أدخل مبلغاً في أي حقل أعلاه لرؤية توزيع الأوراق النقدية المقترحة',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),

                    const SizedBox(height: 40),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Powered By Menuva',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ), // إغلاق الـ Scaffold
    ); // إغلاق الـ PopScope
  }

  Widget _buildPriceCard(String title, String price, Color priceColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            isLoadingPrices
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    price,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: priceColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ],
        ),
      ),
    );
  }
}
