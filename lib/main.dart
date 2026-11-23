import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MDPay - Төлбөрийн Платформ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        primaryColor: const Color(0xFF3B41E3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B41E3),
          primary: const Color(0xFF3B41E3),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================================
// 1-Р ХУУДАС: НЭВТРЭХ & БҮРТГҮҮЛЭХ ХУУДАС
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _emailCtrl = TextEditingController(
    text: "customer@mdpay.mn",
  );
  final TextEditingController _passCtrl = TextEditingController(
    text: "Demo12345!",
  );
  final TextEditingController _nameCtrl = TextEditingController();

  bool _isLoginMode = true;
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _submitAuth() async {
    setState(() => _isLoading = true);

    final res = await _apiService.sendRequest(
      _isLoginMode ? "login" : "register",
      {
        "email": _emailCtrl.text.trim(),
        "password": _passCtrl.text,
        if (!_isLoginMode) "name": _nameCtrl.text.trim(),
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res["status"] == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainWorkspaceScreen(userData: res["user"]),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"] ?? "Алдаа гарлаа"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1238), Color(0xFF3942E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "MDpay",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "● MDPAY FINANCIAL PLATFORM",
                    style: TextStyle(
                      color: Color(0xFF8C9EFF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Санхүүгээ ухаалгаар\nудирд.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Төлбөр, нэхэмжлэл, шилжүүлэг — бүгд нэг системд.",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MDPAY ACCOUNT",
                      style: TextStyle(
                        color: Color(0xFF3B41E3),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Тавтай морил!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Өөрийн бүртгэлээр нэвтэрч, дансаа удирдаарай.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLoginMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _isLoginMode
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Нэвтрэх",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLoginMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isLoginMode
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Бүртгүүлэх",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_isLoginMode) ...[
                      TextField(
                        controller: _nameCtrl,
                        decoration: InputDecoration(
                          labelText: "Нэр",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "И-мэйл хаяг",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: "Нууц үг",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B41E3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitAuth,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLoginMode ? "Нэвтрэх  →" : "Бүртгүүлэх  →",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Демо эрхээр турших (Дарж автоматаар бөглөнө):",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.store, size: 16),
                                label: const Text(
                                  "merchant@mdpay.mn",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _emailCtrl.text = "merchant@mdpay.mn";
                                    _passCtrl.text = "Demo12345!";
                                  });
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.person, size: 16),
                                label: const Text(
                                  "customer@mdpay.mn",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _emailCtrl.text = "customer@mdpay.mn";
                                    _passCtrl.text = "Demo12345!";
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ҮНДСЭН WORKSPACE БОЛОН 4 ЦЭС УДИРДАХ ХУУДАС
// ============================================================================
class MainWorkspaceScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const MainWorkspaceScreen({super.key, required this.userData});

  @override
  State<MainWorkspaceScreen> createState() => _MainWorkspaceScreenState();
}

class _MainWorkspaceScreenState extends State<MainWorkspaceScreen> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;

  double _balance = 0;
  bool _hideBalance = false;
  int _pendingInvoicesCount = 0;
  int _recentTxCount = 0;
  List<dynamic> _receivable = []; // миний нэхэмжилсэн (авлага)
  List<dynamic> _payable = []; // надад ирсэн (өглөг)
  String _invoiceBox = "payable";
  String? _walletId;
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  final TextEditingController _qrAmountCtrl = TextEditingController(
    text: "125000",
  );
  final TextEditingController _qrDescCtrl = TextEditingController(
    text: "Бараа бүтээгдэхүүний төлбөр",
  );
  String _generatedQrCode = "";
  String _generatedQrAmount = "";

  String _searchText = "";
  String _typeFilter = "ALL";

  Map<String, dynamic> get currentUser => widget.userData;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    final res = await _apiService.sendRequest("get_dashboard", {
      "email": currentUser["email"],
    });
    if (res["status"] == "success") {
      setState(() {
        _balance = double.tryParse(res["balance"].toString()) ?? 0;
        _pendingInvoicesCount = res["pending_invoices_count"] ?? 0;
        _recentTxCount = res["recent_transactions_count"] ?? 0;
        _receivable = List.from(res["receivable"] ?? []);
        _payable = List.from(res["payable"] ?? []);
        _walletId = res["wallet_id"]?.toString();
        _transactions = List.from(res["transactions"] ?? []);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res["message"] ?? "Алдаа гарлаа")));
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardTab(),
      _buildQrSystemTab(),
      _buildInvoicesTab(),
      _buildHistorySearchTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B41E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "MDpay",
              style: TextStyle(
                color: Color(0xFF1A1F36),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "● DEMO",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Шинэчлэх",
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
          IconButton(
            tooltip: "Гарах",
            onPressed: () async {
              await ApiService.logout(); // token-ийг төхөөрөмжөөс устгана
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B41E3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Хяналт",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "QR Төлбөр",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: "Нэхэмжлэл",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: "Түүх & Хайлт",
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 2-Р ХУУДАС: ХЯНАЛТЫН САМБАР
  // ==========================================================================
  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "● ТАНЫ САНХҮҮГИЙН ТОЙМ",
              style: TextStyle(
                color: Color(0xFF3B41E3),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Сайн байна уу, ${currentUser['name']}! ✳",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Таны MDPay дансны өнөөдрийн мэдээлэл.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3942E6), Color(0xFF5A62F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Үндсэн дансны үлдэгдэл",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _hideBalance = !_hideBalance),
                        icon: Icon(
                          _hideBalance
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _hideBalance
                          ? "•••••••• ₮"
                          : "${_balance.toStringAsFixed(0)} ₮",
                      key: ValueKey(_hideBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "● Туршилтын данс (MNT)",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text:
                                  _walletId ??
                                  currentUser["wallet_id"] ??
                                  "MDP-998877",
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Дансны дугаар хуулагдлаа!"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              _walletId ??
                                  currentUser["wallet_id"] ??
                                  "MDP-998877",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.copy,
                              color: Colors.white70,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Хүлээгдэж буй нэхэмжлэл",
                    count: _pendingInvoicesCount.toString().padLeft(2, '0'),
                    linkText: "Нэхэмжлэл харах ↗",
                    icon: Icons.receipt_outlined,
                    onTap: () => _onNavTap(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Сүүлийн гүйлгээ",
                    count: _recentTxCount.toString().padLeft(2, '0'),
                    linkText: "Түүх харах ↗",
                    icon: Icons.trending_up,
                    onTap: () => _onNavTap(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Шуурхай үйлдлүүд",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildActionRow(
              icon: Icons.qr_code_scanner,
              title: "QR Код үүсгэх & Уншуулах",
              sub: "Dynamic QR (дүнтэй) болон QuickPay (дүнгүй)",
              onTap: () => _onNavTap(1),
            ),
            _buildActionRow(
              icon: Icons.forward_to_inbox,
              title: "Имэйлээр нэхэмжлэл үүсгэх",
              sub: "Хэрэглэгч рүү нэхэмжлэл илгээх ба төлөх",
              onTap: () => _onNavTap(2),
            ),
            _buildActionRow(
              icon: Icons.currency_exchange,
              title: "Мөнгөн шилжүүлэг хийх",
              sub: "MDPay хэрэглэгч рүү шууд мөнгө шилжүүлэх",
              onTap: _showDirectTransferSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required String linkText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF0FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF3B41E3), size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              linkText,
              style: const TextStyle(
                color: Color(0xFF3B41E3),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF3B41E3)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  // ==========================================================================
  // 3-Р ХУУДАС: QR СИСТЕМ (Dynamic QR ба QuickPay QR)
  // ==========================================================================
  Widget _buildQrSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "QR төлбөр",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "QR уншуулж төлөх эсвэл QR нэхэмжлэл үүсгэх.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F143A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white70,
                  size: 40,
                ),
                const SizedBox(height: 8),
                const Text(
                  "QR уншуулж төлөх",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B41E3),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _scanAndPay,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text("Камер нээх"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "QR нэхэмжлэл үүсгэх",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qrAmountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Үнийн дүн (₮)",
                    prefixIcon: const Icon(Icons.payments_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qrDescCtrl,
                  decoration: InputDecoration(
                    labelText: "Гүйлгээний утга / Барааны нэр",
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B41E3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final res = await _apiService.sendRequest("generate_qr", {
                        "amount": _qrAmountCtrl.text.trim(),
                        "description": _qrDescCtrl.text.trim(),
                      });
                      if (!mounted) return;
                      if (res["status"] == "success") {
                        setState(() {
                          _generatedQrCode = res["qr_code"] ?? "";
                          _generatedQrAmount = _qrAmountCtrl.text.trim();
                        });
                        _loadDashboard();
                      } else {
                        _snack(res["message"] ?? "Алдаа гарлаа", error: true);
                      }
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Шинэ QR үүсгэх"),
                  ),
                ),
                if (_generatedQrCode.isNotEmpty) ...[
                  const Divider(height: 30),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "$_generatedQrAmount ₮",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        QrImageView(data: _generatedQrCode, size: 200),
                        const SizedBox(height: 4),
                        const Text(
                          "Төлөгч MDPay апп-аар уншуулна",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.redAccent : Colors.green,
      ),
    );
  }

  /// Камер нээж QR уншаад, нэхэмжлэлийг харуулж, нууц үгээр төлнө
  Future<void> _scanAndPay() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code == null || !mounted) return;
    try {
      final inv = await ApiService.getInvoice(code);
      if (!mounted) return;
      await _confirmAndPay(inv);
    } on ApiException catch (e) {
      if (mounted) _snack(e.message, error: true);
    }
  }

  /// Нэхэмжлэлийн мэдээлэл + нууц үг асууж төлнө (QR болон жагсаалтаас хоёуланд)
  Future<void> _confirmAndPay(Map<String, dynamic> inv) async {
    final passCtrl = TextEditingController();
    bool busy = false;
    String? error;
    final payable = inv['status'] == 'PENDING' && inv['isExpired'] != true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text("Төлбөр баталгаажуулах"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Хүлээн авагч: ${inv['issuerName']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("${inv['description']}"),
              const SizedBox(height: 8),
              Text(
                "${inv['amount']} ₮",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!payable)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Энэ нэхэмжлэлийг төлөх боломжгүй",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                )
              else ...[
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Нууц үг",
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(dialogCtx),
              child: const Text("Болих"),
            ),
            ElevatedButton(
              onPressed: busy || !payable
                  ? null
                  : () async {
                      setD(() {
                        busy = true;
                        error = null;
                      });
                      try {
                        await ApiService.payInvoice(
                          '${inv['id']}',
                          passCtrl.text,
                        );
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (!mounted) return;
                        await _loadDashboard();
                        _showSuccessReceiptDialog(
                          amount: '${inv['amount']}',
                          desc: '${inv['description']}',
                          code: '${inv['issuerName']}',
                        );
                      } on ApiException catch (e) {
                        setD(() {
                          busy = false;
                          error = e.message;
                        });
                      }
                    },
              child: Text(busy ? "Түр хүлээнэ үү..." : "Төлөх"),
            ),
          ],
        ),
      ),
    );
    passCtrl.dispose();
  }

  void _showQrDialog(Map<String, dynamic> inv) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Нэхэмжлэл #${inv['id']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${inv['amount']} ₮",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("${inv['description']}"),
            const SizedBox(height: 12),
            if ((inv['qrText'] ?? '').toString().isNotEmpty)
              QrImageView(data: inv['qrText'], size: 200),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Хаах"),
          ),
        ],
      ),
    );
  }

  void _showSuccessReceiptDialog({
    required String amount,
    required String desc,
    required String code,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFE6F4EA),
              child: Icon(Icons.check_circle, color: Colors.green, size: 44),
            ),
            const SizedBox(height: 12),
            const Text(
              "Амжилттай төлөгдлөө!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "$amount ₮",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B41E3),
              ),
            ),
            const Divider(height: 24),
            Text("Утга: $desc", textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              "Хүлээн авагч: $code",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Болсон"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDirectTransferSheet() {
    final accCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController(text: "Мөнгөн шилжүүлэг");
    final passCtrl = TextEditingController();
    Map<String, dynamic>? receiver;
    bool askPassword = false;
    bool busy = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setD) {
          void resetCheck() => setD(() {
            receiver = null;
            askPassword = false;
            error = null;
          });

          Future<void> check() async {
            setD(() {
              busy = true;
              error = null;
              receiver = null;
            });
            final res = await _apiService.sendRequest("lookup_account", {
              "accountNumber": accCtrl.text.trim(),
            });
            setD(() {
              busy = false;
              if (res["status"] == "success") {
                receiver = Map<String, dynamic>.from(res["account"]);
              } else {
                error = res["message"] ?? "Данс олдсонгүй";
              }
            });
          }

          Future<void> submit() async {
            setD(() {
              busy = true;
              error = null;
            });
            final res = await _apiService.sendRequest("transfer", {
              "accountNumber": accCtrl.text.trim(),
              "amount": amountCtrl.text.trim(),
              "password": passCtrl.text,
              "note": descCtrl.text.trim(),
            });
            if (res["status"] == "success") {
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (!mounted) return;
              await _loadDashboard();
              _showSuccessReceiptDialog(
                amount: amountCtrl.text.trim(),
                desc: descCtrl.text.trim(),
                code: receiver?["name"] ?? accCtrl.text.trim(),
              );
            } else {
              setD(() {
                busy = false;
                error = res["message"] ?? "Алдаа гарлаа";
              });
            }
          }

          return AlertDialog(
            title: Text(
              askPassword ? "Нууц үгээ баталгаажуулах" : "Мөнгө шилжүүлэх",
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!askPassword) ...[
                    TextField(
                      controller: accCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => resetCheck(),
                      decoration: const InputDecoration(
                        labelText: "Хүлээн авагчийн дансны дугаар",
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (receiver == null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: busy || accCtrl.text.trim().isEmpty
                              ? null
                              : check,
                          icon: const Icon(Icons.search),
                          label: Text(busy ? "Шалгаж байна..." : "Шалгах"),
                        ),
                      )
                    else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receiver!["name"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Данс: ${receiver!["accountNumber"]}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Дүн (₮)"),
                      ),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                          labelText: "Гүйлгээний утга",
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      "${receiver!["name"]} руу ${amountCtrl.text.trim()} ₮ шилжүүлнэ.",
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passCtrl,
                      obscureText: true,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Нууц үг",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(dialogCtx),
                child: const Text("Болих"),
              ),
              if (receiver != null && !askPassword)
                ElevatedButton(
                  onPressed: () {
                    if ((int.tryParse(amountCtrl.text.trim()) ?? 0) <= 0) {
                      setD(() => error = "Дүн оруулна уу");
                      return;
                    }
                    setD(() {
                      askPassword = true;
                      error = null;
                    });
                  },
                  child: const Text("Шилжүүлэх"),
                ),
              if (askPassword)
                ElevatedButton(
                  onPressed: busy || passCtrl.text.isEmpty && false
                      ? null
                      : submit,
                  child: Text(busy ? "Түр хүлээнэ үү..." : "Баталгаажуулах"),
                ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // 4-Р ХУУДАС: НЭХЭМЖЛЭЛ ҮҮСГЭХ БА ТӨЛӨХ
  // ==========================================================================
  void _showCreateInvoiceDialog() {
    final accCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool direct = false; // false = QR нэхэмжлэл, true = хүнд нэхэмжлэх
    Map<String, dynamic>? receiver;
    bool busy = false;
    String? error;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setD) {
          Future<void> check() async {
            setD(() {
              busy = true;
              error = null;
              receiver = null;
            });
            final res = await _apiService.sendRequest("lookup_account", {
              "accountNumber": accCtrl.text.trim(),
            });
            setD(() {
              busy = false;
              if (res["status"] == "success") {
                receiver = Map<String, dynamic>.from(res["account"]);
              } else {
                error = res["message"] ?? "Данс олдсонгүй";
              }
            });
          }

          Future<void> submit() async {
            if ((int.tryParse(amountCtrl.text.trim()) ?? 0) <= 0) {
              setD(() => error = "Дүн оруулна уу");
              return;
            }
            if (direct && receiver == null) {
              setD(() => error = "Эхлээд дансны дугаарыг шалгана уу");
              return;
            }
            setD(() {
              busy = true;
              error = null;
            });
            try {
              final inv = await ApiService.createInvoice(
                amountCtrl.text.trim(),
                description: descCtrl.text.trim(),
                receiverAccountNumber: direct ? accCtrl.text.trim() : null,
              );
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              if (!mounted) return;
              await _loadDashboard();
              setState(() => _invoiceBox = "receivable");
              if (!direct) {
                _showQrDialog(inv);
              } else {
                _snack("Нэхэмжлэл ${receiver?['name']}-д илгээгдлээ");
              }
            } on ApiException catch (e) {
              setD(() {
                busy = false;
                error = e.message;
              });
            }
          }

          return AlertDialog(
            title: const Text("Шинэ нэхэмжлэл"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text("QR нэхэмжлэл"),
                        selected: !direct,
                        onSelected: (_) => setD(() {
                          direct = false;
                          error = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text("Хүнд нэхэмжлэх"),
                        selected: direct,
                        onSelected: (_) => setD(() {
                          direct = true;
                          error = null;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    direct
                        ? "Зөвхөн сонгосон хүн төлж чадна."
                        : "QR-ийг хэн ч уншиж төлж болно.",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (direct) ...[
                    TextField(
                      controller: accCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setD(() => receiver = null),
                      decoration: const InputDecoration(
                        labelText: "Төлөгчийн дансны дугаар",
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (receiver == null)
                      OutlinedButton.icon(
                        onPressed: busy || accCtrl.text.trim().isEmpty
                            ? null
                            : check,
                        icon: const Icon(Icons.search),
                        label: Text(busy ? "Шалгаж байна..." : "Шалгах"),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${receiver!['name']} · ${receiver!['accountNumber']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Нэхэмжлэх дүн (₮)",
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: "Нэхэмжлэлийн утга",
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: busy ? null : () => Navigator.pop(dialogCtx),
                child: const Text("Болих"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B41E3),
                  foregroundColor: Colors.white,
                ),
                onPressed: busy ? null : submit,
                child: Text(busy ? "Түр хүлээнэ үү..." : "Үүсгэх"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInvoicesTab() {
    final list = _invoiceBox == "payable" ? _payable : _receivable;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Нэхэмжлэлүүд",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B41E3),
                  foregroundColor: Colors.white,
                ),
                onPressed: _showCreateInvoiceDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Нэхэмжлэл"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ChoiceChip(
                label: Text("Өглөг (надад ирсэн) ${_payable.length}"),
                selected: _invoiceBox == "payable",
                onSelected: (_) => setState(() => _invoiceBox = "payable"),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text("Авлага (миний) ${_receivable.length}"),
                selected: _invoiceBox == "receivable",
                onSelected: (_) => setState(() => _invoiceBox = "receivable"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      _invoiceBox == "payable"
                          ? "Танд ирсэн нэхэмжлэл алга"
                          : "Нэхэмжилсэн нэхэмжлэл алга",
                    ),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final inv = Map<String, dynamic>.from(list[index]);
                      final bool isPaid = inv["status"] == "PAID";
                      final bool closed =
                          inv["status"] == "CANCELLED" ||
                          inv["isExpired"] == true;
                      final bool pending = !isPaid && !closed;
                      final bool inbox = _invoiceBox == "payable";
                      final String who = inbox
                          ? "Нэхэмжилсэн: ${inv['issuerName']}"
                          : (inv['isDirected'] == true
                                ? "Төлөгч: ${inv['receiverName']}"
                                : "QR (хэн ч төлнө)");

                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(14),
                          onTap: !inbox && pending
                              ? () => _showQrDialog(inv)
                              : null,
                          leading: CircleAvatar(
                            backgroundColor: isPaid
                                ? const Color(0xFFE6F4EA)
                                : const Color(0xFFFFF3E0),
                            child: Icon(
                              isPaid ? Icons.check_circle : Icons.schedule,
                              color: isPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            (inv["description"] ?? "").toString().isEmpty
                                ? "Нэхэмжлэл #${inv['id']}"
                                : inv["description"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            who,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${inv['amount']} ₮",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (isPaid)
                                const Text(
                                  "ТӨЛӨГДСӨН",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else if (closed)
                                const Text(
                                  "ХААГДСАН",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 11,
                                  ),
                                )
                              else if (inbox)
                                SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B41E3),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                    ),
                                    onPressed: () => _confirmAndPay(inv),
                                    child: const Text(
                                      "Төлөх",
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                )
                              else
                                const Text(
                                  "QR харах ›",
                                  style: TextStyle(
                                    color: Color(0xFF3B41E3),
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 5-Р ХУУДАС: ГҮЙЛГЭЭНИЙ ТҮҮХ БА ОЛОН ТӨРЛӨӨР ХАЙЛТ
  // ==========================================================================
  Widget _buildHistorySearchTab() {
    final filtered = _transactions.where((tx) {
      final matchesType = _typeFilter == "ALL" || tx["type"] == _typeFilter;
      final q = _searchText.toLowerCase();
      final matchesSearch =
          tx["title"].toString().toLowerCase().contains(q) ||
          tx["counterparty"].toString().toLowerCase().contains(q) ||
          tx["amount"].toString().contains(q);
      return matchesType && matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Гүйлгээний хуулга & Хайлт",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => setState(() => _searchText = val),
            decoration: InputDecoration(
              hintText: "Утга, имэйл эсвэл үнийн дүнгээр хайх...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ChoiceChip(
                label: const Text("Бүгд"),
                selected: _typeFilter == "ALL",
                onSelected: (_) => setState(() => _typeFilter = "ALL"),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Орлого"),
                selected: _typeFilter == "INCOME",
                onSelected: (_) => setState(() => _typeFilter = "INCOME"),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Зарлага"),
                selected: _typeFilter == "EXPENSE",
                onSelected: (_) => setState(() => _typeFilter = "EXPENSE"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("Хайлтад тохирох гүйлгээ олдсонгүй"))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final bool isIncome = tx["type"] == "INCOME";

                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncome
                                ? const Color(0xFFE6F4EA)
                                : const Color(0xFFFCE8E6),
                            child: Icon(
                              isIncome ? Icons.south_west : Icons.north_east,
                              color: isIncome ? Colors.green : Colors.redAccent,
                            ),
                          ),
                          title: Text(
                            tx["title"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${tx['counterparty']} • ${tx['date']}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            "${isIncome ? '+' : '-'}${tx['amount']} ₮",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isIncome ? Colors.green : Colors.redAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR уншуулах")),
      body: MobileScanner(
        onDetect: (capture) {
          if (_done || capture.barcodes.isEmpty) return;
          final raw = capture.barcodes.first.rawValue;
          if (raw == null || raw.isEmpty) return;
          _done = true;
          Navigator.pop(context, raw);
        },
      ),
    );
  }
}
