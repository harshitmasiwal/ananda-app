import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/language_provider.dart';
import '../../shared/widgets/language_toggle.dart';

// ─── API Config ────────────────────────────────────────────────────────────────
const _apiNinjasKey = 'HcRCPmdAe9ukZfXgkFz7FZHcbtLDwLkXgQm6rRzB';

// ─── Panchang Calculator ───────────────────────────────────────────────────────
class PanchangData {
  final String tithi;
  final String tithiHi;
  final String nakshatra;
  final String nakshatraHi;
  final String yoga;
  final String yogaHi;
  final String karan;
  final String karanHi;
  final String vara;
  final String varaHi;
  final String paksha;
  final String pakshaHi;
  final String rahuKaal;
  final String sunriseApprox;
  final String sunsetApprox;
  final String vikramSamvat;
  final String hindiMonth;

  const PanchangData({
    required this.tithi,
    required this.tithiHi,
    required this.nakshatra,
    required this.nakshatraHi,
    required this.yoga,
    required this.yogaHi,
    required this.karan,
    required this.karanHi,
    required this.vara,
    required this.varaHi,
    required this.paksha,
    required this.pakshaHi,
    required this.rahuKaal,
    required this.sunriseApprox,
    required this.sunsetApprox,
    required this.vikramSamvat,
    required this.hindiMonth,
  });
}

class PanchangCalculator {
  static const _tithis = [
    'Pratipada', 'Dwitiya', 'Tritiya', 'Chaturthi', 'Panchami',
    'Shashthi', 'Saptami', 'Ashtami', 'Navami', 'Dashami',
    'Ekadashi', 'Dwadashi', 'Trayodashi', 'Chaturdashi', 'Purnima/Amavasya',
  ];
  static const _tithisHi = [
    'प्रतिपदा', 'द्वितीया', 'तृतीया', 'चतुर्थी', 'पंचमी',
    'षष्ठी', 'सप्तमी', 'अष्टमी', 'नवमी', 'दशमी',
    'एकादशी', 'द्वादशी', 'त्रयोदशी', 'चतुर्दशी', 'पूर्णिमा/अमावस्या',
  ];
  static const _nakshatras = [
    'Ashwini', 'Bharani', 'Krittika', 'Rohini', 'Mrigashira',
    'Ardra', 'Punarvasu', 'Pushya', 'Ashlesha', 'Magha',
    'Purva Phalguni', 'Uttara Phalguni', 'Hasta', 'Chitra', 'Swati',
    'Vishakha', 'Anuradha', 'Jyeshtha', 'Mula', 'Purva Ashadha',
    'Uttara Ashadha', 'Shravana', 'Dhanishta', 'Shatabhisha',
    'Purva Bhadrapada', 'Uttara Bhadrapada', 'Revati',
  ];
  static const _nakshatrasHi = [
    'अश्विनी', 'भरणी', 'कृत्तिका', 'रोहिणी', 'मृगशिरा',
    'आर्द्रा', 'पुनर्वसु', 'पुष्य', 'आश्लेषा', 'मघा',
    'पूर्व फाल्गुनी', 'उत्तर फाल्गुनी', 'हस्त', 'चित्रा', 'स्वाति',
    'विशाखा', 'अनुराधा', 'ज्येष्ठा', 'मूल', 'पूर्व आषाढ़ा',
    'उत्तर आषाढ़ा', 'श्रवण', 'धनिष्ठा', 'शतभिषा',
    'पूर्व भाद्रपद', 'उत्तर भाद्रपद', 'रेवती',
  ];
  static const _yogas = [
    'Vishkambha', 'Preeti', 'Ayushman', 'Saubhagya', 'Shobhana',
    'Atiganda', 'Sukarma', 'Dhriti', 'Shula', 'Ganda',
    'Vriddhi', 'Dhruva', 'Vyaghata', 'Harshana', 'Vajra',
    'Siddhi', 'Vyatipata', 'Variyan', 'Parigha', 'Shiva',
    'Siddha', 'Sadhya', 'Shubha', 'Shukla', 'Brahma',
    'Indra', 'Vaidhriti',
  ];
  static const _yogasHi = [
    'विष्कम्भ', 'प्रीति', 'आयुष्मान', 'सौभाग्य', 'शोभन',
    'अतिगण्ड', 'सुकर्मा', 'धृति', 'शूल', 'गण्ड',
    'वृद्धि', 'ध्रुव', 'व्याघात', 'हर्षण', 'वज्र',
    'सिद्धि', 'व्यतीपात', 'वरीयान', 'परिघ', 'शिव',
    'सिद्ध', 'साध्य', 'शुभ', 'शुक्ल', 'ब्रह्म',
    'इन्द्र', 'वैधृति',
  ];
  static const _karans = [
    'Bava', 'Balava', 'Kaulava', 'Taitila', 'Garaja',
    'Vanija', 'Vishti', 'Shakuni', 'Chatushpada', 'Naga',
  ];
  static const _karansHi = [
    'बव', 'बालव', 'कौलव', 'तैतिल', 'गर',
    'वणिज', 'विष्टि', 'शकुनि', 'चतुष्पाद', 'नाग',
  ];
  static const _varas = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
  static const _varasHi = [
    'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार',
    'शुक्रवार', 'शनिवार', 'रविवार',
  ];

  // Rahu Kaal by weekday (Mon=0..Sun=6)
  static const _rahuKaal = [
    '7:30 – 9:00',   // Monday
    '15:00 – 16:30', // Tuesday
    '12:00 – 13:30', // Wednesday
    '13:30 – 15:00', // Thursday
    '10:30 – 12:00', // Friday
    '9:00 – 10:30',  // Saturday
    '16:30 – 18:00', // Sunday
  ];

  static const _hindiMonths = [
    'चैत्र', 'वैशाख', 'ज्येष्ठ', 'आषाढ़', 'श्रावण', 'भाद्रपद',
    'आश्विन', 'कार्तिक', 'मार्गशीर्ष', 'पौष', 'माघ', 'फाल्गुन',
  ];

  static PanchangData calculate(DateTime date) {
    final jd = _julianDay(date);
    final moonLong = _moonLongitude(jd);
    final sunLong = _sunLongitude(jd);

    final elongation = (moonLong - sunLong + 360) % 360;
    final tithiIndex = (elongation / 12).floor();
    final tithiNum = tithiIndex % 15;
    final isPurnima = tithiIndex == 14;
    final isAmavasya = tithiIndex == 29;
    final paksha = tithiIndex < 15 ? 'Shukla Paksha' : 'Krishna Paksha';
    final pakshaHi = tithiIndex < 15 ? 'शुक्ल पक्ष' : 'कृष्ण पक्ष';

    String tithiName = _tithis[tithiNum];
    String tithiNameHi = _tithisHi[tithiNum];
    if (isPurnima) { tithiName = 'Purnima'; tithiNameHi = 'पूर्णिमा'; }
    if (isAmavasya) { tithiName = 'Amavasya'; tithiNameHi = 'अमावस्या'; }

    final nakshatraIndex = (moonLong / (360.0 / 27)).floor() % 27;
    final yogaIndex = ((sunLong + moonLong) / (360.0 / 27)).floor() % 27;
    final karanIndex = (elongation / 6).floor() % 10;
    final vara = date.weekday - 1; // Mon=0
    final vikramYear = date.year + (date.month > 3 ? 57 : 56);
    final hindiMonthIndex = ((date.month + 1) % 12);

    return PanchangData(
      tithi: tithiName,
      tithiHi: tithiNameHi,
      nakshatra: _nakshatras[nakshatraIndex],
      nakshatraHi: _nakshatrasHi[nakshatraIndex],
      yoga: _yogas[yogaIndex],
      yogaHi: _yogasHi[yogaIndex],
      karan: _karans[karanIndex],
      karanHi: _karansHi[karanIndex],
      vara: _varas[vara],
      varaHi: _varasHi[vara],
      paksha: paksha,
      pakshaHi: pakshaHi,
      rahuKaal: _rahuKaal[vara],
      sunriseApprox: '6:00 AM',
      sunsetApprox: '6:00 PM',
      vikramSamvat: 'VS $vikramYear',
      hindiMonth: _hindiMonths[hindiMonthIndex],
    );
  }

  static double _julianDay(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day;
    final a = ((14 - m) / 12).floor();
    final yr = y + 4800 - a;
    final mo = m + 12 * a - 3;
    return d +
        ((153 * mo + 2) / 5).floor() +
        365 * yr +
        (yr / 4).floor() -
        (yr / 100).floor() +
        (yr / 400).floor() -
        32045;
  }

  static double _sunLongitude(double jd) {
    final n = jd - 2451545.0;
    final l = (280.460 + 0.9856474 * n) % 360;
    final g = (357.528 + 0.9856003 * n) % 360 * pi / 180;
    return (l + 1.915 * sin(g) + 0.020 * sin(2 * g)) % 360;
  }

  static double _moonLongitude(double jd) {
    final n = jd - 2451545.0;
    final l = (218.316 + 13.176396 * n) % 360;
    final m = (134.963 + 13.064993 * n) % 360 * pi / 180;
    final f = (93.272 + 13.229350 * n) % 360 * pi / 180;
    return (l +
            6.289 * sin(m) -
            1.274 * sin(2 * f - m) +
            0.658 * sin(2 * f) -
            0.214 * sin(2 * m)) %
        360;
  }
}

// ─── Horoscope Model ───────────────────────────────────────────────────────────
class HoroscopeResult {
  final String sign;
  final String horoscope;
  final String horoscopeHi;
  final String date;
  final bool isLoading;
  final String? error;

  const HoroscopeResult({
    required this.sign,
    this.horoscope = '',
    this.horoscopeHi = '',
    this.date = '',
    this.isLoading = false,
    this.error,
  });
}

// ─── API-Ninjas Horoscope Fetch + Google Translate ────────────────────────────
Future<HoroscopeResult> fetchHoroscope(String sign) async {
  try {
    // 1. Fetch from API-Ninjas
    final uri = Uri.parse(
        'https://api.api-ninjas.com/v1/horoscope?zodiac=$sign');
    final response = await http.get(
      uri,
      headers: {'X-Api-Key': _apiNinjasKey},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('API-Ninjas error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final englishText = (data['horoscope'] as String?) ?? '';
    final date = (data['date'] as String?) ?? '';

    // 2. Translate to Hindi using free Google Translate endpoint
    String hindiText = '';
    try {
      final translateUri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=en&tl=hi&dt=t&q=${Uri.encodeComponent(englishText)}',
      );
      final tRes = await http
          .get(translateUri)
          .timeout(const Duration(seconds: 8));
      if (tRes.statusCode == 200) {
        final tData = json.decode(tRes.body);
        // Response is a nested list: [[["translated","original",...],...],...]
        final parts = tData[0] as List<dynamic>;
        hindiText = parts
            .map((p) => (p as List<dynamic>)[0].toString())
            .join('');
      }
    } catch (_) {
      // Hindi translation failed — fall back to English
      hindiText = englishText;
    }

    return HoroscopeResult(
      sign: sign,
      horoscope: englishText,
      horoscopeHi: hindiText,
      date: date,
      isLoading: false,
    );
  } catch (e) {
    // Full offline fallback
    return HoroscopeResult(
      sign: sign,
      horoscope: _offlinePredictions[sign] ??
          'A day filled with divine grace. Seek blessings through prayer and meditation.',
      horoscopeHi: _offlinePredictionsHi[sign] ??
          'आज का दिन दैवीय कृपा से भरा है। प्रार्थना और ध्यान के माध्यम से आशीर्वाद प्राप्त करें।',
      date: '',
      isLoading: false,
      error: e.toString(),
    );
  }
}

const _offlinePredictions = {
  'aries':
      'Mars blesses you with courage today. Take decisive action on matters dear to your heart. New beginnings await those bold enough to embrace them.',
  'taurus':
      'Venus showers abundance on you. Financial stability is on the horizon. Enjoy life\'s earthly pleasures while staying grounded in gratitude.',
  'gemini':
      'Mercury sharpens your intellect today. Excellent day for communication, learning, and forming new connections. Express your ideas freely.',
  'cancer':
      'The Moon nurtures your soul. Family bonds strengthen today. Trust your intuition — it will guide you toward emotional fulfillment.',
  'leo':
      'The Sun illuminates your path with glory. Leadership opportunities arise. Your charisma attracts positive energy and loyal companions.',
  'virgo':
      'Mercury brings clarity to your work. Attention to detail serves you well. A practical approach to problems yields excellent results.',
  'libra':
      'Venus harmonizes your relationships. Seek balance in all things. Diplomacy and grace will help you resolve any lingering conflicts.',
  'scorpio':
      'Pluto reveals deep truths. Transformation is underway. Trust the process of change — it leads to greater power and wisdom.',
  'sagittarius':
      'Jupiter expands your horizons. Adventure calls. Whether physical or intellectual, exploration brings joy and valuable insights.',
  'capricorn':
      'Saturn rewards your discipline. Career matters progress steadily. Hard work and patience are your most powerful tools today.',
  'aquarius':
      'Uranus sparks innovation. Original ideas flow freely. Connect with like-minded souls to bring your visionary plans to life.',
  'pisces':
      'Neptune deepens your intuition. Spiritual awareness is heightened. Creative pursuits and meditation bring peace and divine inspiration.',
};

const _offlinePredictionsHi = {
  'aries':
      'मंगल आज आपको साहस का आशीर्वाद देता है। जो मामले आपके दिल के करीब हैं उन पर निर्णायक कदम उठाएं।',
  'taurus':
      'शुक्र आप पर प्रचुरता की वर्षा करता है। वित्तीय स्थिरता क्षितिज पर है। कृतज्ञता में स्थिर रहें।',
  'gemini':
      'बुध आज आपकी बुद्धि को तेज करता है। संचार, सीखने और नए संबंध बनाने के लिए उत्कृष्ट दिन।',
  'cancer':
      'चंद्रमा आपकी आत्मा का पोषण करता है। पारिवारिक बंधन आज मजबूत होते हैं। अपनी अंतरात्मा पर भरोसा करें।',
  'leo':
      'सूर्य आपके मार्ग को गौरव से प्रकाशित करता है। नेतृत्व के अवसर उत्पन्न होते हैं।',
  'virgo':
      'बुध आपके काम में स्पष्टता लाता है। विवरण पर ध्यान आपकी अच्छी सेवा करता है।',
  'libra':
      'शुक्र आपके रिश्तों में सामंजस्य बिठाता है। हर चीज में संतुलन खोजें।',
  'scorpio':
      'प्लूटो गहरे सत्यों को उजागर करता है। परिवर्तन जारी है। परिवर्तन की प्रक्रिया पर भरोसा करें।',
  'sagittarius':
      'बृहस्पति आपके क्षितिज का विस्तार करता है। साहसिक कार्य पुकारता है।',
  'capricorn':
      'शनि आपके अनुशासन को पुरस्कृत करता है। करियर के मामले धीरे-धीरे आगे बढ़ते हैं।',
  'aquarius':
      'यूरेनस नवाचार की चिंगारी जलाता है। मूल विचार स्वतंत्र रूप से प्रवाहित होते हैं।',
  'pisces':
      'नेपच्यून आपकी अंतर्ज्ञान को गहरा करता है। आध्यात्मिक जागरूकता बढ़ी हुई है।',
};

// ─── Main Screen ───────────────────────────────────────────────────────────────
class HoroscopeScreen extends ConsumerStatefulWidget {
  final bool showPanchangFirst;
  const HoroscopeScreen({super.key, this.showPanchangFirst = false});

  @override
  ConsumerState<HoroscopeScreen> createState() => _HoroscopeScreenState();
}

class _HoroscopeScreenState extends ConsumerState<HoroscopeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSign = 'aries';
  HoroscopeResult? _horoscopeResult;
  bool _loadingHoroscope = false;
  late PanchangData _panchangData;

  static const _signData = [
    ('aries', '♈', 'Aries', 'मेष', 'Mar 21 – Apr 19'),
    ('taurus', '♉', 'Taurus', 'वृषभ', 'Apr 20 – May 20'),
    ('gemini', '♊', 'Gemini', 'मिथुन', 'May 21 – Jun 20'),
    ('cancer', '♋', 'Cancer', 'कर्क', 'Jun 21 – Jul 22'),
    ('leo', '♌', 'Leo', 'सिंह', 'Jul 23 – Aug 22'),
    ('virgo', '♍', 'Virgo', 'कन्या', 'Aug 23 – Sep 22'),
    ('libra', '♎', 'Libra', 'तुला', 'Sep 23 – Oct 22'),
    ('scorpio', '♏', 'Scorpio', 'वृश्चिक', 'Oct 23 – Nov 21'),
    ('sagittarius', '♐', 'Sagittarius', 'धनु', 'Nov 22 – Dec 21'),
    ('capricorn', '♑', 'Capricorn', 'मकर', 'Dec 22 – Jan 19'),
    ('aquarius', '♒', 'Aquarius', 'कुंभ', 'Jan 20 – Feb 18'),
    ('pisces', '♓', 'Pisces', 'मीन', 'Feb 19 – Mar 20'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.showPanchangFirst ? 0 : 1,
    );
    _panchangData = PanchangCalculator.calculate(DateTime.now());
    _loadHoroscope(_selectedSign);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHoroscope(String sign) async {
    setState(() => _loadingHoroscope = true);
    final result = await fetchHoroscope(sign);
    if (mounted) {
      setState(() {
        _horoscopeResult = result;
        _loadingHoroscope = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = ref.watch(isHindiProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('🔮',
                              style: TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isHindi ? 'ज्योतिष और पंचांग' : 'Astro & Panchang',
                          style: AppTextStyles.appName
                              .copyWith(fontSize: 20, letterSpacing: 0.5),
                        ),
                        const Spacer(),
                        LanguageToggle(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.gold,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Colors.white.withValues(alpha: 0.55),
                    labelStyle: AppTextStyles.h3
                        .copyWith(color: Colors.white, fontSize: 14),
                    tabs: [
                      Tab(text: isHindi ? 'पंचांग' : 'Panchang'),
                      Tab(text: isHindi ? 'राशिफल' : 'Horoscope'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab views ───────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PanchangTab(isHindi: isHindi, data: _panchangData),
                _HoroscopeTab(
                  isHindi: isHindi,
                  signData: _signData,
                  selectedSign: _selectedSign,
                  horoscopeResult: _horoscopeResult,
                  isLoading: _loadingHoroscope,
                  onSignChanged: (s) {
                    setState(() => _selectedSign = s);
                    _loadHoroscope(s);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Panchang Tab ─────────────────────────────────────────────────────────────
class _PanchangTab extends StatelessWidget {
  final bool isHindi;
  final PanchangData data;
  const _PanchangTab({required this.isHindi, required this.data});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date Hero Card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A237E).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Left: gregorian date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${now.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      '${months[now.month - 1]} ${now.year}',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        isHindi ? data.varaHi : data.vara,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Right: Hindu date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('☀️', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 10),
                    Text(
                      data.vikramSamvat,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      isHindi ? data.hindiMonth : 'Hindu Month',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isHindi ? data.pakshaHi : data.paksha,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Sunrise / Sunset ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _SunCard(
                  icon: '🌅',
                  label: isHindi ? 'सूर्योदय' : 'Sunrise',
                  time: data.sunriseApprox,
                  color: const Color(0xFFFF8F00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SunCard(
                  icon: '🌇',
                  label: isHindi ? 'सूर्यास्त' : 'Sunset',
                  time: data.sunsetApprox,
                  color: const Color(0xFF6A1B9A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            isHindi ? 'पंचांग विवरण' : 'Panchang Details',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 12),

          _PanchangRow(
            icon: Icons.brightness_2_rounded,
            label: isHindi ? 'तिथि' : 'Tithi',
            value: isHindi ? data.tithiHi : data.tithi,
            color: const Color(0xFF1565C0),
          ),
          _PanchangRow(
            icon: Icons.star_rounded,
            label: isHindi ? 'नक्षत्र' : 'Nakshatra',
            value: isHindi ? data.nakshatraHi : data.nakshatra,
            color: const Color(0xFF6A1B9A),
          ),
          _PanchangRow(
            icon: Icons.auto_fix_high_rounded,
            label: isHindi ? 'योग' : 'Yoga',
            value: isHindi ? data.yogaHi : data.yoga,
            color: const Color(0xFF00695C),
          ),
          _PanchangRow(
            icon: Icons.circle_outlined,
            label: isHindi ? 'करण' : 'Karan',
            value: isHindi ? data.karanHi : data.karan,
            color: const Color(0xFFAD1457),
          ),
          _PanchangRow(
            icon: Icons.calendar_today_rounded,
            label: isHindi ? 'वार' : 'Vara',
            value: isHindi ? data.varaHi : data.vara,
            color: const Color(0xFFE65100),
          ),
          _PanchangRow(
            icon: Icons.do_not_disturb_on_rounded,
            label: isHindi ? 'राहु काल' : 'Rahu Kaal',
            value: data.rahuKaal,
            color: const Color(0xFF37474F),
            isBad: true,
          ),

          const SizedBox(height: 20),

          // ── Daily Shloka ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF8E1), Color(0xFFFFFDE7)],
              ),
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🕉️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHindi ? 'आज का संदेश' : 'Today\'s Message',
                        style: AppTextStyles.h3.copyWith(
                            fontSize: 13, color: AppColors.goldDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHindi
                            ? 'सत्यं शिवं सुन्दरम् — सत्य, शिव और सौंदर्य की साधना करें।'
                            : 'Satyam Shivam Sundaram — Seek truth, auspiciousness & beauty in every moment.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: const Color(0xFF5D4037),
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SunCard extends StatelessWidget {
  final String icon;
  final String label;
  final String time;
  final Color color;
  const _SunCard(
      {required this.icon,
      required this.label,
      required this.time,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              Text(time,
                  style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanchangRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isBad;
  const _PanchangRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isBad = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBad
              ? Colors.red.withValues(alpha: 0.2)
              : AppColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: AppTextStyles.h3.copyWith(
                  fontSize: 13,
                  color: isBad
                      ? Colors.red.shade700
                      : AppColors.textPrimary)),
          if (isBad) ...[
            const SizedBox(width: 6),
            Icon(Icons.warning_amber_rounded,
                color: Colors.red.shade400, size: 16),
          ],
        ],
      ),
    );
  }
}

// ─── Horoscope Tab ────────────────────────────────────────────────────────────
class _HoroscopeTab extends StatelessWidget {
  final bool isHindi;
  final List<(String, String, String, String, String)> signData;
  final String selectedSign;
  final HoroscopeResult? horoscopeResult;
  final bool isLoading;
  final ValueChanged<String> onSignChanged;

  const _HoroscopeTab({
    required this.isHindi,
    required this.signData,
    required this.selectedSign,
    required this.horoscopeResult,
    required this.isLoading,
    required this.onSignChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = signData.firstWhere(
        (s) => s.$1 == selectedSign,
        orElse: () => signData[0]);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isHindi ? 'अपनी राशि चुनें' : 'Choose Your Zodiac Sign',
            style: AppTextStyles.sectionHeader,
          ),
          const SizedBox(height: 12),

          // ── Zodiac Grid ─────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.9,
            ),
            itemCount: signData.length,
            itemBuilder: (_, i) {
              final sign = signData[i];
              final isActive = sign.$1 == selectedSign;
              return GestureDetector(
                onTap: () => onSignChanged(sign.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isActive ? null : AppColors.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF1A237E)
                          : AppColors.divider,
                      width: 1.5,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1A237E)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sign.$2,
                          style: TextStyle(
                              fontSize: isActive ? 26 : 22)),
                      const SizedBox(height: 2),
                      Text(
                        isHindi ? sign.$4 : sign.$3,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── Horoscope Result Card ───────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: isLoading
                ? _loadingCard(isHindi)
                : _resultCard(selected, horoscopeResult, isHindi),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _loadingCard(bool isHindi) {
    return Container(
      key: const ValueKey('loading'),
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isHindi
                ? 'राशिफल लोड हो रहा है...'
                : 'Fetching your horoscope...',
            style:
                const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(
    (String, String, String, String, String) selected,
    HoroscopeResult? result,
    bool isHindi,
  ) {
    final horoscopeText = isHindi
        ? (result?.horoscopeHi.isNotEmpty == true
            ? result!.horoscopeHi
            : _offlinePredictionsHi[selected.$1] ?? '')
        : (result?.horoscope.isNotEmpty == true
            ? result!.horoscope
            : _offlinePredictions[selected.$1] ?? '');

    return Container(
      key: ValueKey(selected.$1),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Sign header ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Text(selected.$2,
                    style: const TextStyle(fontSize: 42)),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHindi ? selected.$4 : selected.$3,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      selected.$5,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                if (result?.date.isNotEmpty == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      result!.date,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Horoscope text ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                horoscopeText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Source badge ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: AppColors.gold, size: 14),
                const SizedBox(width: 6),
                Text(
                  result?.error == null
                      ? (isHindi
                          ? 'API Ninjas से लाइव डेटा'
                          : 'Live data via API-Ninjas')
                      : (isHindi ? 'ऑफलाइन मोड' : 'Offline mode'),
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
