import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'api_service.dart';

const green = Color(0xFF14966A);
const navy = Color(0xFF17324D);

void main() => runApp(const SaharaApp());

class SaharaApp extends StatelessWidget {
  const SaharaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAHARA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: green,
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  bool authority = false;
  final id = TextEditingController(text: 'CASE_001');
  final password = TextEditingController(text: 'password');

  @override
  void dispose() {
    id.dispose();
    password.dispose();
    super.dispose();
  }

  void enter() {
    final value = id.text.trim();
    if (value.isEmpty) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => authority
            ? const AuthorityScreen()
            : ParticipantScreen(caseId: value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.shield,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'SAHARA',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: navy,
                          ),
                        ),
                        const Text(
                          'Support • Assessment • Human Assistance • Response',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'SECURE ACCESS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: green,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Welcome',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text('Choose how you would like to access SAHARA.'),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleButton(
                          active: !authority,
                          icon: Icons.person_outline,
                          label: 'Participant',
                          onTap: () {
                            setState(() {
                              authority = false;
                              id.text = 'CASE_001';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _RoleButton(
                          active: authority,
                          icon: Icons.admin_panel_settings_outlined,
                          label: 'Authority',
                          onTap: () {
                            setState(() {
                              authority = true;
                              id.text = 'AUTH_001';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    authority ? 'Authority ID' : 'Case ID',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: id,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: enter,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(
                        authority
                            ? 'Open authority console'
                            : 'Continue securely',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Privacy-first access with human oversight.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final bool active;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoleButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: active ? green.withValues(alpha: 0.1) : null,
          border: Border.all(
            color: active ? green : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? green : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantScreen extends StatefulWidget {
  final String caseId;

  const ParticipantScreen({super.key, required this.caseId});

  @override
  State<ParticipantScreen> createState() => _ParticipantState();
}

class _ParticipantState extends State<ParticipantScreen> {
  final text = TextEditingController();
  final recorder = AudioRecorder();
  String? audio;
  bool recording = false;
  bool busy = false;
  bool done = false;
  int seconds = 0;
  Timer? timer;

  void logout() {
    timer?.cancel();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> toggleRecord() async {
    if (recording) {
      audio = await recorder.stop();
      timer?.cancel();
      if (!mounted) return;
      setState(() => recording = false);
      return;
    }

    if (!await recorder.hasPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/sahara_${DateTime.now().millisecondsSinceEpoch}.wav';

    await recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );

    seconds = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => seconds++);
    });

    if (!mounted) return;
    setState(() {
      recording = true;
      audio = null;
    });
  }

  Future<void> submit() async {
    if (text.text.trim().isEmpty && audio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something or record a voice response.'),
        ),
      );
      return;
    }

    setState(() => busy = true);

    try {
      await ApiService.analyzeInteraction(
        caseId: widget.caseId,
        text: text.text,
        audioPath: audio,
      );

      if (!mounted) return;

      text.clear();
      audio = null;
      setState(() {
        done = true;
        busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not submit: $e')),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    recorder.dispose();
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAHARA'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'PRIVATE CHECK-IN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: green,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Share in your own words or voice. There is no right or wrong answer.',
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: done ? _successView() : _checkInView(),
            ),
          ),
          const SizedBox(height: 14),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                'Your privacy matters. Your assessment results are not shown here. Authorized support teams use submitted responses when additional support may be needed.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Need immediate help? Contact your designated helpline or local emergency service if you are in immediate danger.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _successView() {
    return Column(
      children: [
        const Icon(Icons.check_circle_outline, color: green, size: 55),
        const SizedBox(height: 12),
        const Text(
          'Thank you for checking in.',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 7),
        const Text('Your response has been securely recorded.'),
        const SizedBox(height: 15),
        OutlinedButton(
          onPressed: () => setState(() => done = false),
          child: const Text('Make another check-in'),
        ),
      ],
    );
  }

  Widget _checkInView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Case ID • ${widget.caseId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        const Text(
          'Write your response',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: text,
          maxLines: 7,
          decoration: const InputDecoration(
            hintText: 'Tell us anything you would like to share...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.mic_none, color: green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  recording
                      ? 'Recording ${seconds}s'
                      : audio != null
                          ? 'Voice recorded'
                          : 'Voice check-in',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: busy ? null : toggleRecord,
                icon: Icon(
                  recording ? Icons.stop_circle : Icons.mic,
                  color: green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: busy ? null : submit,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.arrow_forward),
            label: Text(busy ? 'Saving your check-in…' : 'Submit check-in'),
          ),
        ),
      ],
    );
  }
}

class AuthorityScreen extends StatefulWidget {
  const AuthorityScreen({super.key});

  @override
  State<AuthorityScreen> createState() => _AuthorityState();
}

class _AuthorityState extends State<AuthorityScreen> {
  List<dynamic> cases = [];
  bool loading = true;
  int tab = 0;
  String query = '';

  void logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> load() async {
    if (mounted) setState(() => loading = true);

    try {
      final result = await ApiService.getCases();
      if (!mounted) return;
      setState(() => cases = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backend unavailable: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = cases.where((item) {
      final caseId = (item['case_id'] ?? '').toString().toLowerCase();
      return caseId.contains(query.toLowerCase());
    }).toList();

    final urgent = cases.where((item) {
      return item['risk'] == 'High' || item['risk'] == 'Severe';
    }).length;

    final increasing = cases.where((item) {
      return item['trend'] == 'Increasing';
    }).length;

    final interactions = cases.fold<int>(0, (sum, item) {
      final value = item['interactions'];
      return sum + (value is num ? value.toInt() : 0);
    });

    final review = cases.where((item) {
      return item['risk'] != 'Low' || item['trend'] == 'Increasing';
    }).toList();

    final shown = tab == 0 ? review : filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Authority Console'),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (index) => setState(() => tab = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Cases',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'MoSJE • SIH 2026',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: green,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tab == 0 ? 'Authority overview' : 'Case monitoring',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const Text('Human-led monitoring and intervention workspace'),
                const SizedBox(height: 18),
                if (tab == 0) ...[
                  _Stats(
                    total: cases.length,
                    urgent: urgent,
                    increasing: increasing,
                    interactions: interactions,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Cases needing review',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                ],
                if (tab == 1) ...[
                  TextField(
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search Case ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (shown.isEmpty)
                  const _Empty(
                    title: 'No cases found',
                    subtitle:
                        'Cases will appear after a participant submits a check-in.',
                  ),
                for (final item in shown)
                  _CaseTile(
                    data: Map<String, dynamic>.from(item),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CaseDetailScreen(
                            caseId: item['case_id'].toString(),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

class _Stats extends StatelessWidget {
  final int total;
  final int urgent;
  final int increasing;
  final int interactions;

  const _Stats({
    required this.total,
    required this.urgent,
    required this.increasing,
    required this.interactions,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _Stat('Active cases', total, Icons.people_outline),
        _Stat('High / severe', urgent, Icons.warning_amber_rounded),
        _Stat('Increasing trend', increasing, Icons.trending_up),
        _Stat('Interactions', interactions, Icons.forum_outlined),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;

  const _Stat(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: green),
            const Spacer(),
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            Text(title, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CaseTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _CaseTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final risk = (data['risk'] ?? 'Unknown').toString();
    final trend = (data['trend'] ?? 'Stable').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: green.withValues(alpha: 0.1),
          child: const Icon(Icons.person_outline, color: green),
        ),
        title: Text(
          (data['case_id'] ?? 'Case').toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Distress ${data['score'] ?? '-'} / 24 • $trend\n'
          '${data['interactions'] ?? 0} interactions',
        ),
        isThreeLine: true,
        trailing: _RiskBadge(risk),
        onTap: onTap,
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String risk;

  const _RiskBadge(this.risk);

  @override
  Widget build(BuildContext context) {
    Color background = Colors.grey.shade200;
    Color foreground = Colors.grey.shade800;

    if (risk == 'Severe') {
      background = Colors.red.shade100;
      foreground = Colors.red.shade800;
    } else if (risk == 'High') {
      background = Colors.orange.shade100;
      foreground = Colors.orange.shade900;
    } else if (risk == 'Moderate') {
      background = Colors.amber.shade100;
      foreground = Colors.amber.shade900;
    } else if (risk == 'Low') {
      background = Colors.green.shade100;
      foreground = Colors.green.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        risk,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: foreground,
        ),
      ),
    );
  }
}

class CaseDetailScreen extends StatefulWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailState();
}

class _CaseDetailState extends State<CaseDetailScreen> {
  Map<String, dynamic>? summary;
  List<dynamic> history = [];
  bool loading = true;
  String? assignment;

  Future<void> load() async {
    try {
      final result = await Future.wait([
        ApiService.getSummary(widget.caseId),
        ApiService.getHistory(widget.caseId),
      ]);

      if (!mounted) return;

      setState(() {
        summary = result[0] as Map<String, dynamic>;
        final historyResult = result[1] as Map<String, dynamic>;
        history = List<dynamic>.from(historyResult['history'] ?? []);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to load case: $e')),
      );
    }
  }

  void showAssign() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  'Assign support',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text('Counsellor'),
                subtitle:
                    const Text('Psychosocial support and follow-up'),
                onTap: () {
                  setState(() => assignment = 'Counsellor');
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Police officer'),
                subtitle: const Text('Safety or protection response'),
                onTap: () {
                  setState(() => assignment = 'Police officer');
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.caseId)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final data = summary ?? <String, dynamic>{};
    final score = (data['current_score'] as num?)?.toDouble() ?? 0;
    final risk = (data['current_risk'] ?? '-').toString();
    final trend = (data['trend'] ?? '-').toString();
    final priority = (data['priority'] ?? '-').toString();
    final average =
        ((data['average_score'] as num?)?.toDouble() ?? 0).toStringAsFixed(1);
    final maximum =
        ((data['maximum_score'] as num?)?.toDouble() ?? 0).toStringAsFixed(1);
    final urgent =
        risk == 'High' || risk == 'Severe' || trend == 'Increasing';

    final values = history.map((item) {
      final map = Map<String, dynamic>.from(item);
      return (map['distress_score'] as num?)?.toDouble() ?? 0;
    }).toList();

    final children = <Widget>[
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CASE OVERVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: green,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  widget.caseId,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
              ],
            ),
          ),
          _RiskBadge(risk),
        ],
      ),
      const SizedBox(height: 14),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENT DISTRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      score.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: navy,
                      ),
                    ),
                    const Text('/ 24'),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Priority', style: TextStyle(fontSize: 11)),
                  Text(
                    priority,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Interactions', style: TextStyle(fontSize: 11)),
                  Text(
                    '${data['interaction_count'] ?? history.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(child: _Metric('Trend', trend, Icons.timeline)),
          const SizedBox(width: 8),
          Expanded(child: _Metric('Average', average, Icons.analytics_outlined)),
          const SizedBox(width: 8),
          Expanded(child: _Metric('Maximum', maximum, Icons.arrow_upward)),
        ],
      ),
    ];

    if (urgent) {
      children.addAll([
        const SizedBox(height: 14),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Intervention review recommended. This case has an elevated or increasing distress signal.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    if (assignment != null) {
      children.addAll([
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.check_circle, color: green),
            title: Text(
              '$assignment assigned',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Status: Pending'),
          ),
        ),
      ]);
    }

    children.addAll([
      const SizedBox(height: 20),
      const Text(
        'Longitudinal monitoring',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 7),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: values.isEmpty
              ? const SizedBox(
                  height: 190,
                  child: Center(
                    child: Text('Additional check-ins build the trend.'),
                  ),
                )
              : _DistressChart(values: values),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Operational action',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: showAssign,
            icon: const Icon(Icons.people_outline),
            label: const Text('Assign support'),
          ),
        ],
      ),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.support_agent, color: green),
              title: const Text('Assign counsellor'),
              subtitle:
                  const Text('Psychosocial support and follow-up'),
              trailing: const Icon(Icons.chevron_right),
              onTap: showAssign,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: green),
              title: const Text('Assign police officer'),
              subtitle: const Text('Safety or protection response'),
              trailing: const Icon(Icons.chevron_right),
              onTap: showAssign,
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'Participant responses',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 7),
      _Evidence(history: history),
      const SizedBox(height: 20),
      const Text(
        'Recorded interactions',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 7),
    ]);

    if (history.isEmpty) {
      children.add(
        const _Empty(
          title: 'No recorded interactions',
          subtitle: 'Additional check-ins will appear here.',
        ),
      );
    } else {
      for (int i = 0; i < history.length; i++) {
        children.add(
          _HistoryTile(
            index: i + 1,
            data: Map<String, dynamic>.from(history[i]),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caseId),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: children,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _Metric(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, size: 18, color: green),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;

  const _HistoryTile({required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    final score = (data['distress_score'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(radius: 15, child: Text('$index')),
        title: Text('Score ${score.toStringAsFixed(2)} / 24'),
        subtitle: Text(
          '${data['timestamp'] ?? ''} • ${data['risk_level'] ?? ''}',
        ),
        trailing: data['safety_signal'] != null
            ? const Icon(Icons.warning, color: Colors.orange)
            : null,
      ),
    );
  }
}

class _Evidence extends StatelessWidget {
  final List<dynamic> history;

  const _Evidence({required this.history});

  @override
  Widget build(BuildContext context) {
    final items = history.where((item) {
      final map = Map<String, dynamic>.from(item);
      return map['text_content'] != null ||
          map['audio_url'] != null ||
          map['transcription'] != null ||
          map['safety_signal'] != null;
    }).toList();

    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No response evidence has been recorded for this case yet.',
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final item in items)
          _EvidenceCard(data: Map<String, dynamic>.from(item)),
      ],
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _EvidenceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Text(
        data['timestamp']?.toString() ?? '',
        style: const TextStyle(fontSize: 11),
      ),
    ];

    if (data['safety_signal'] != null) {
      children.addAll([
        const SizedBox(height: 8),
        Text(
          data['safety_signal'].toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ]);
    }

    if (data['text_content'] != null) {
      children.addAll([
        const SizedBox(height: 9),
        const Text(
          'Text response',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(data['text_content'].toString()),
      ]);
    }

    if (data['transcription'] != null) {
      children.addAll([
        const SizedBox(height: 9),
        const Text(
          'Voice transcription',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(data['transcription'].toString()),
      ]);
    }

    if (data['audio_url'] != null) {
      children.addAll([
        const SizedBox(height: 9),
        const Row(
          children: [
            Icon(Icons.volume_up_outlined),
            SizedBox(width: 7),
            Text('Voice response recorded'),
          ],
        ),
      ]);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _DistressChart extends StatelessWidget {
  final List<double> values;

  const _DistressChart({required this.values});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: CustomPaint(painter: _ChartPainter(values)),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;

  _ChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final grid = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final y = 18 + (size.height - 42) * i / 4;
      canvas.drawLine(Offset(34, y), Offset(size.width - 8, y), grid);
    }

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : 38 + (size.width - 50) * i / (values.length - 1);
      final y = size.height -
          25 -
          (size.height - 55) * (values[i].clamp(0, 24) / 24);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, Paint()..color = green);
    }

    canvas.drawPath(path, line);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final value in [0, 6, 12, 18, 24]) {
      final y = size.height - 25 - (size.height - 55) * value / 24;
      textPainter.text = TextSpan(
        text: '$value',
        style: const TextStyle(fontSize: 9, color: Colors.grey),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 6));
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}

class _Empty extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Empty({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 38, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
