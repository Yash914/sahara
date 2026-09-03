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
  Widget build(BuildContext context) => MaterialApp(
    title: 'SAHARA', debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: green, scaffoldBackgroundColor: const Color(0xFFF6FAF8)),
    home: const LoginScreen(),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}
class _LoginState extends State<LoginScreen> {
  bool authority = false;
  final id = TextEditingController(text: 'CASE_001');
  final password = TextEditingController(text: 'password');
  @override void dispose() { id.dispose(); password.dispose(); super.dispose(); }
  void enter() {
    if (id.text.trim().isEmpty) return;
    final page = authority
      ? AuthorityScreen(logout: backToLogin)
      : ParticipantScreen(caseId: id.text.trim(), logout: backToLogin);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
  void backToLogin() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Column(children: [
                    Container(width: 54, height: 54, decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.shield_rounded, color: Colors.white, size: 30)),
                    const SizedBox(height: 10),
                    const Text('SAHARA', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: navy)),
                    const Text('Support • Assessment • Human Assistance • Response', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                  ])),
                  const SizedBox(height: 28),
                  const Text('SECURE ACCESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: green, letterSpacing: 1.2)),
                  const SizedBox(height: 5), const Text('Welcome', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5), const Text('Choose how you would like to access SAHARA.'), const SizedBox(height: 20),
                  Row(children: [
                    Expanded(child: _RoleTab(active: !authority, icon: Icons.person_outline, title: 'Participant', onTap: () => setState(() { authority = false; id.text = 'CASE_001'; }))),
                    const SizedBox(width: 10),
                    Expanded(child: _RoleTab(active: authority, icon: Icons.admin_panel_settings_outlined, title: 'Authority', onTap: () => setState(() { authority = true; id.text = 'AUTH_001'; }))),
                  ]),
                  const SizedBox(height: 20),
                  Text(authority ? 'Authority ID' : 'Case ID', style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 7),
                  TextField(controller: id, decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge_outlined))),
                  const SizedBox(height: 14), const Text('Password', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 7),
                  TextField(controller: password, obscureText: true, decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline))),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(onPressed: enter, icon: const Icon(Icons.arrow_forward), label: Text(authority ? 'Open authority console' : 'Continue securely'))),
                  const SizedBox(height: 14),
                  const Row(children: [Icon(Icons.verified_user_outlined, size: 16, color: green), SizedBox(width: 8), Expanded(child: Text('Privacy-first access with human oversight.', style: TextStyle(fontSize: 12)))])
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final bool active; final IconData icon; final String title; final VoidCallback onTap;
  const _RoleTab({required this.active, required this.icon, required this.title, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: active ? green.withValues(alpha: .10) : Colors.transparent, border: Border.all(color: active ? green : Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, color: active ? green : Colors.grey), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)))])));
}

class ParticipantScreen extends StatefulWidget {
  final String caseId; final VoidCallback logout;
  const ParticipantScreen({super.key, required this.caseId, required this.logout});
  @override State<ParticipantScreen> createState() => _ParticipantState();
}
class _ParticipantState extends State<ParticipantScreen> {
  final text = TextEditingController(); final recorder = AudioRecorder(); String? audio; bool recording = false, busy = false, done = false; int seconds = 0; Timer? timer;
  Future<void> toggleRecord() async {
    if (recording) { audio = await recorder.stop(); timer?.cancel(); setState(() => recording = false); return; }
    if (!await recorder.hasPermission()) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Microphone permission is required.'))); return; }
    final path = '${(await getTemporaryDirectory()).path}/sahara_${DateTime.now().millisecondsSinceEpoch}.wav';
    await recorder.start(const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1), path: path);
    seconds = 0; timer?.cancel(); timer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() => seconds++); });
    setState(() { recording = true; audio = null; });
  }
  Future<void> submit() async {
    if (text.text.trim().isEmpty && audio == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please write something or record a voice response.'))); return; }
    setState(() => busy = true);
    try { await ApiService.analyzeInteraction(caseId: widget.caseId, text: text.text, audioPath: audio); text.clear(); audio = null; setState(() => done = true); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit: $e'))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override void dispose() { timer?.cancel(); recorder.dispose(); text.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('SAHARA'), actions: [IconButton(onPressed: widget.logout, icon: const Icon(Icons.logout))]),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('PRIVATE CHECK-IN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: green, letterSpacing: 1.2)), const SizedBox(height: 6),
      const Text('How are you feeling today?', style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: navy)), const SizedBox(height: 7), const Text('Share in your own words or voice. There is no right or wrong answer.'), const SizedBox(height: 20),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: done ? _Success(onAgain: () => setState(() => done = false)) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Case ID • ${widget.caseId}', style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 16), const Text('Write your response', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 7),
        TextField(controller: text, maxLines: 7, decoration: const InputDecoration(hintText: 'Tell us anything you would like to share...', border: OutlineInputBorder(), alignLabelWithHint: true)), const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.mic_none, color: green), const SizedBox(width: 10), Expanded(child: Text(recording ? 'Recording ${seconds}s' : audio != null ? 'Voice recorded' : 'Voice check-in', style: const TextStyle(fontWeight: FontWeight.w600))), IconButton(onPressed: busy ? null : toggleRecord, icon: Icon(recording ? Icons.stop_circle : Icons.mic, color: green))])),
        const SizedBox(height: 18), SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(onPressed: busy ? null : submit, icon: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward), label: Text(busy ? 'Saving your check-in…' : 'Submit check-in')))
      ]))),
      const SizedBox(height: 14), const Card(child: Padding(padding: EdgeInsets.all(15), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.shield_outlined, color: green), SizedBox(width: 10), Expanded(child: Text('Your privacy matters. Your assessment results are not shown here. Authorized support teams use submitted responses when additional support may be needed.', style: TextStyle(fontSize: 12)))]))),
      const SizedBox(height: 12), const Card(child: Padding(padding: EdgeInsets.all(14), child: Text('Need immediate help? Contact your designated helpline or local emergency service if you are in immediate danger.', style: TextStyle(fontSize: 12))))
    ]),
  );
}
class _Success extends StatelessWidget { final VoidCallback onAgain; const _Success({required this.onAgain}); @override Widget build(BuildContext context) => Column(children: [Container(width: 64, height: 64, decoration: BoxDecoration(color: green.withValues(alpha: .12), shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline, color: green, size: 38)), const SizedBox(height: 14), const Text('Thank you for checking in.', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)), const SizedBox(height: 6), const Text('Your response has been securely recorded.'), const SizedBox(height: 16), OutlinedButton(onPressed: onAgain, child: const Text('Make another check-in'))]); }

class AuthorityScreen extends StatefulWidget { final VoidCallback logout; const AuthorityScreen({super.key, required this.logout}); @override State<AuthorityScreen> createState() => _AuthorityState(); }
class _AuthorityState extends State<AuthorityScreen> {
  List<dynamic> cases = []; bool loading = true; int tab = 0; String query = '';
  Future<void> load() async { if (mounted) setState(() => loading = true); try { cases = await ApiService.getCases(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backend unavailable: $e'))); } finally { if (mounted) setState(() => loading = false); } }
  @override void initState() { super.initState(); load(); }
  @override Widget build(BuildContext context) {
    final filtered = cases.where((x) => (x['case_id'] ?? '').toString().toLowerCase().contains(query.toLowerCase())).toList();
    final urgent = cases.where((x) => x['risk'] == 'High' || x['risk'] == 'Severe').length;
    final increasing = cases.where((x) => x['trend'] == 'Increasing').length;
    final interactions = cases.fold<int>(0, (n, x) => n + ((x['interactions'] is num) ? (x['interactions'] as num).toInt() : 0));
    return Scaffold(
      appBar: AppBar(title: const Text('Authority Console'), actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh)), IconButton(onPressed: widget.logout, icon: const Icon(Icons.logout))]),
      bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Overview'), NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Cases')]),
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 30), children: [
        const Text('MoSJE • SIH 2026', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: green, letterSpacing: 1)), const SizedBox(height: 4), Text(tab == 0 ? 'Authority overview' : 'Case monitoring', style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold, color: navy)), const Text('Human-led monitoring and intervention workspace'), const SizedBox(height: 18),
        if (tab == 0) ...[_StatGrid(total: cases.length, urgent: urgent, increasing: increasing, interactions: interactions), const SizedBox(height: 22), const Text('Cases needing review', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 10), if (cases.isEmpty) const _Empty(title: 'No active cases yet', subtitle: 'Cases will appear after a participant submits a check-in.'), for (final x in cases.where((x) => x['risk'] != 'Low' || x['trend'] == 'Increasing')) _CaseTile(data: Map<String, dynamic>.from(x), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailScreen(caseId: x['case_id'].toString()))))],
        if (tab == 1) ...[TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search Case ID', border: OutlineInputBorder())), const SizedBox(height: 14), if (filtered.isEmpty) const _Empty(title: 'No matching cases', subtitle: 'Try another Case ID.'), for (final x in filtered) _CaseTile(data: Map<String, dynamic>.from(x), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailScreen(caseId: x['case_id'].toString()))))]
      ]),
    );
  }
}
class _StatGrid extends StatelessWidget { final int total, urgent, increasing, interactions; const _StatGrid({required this.total, required this.urgent, required this.increasing, required this.interactions}); @override Widget build(BuildContext context) => GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.55, children: [_Stat('Active cases', total, Icons.people_outline), _Stat('High / severe', urgent, Icons.warning_amber_rounded), _Stat('Increasing trend', increasing, Icons.trending_up), _Stat('Interactions', interactions, Icons.forum_outlined)]); }
class _Stat extends StatelessWidget { final String title; final int value; final IconData icon; const _Stat(this.title, this.value, this.icon); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: green, size: 20), const Spacer(), Text('$value', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: navy)), Text(title, style: const TextStyle(fontSize: 12))]))); }
class _CaseTile extends StatelessWidget { final Map<String, dynamic> data; final VoidCallback onTap; const _CaseTile({required this.data, required this.onTap}); @override Widget build(BuildContext context) { final risk = (data['risk'] ?? 'Unknown').toString(); final trend = (data['trend'] ?? 'Stable').toString(); return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5), leading: CircleAvatar(backgroundColor: green.withValues(alpha: .10), child: const Icon(Icons.person_outline, color: green)), title: Text((data['case_id'] ?? 'Case').toString(), style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('Distress ${data['score'] ?? '-'} / 24 • $trend\n${data['interactions'] ?? 0} interactions'), isThreeLine: true, trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [_RiskBadge(risk), const SizedBox(height: 4), const Icon(Icons.chevron_right)]), onTap: onTap); } }
class _RiskBadge extends StatelessWidget { final String risk; const _RiskBadge(this.risk); @override Widget build(BuildContext context) { var bg = Colors.grey.shade200; var fg = Colors.grey.shade800; if (risk == 'Severe') { bg = Colors.red.shade100; fg = Colors.red.shade800; } else if (risk == 'High') { bg = Colors.orange.shade100; fg = Colors.orange.shade900; } else if (risk == 'Moderate') { bg = Colors.amber.shade100; fg = Colors.amber.shade900; } else if (risk == 'Low') { bg = Colors.green.shade100; fg = Colors.green.shade800; } return Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)), child: Text(risk, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg))); } }

class CaseDetailScreen extends StatefulWidget { final String caseId; const CaseDetailScreen({super.key, required this.caseId}); @override State<CaseDetailScreen> createState() => _CaseDetailState(); }
class _CaseDetailState extends State<CaseDetailScreen> {
  Map<String, dynamic>? summary; List<dynamic> history = []; bool loading = true; String? assignment;
  Future<void> load() async { try { final r = await Future.wait([ApiService.getSummary(widget.caseId), ApiService.getHistory(widget.caseId)]); final s = r[0] as Map<String, dynamic>; final h = r[1] as Map<String, dynamic>; if (mounted) setState(() { summary = s; history = List<dynamic>.from(h['history'] ?? []); loading = false; }); } catch (e) { if (mounted) { setState(() => loading = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to load case: $e'))); } } }
  void assign(String who) { setState(() => assignment = who); Navigator.pop(context); }
  void showAssign() => showModalBottomSheet(context: context, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [const Padding(padding: EdgeInsets.all(18), child: Text('Assign support', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), ListTile(leading: const Icon(Icons.support_agent), title: const Text('Counsellor'), subtitle: const Text('Psychosocial support and follow-up'), onTap: () => assign('Counsellor')), ListTile(leading: const Icon(Icons.shield_outlined), title: const Text('Police officer'), subtitle: const Text('Safety or protection response'), onTap: () => assign('Police officer')), const SizedBox(height: 12)])));
  @override void initState() { super.initState(); load(); }
  @override Widget build(BuildContext context) {
    final d = summary ?? <String, dynamic>{}; final score = (d['current_score'] as num?)?.toDouble() ?? 0; final risk = (d['current_risk'] ?? '-').toString(); final trend = (d['trend'] ?? '-').toString(); final priority = (d['priority'] ?? '-').toString(); final urgent = risk == 'High' || risk == 'Severe' || trend == 'Increasing'; final values = history.map((x) => ((x['distress_score'] as num?)?.toDouble() ?? 0)).toList();
    return Scaffold(appBar: AppBar(title: Text(widget.caseId), actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))]), body: loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(onRefresh: load, child: ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CASE OVERVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: green, letterSpacing: 1)), Text(widget.caseId, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: navy))])), _RiskBadge(risk)]), const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CURRENT DISTRESS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text(score.toStringAsFixed(1), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: navy)), const Text('/ 24')])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Priority', style: TextStyle(fontSize: 11)), Text(priority, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Interactions', style: TextStyle(fontSize: 11)), Text('${d['interaction_count'] ?? history.length}', style: const TextStyle(fontWeight: FontWeight.bold))])]))),
      const SizedBox(height: 10), Row(children: [Expanded(child: _Metric('Trend', trend, Icons.timeline)), const SizedBox(width: 8), Expanded(child: _Metric('Average', ((d['average_score'] as num?)?.toDouble() ?? 0).toStringAsFixed(1), Icons.analytics_outlined)), const SizedBox(width: 8), Expanded(child: _Metric('Maximum', ((d['maximum_score'] as num?)?.toDouble() ?? 0).toStringAsFixed(1), Icons.arrow_upward))]),
      if (urgent) ...[const SizedBox(height: 14), Card(color: Colors.orange.shade50, child: const Padding(padding: EdgeInsets.all(15), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.warning_amber_rounded), SizedBox(width: 10), Expanded(child: Text('Intervention review recommended. This case has an elevated or increasing distress signal. Authority review is required.', style: TextStyle(fontWeight: FontWeight.w600)))])))],
      if (assignment != null) ...[const SizedBox(height: 10), Card(child: ListTile(leading: const Icon(Icons.check_circle, color: green), title: Text('$assignment assigned', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${widget.caseId} • Status: Pending')))],
      const SizedBox(height: 20), const Text('Longitudinal monitoring', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 7), Card(child: Padding(padding: const EdgeInsets.all(12), child: values.isEmpty ? const SizedBox(height: 190, child: Center(child: Text('Additional check-ins build the trend.'))) : _DistressChart(values: values))),
      const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Operational action', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), TextButton.icon(onPressed: showAssign, icon: const Icon(Icons.people_outline), label: const Text('Assign support'))]),
      Card(child: Column(children: [ListTile(leading: const Icon(Icons.support_agent, color: green), title: const Text('Assign counsellor', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Psychosocial support and follow-up'), trailing: const Icon(Icons.chevron_right), onTap: showAssign), const Divider(height: 1), ListTile(leading: const Icon(Icons.shield_outlined, color: green), title: const Text('Assign police officer', style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('Safety or protection response'), trailing: const Icon(Icons.chevron_right), onTap: showAssign)])),
      const SizedBox(height: 20), const Text('Participant responses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 7), _Evidence(history: history),
      const SizedBox(height: 20), const Text('Recorded interactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 7), if (history.isEmpty) const _Empty(title: 'No recorded interactions', subtitle: 'Additional check-ins will appear here.'), for (int i = 0; i < history.length; i++) _HistoryTile(index: i + 1, data: Map<String, dynamic>.from(history[i]))
    ])));
  }
}
class _Metric extends StatelessWidget { final String title, value; final IconData icon; const _Metric(this.title, this.value, this.icon); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [Icon(icon, size: 18, color: green), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(title, style: const TextStyle(fontSize: 10))]))); }
class _HistoryTile extends StatelessWidget { final int index; final Map<String, dynamic> data; const _HistoryTile({required this.index, required this.data}); @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(radius: 15, child: Text('$index')), title: Text('Score ${((data['distress_score'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} / 24'), subtitle: Text('${data['timestamp'] ?? ''} • ${data['risk_level'] ?? ''}'), trailing: data['safety_signal'] != null ? const Icon(Icons.warning, color: Colors.orange) : null)); }
class _Evidence extends StatelessWidget { final List<dynamic> history; const _Evidence({required this.history}); @override Widget build(BuildContext context) { final items = history.where((x) { final m = Map<String, dynamic>.from(x); return m['text_content'] != null || m['audio_url'] != null || m['transcription'] != null || m['safety_signal'] != null; }).toList(); if (items.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No response evidence has been recorded for this case yet.'))); return Column(children: [for (final x in items) _EvidenceCard(data: Map<String, dynamic>.from(x))]); } }
class _EvidenceCard extends StatelessWidget { final Map<String, dynamic> data; const _EvidenceCard({required this.data}); @override Widget build(BuildContext context) { return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data['timestamp']?.toString() ?? '', style: const TextStyle(fontSize: 11)), if (data['safety_signal'] != null) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.all(8), color: const Color(0xFFFFF3E0), child: Text(data['safety_signal'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))], if (data['text_content'] != null) ...[const SizedBox(height: 9), const Text('Text response', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(data['text_content'].toString())], if (data['transcription'] != null) ...[const SizedBox(height: 9), const Text('Voice transcription', style: TextStyle(fontWeight: FontWeight.bold)), Text(data['transcription'].toString())], if (data['audio_url'] != null) ...[const SizedBox(height: 9), const Row(children: [Icon(Icons.volume_up_outlined), SizedBox(width: 7), Text('Voice response recorded')])] ))); } }
class _DistressChart extends StatelessWidget { final List<double> values; const _DistressChart({required this.values}); @override Widget build(BuildContext context) => SizedBox(height: 220, child: CustomPaint(painter: _ChartPainter(values))); }
class _ChartPainter extends CustomPainter { final List<double> values; _ChartPainter(this.values); @override void paint(Canvas canvas, Size size) { final line = Paint()..color = green..strokeWidth = 3..style = PaintingStyle.stroke; final grid = Paint()..color = Colors.grey.withValues(alpha: .2)..strokeWidth = 1; for (int i = 0; i < 5; i++) { final y = 18 + (size.height - 42) * i / 4; canvas.drawLine(Offset(34, y), Offset(size.width - 8, y), grid); } final path = Path(); for (int i = 0; i < values.length; i++) { final x = values.length == 1 ? size.width / 2 : 38 + (size.width - 50) * i / (values.length - 1); final y = size.height - 25 - (size.height - 55) * (values[i].clamp(0, 24) / 24); if (i == 0) path.moveTo(x, y); else path.lineTo(x, y); canvas.drawCircle(Offset(x, y), 4, Paint()..color = green); } canvas.drawPath(path, line); final tp = TextPainter(textDirection: TextDirection.ltr); for (final v in [0, 6, 12, 18, 24]) { final y = size.height - 25 - (size.height - 55) * v / 24; tp.text = TextSpan(text: '$v', style: const TextStyle(fontSize: 9, color: Colors.grey)); tp.layout(); tp.paint(canvas, Offset(5, y - 6)); } } @override bool shouldRepaint(covariant _ChartPainter oldDelegate) => oldDelegate.values != values; }
class _Empty extends StatelessWidget { final String title, subtitle; const _Empty({required this.title, required this.subtitle}); @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(25), child: Column(children: [const Icon(Icons.inbox_outlined, size: 38, color: Colors.grey), const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))]))); }
