// lib/features/loads/presentation/pages/points_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:conexion_carga_app/core/env.dart';
import 'package:conexion_carga_app/core/auth_session.dart';
import 'package:conexion_carga_app/app/widgets/theme_toggle.dart';
import 'package:conexion_carga_app/app/theme/theme_conection.dart';

class PointsPage extends StatefulWidget {
  const PointsPage({super.key});

  @override
  State<PointsPage> createState() => _PointsPageState();
}

class _PointsPageState extends State<PointsPage> {
  bool _loading = true;
  String? _error;

  // filas ya ordenadas por puntos (desc)
  List<_Row> _items = [];

  String get _firstName {
    final u = AuthSession.instance.user.value;
    final fn = (u?.firstName ?? '').trim();
    return fn.isEmpty ? 'Usuario' : fn;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('${Env.baseUrl}/api/users?limit=1000');
      final res = await http.get(uri).timeout(const Duration(seconds: 12));

      if (res.statusCode != 200) {
        throw Exception('No se pudo obtener el top (${res.statusCode}).');
      }

      final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;

      // Usuario actual para decidir si se enmascara o no
      final me = AuthSession.instance.user.value;
      final myEmail = (me?.email ?? '').toLowerCase();

      final rows = <_Row>[];
      for (final it in data) {
        final m = (it as Map).cast<String, dynamic>();
        final email = (m['email'] ?? '').toString();
        final phone = (m['phone'] ?? '').toString(); // tu cédula/N° doc
        final pts = (m['points'] is int)
            ? m['points'] as int
            : int.tryParse('${m['points']}') ?? 0;

        rows.add(_Row(
          email: email,
          maskedEmail:
              email.toLowerCase() == myEmail ? email : _maskEmail(email),
          idLast4: _last4(phone),
          points: pts,
        ));
      }

      // Ordena por puntos descendente
      rows.sort((a, b) => b.points.compareTo(a.points));

      setState(() {
        _items = rows;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Enmascara email excepto el actual (p.e. j*****2@gmail.com)
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final user = parts[0];
    final domain = parts[1];
    if (user.length <= 2) return '${user[0]}*****@$domain';
    return '${user[0]}*****${user[user.length - 1]}@$domain';
  }

  String _last4(String v) {
    final s = v.trim();
    if (s.length <= 4) return s;
    return '...${s.substring(s.length - 4)}';
  }

  // ────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        title: const Text('Top Puntajes'),
        // subtítulo compacto
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(5),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '¡ Aumenta tus puntos $_firstName !',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: cs.onSecondaryContainer.withOpacity(0.9)),
            ),
          ),
        ),
        actions: const [
          // botón de recarga
  
          ThemeToggle(size: 22),
          SizedBox(width: 8),
        ],
      ),
      body: _Body(
        loading: _loading,
        error: _error,
        items: _items,
        onRefresh: _load,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.loading,
    required this.error,
    required this.items,
    required this.onRefresh,
  });

  final bool loading;
  final String? error;
  final List<_Row> items;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.error),
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── encabezado/rotulos ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Container(
            decoration: BoxDecoration(
              color: (isLight ? kBrandGreen : kDeepDarkGreen)
                  .withOpacity(isLight ? 0.85 : 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: const [
                _HeaderCell(label: 'Top', flex: 16),
                _HeaderCell(label: 'e-mail', flex: 38),
                _HeaderCell(label: 'ID', flex: 24),
                _HeaderCell(label: 'Puntos', flex: 22),
              ],
            ),
          ),
        ),

        // ── lista ────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final r = items[i];
                final rank = i + 1;
                return _RowTile(row: r, rank: rank);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.label, required this.flex});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────
// Row visual
// ────────────────────────────────────────────────────────────
class _RowTile extends StatelessWidget {
  const _RowTile({required this.row, required this.rank});

  final _Row row;
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.05 : 0.20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: (isLight ? Colors.black12 : Colors.white10),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          // TOP: medalla + # (centrado)
          Expanded(
            flex: 16,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    rank == 1
                        ? Icons.emoji_events
                        : rank == 2
                            ? Icons.emoji_events
                            : rank == 3
                                ? Icons.emoji_events
                                : Icons.emoji_events_outlined,
                    size: 18,
                    color: rank == 1
                        ? const Color(0xFFFFC107) // oro
                        : rank == 2
                            ? const Color(0xFFB0BEC5) // plata
                            : rank == 3
                                ? const Color(0xFFCD7F32) // bronce
                                : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$rank',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // E-MAIL (una sola línea, centrado)
          Expanded(
            flex: 38,
            child: Center(
              child: Text(
                row.maskedEmail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),

          // ID (últimos 4, centrado)
          Expanded(
            flex: 24,
            child: Center(
              child: Text(
                row.idLast4,
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: const TextStyle(letterSpacing: .3),
              ),
            ),
          ),

          // PUNTOS (píldora verde)
          Expanded(
            flex: 22,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isLight ? kGreenStrong : kDarkGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${row.points}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Datos mínimos de cada fila
class _Row {
  final String email;
  final String maskedEmail; // ya viene enmascarado si NO es el usuario actual
  final String idLast4; // …1234
  final int points;

  _Row({
    required this.email,
    required this.maskedEmail,
    required this.idLast4,
    required this.points,
  });
}

// Botón de refresco en AppBar (separado para mantener AppBar liviano)
class _RefreshButton extends StatelessWidget {
  const _RefreshButton();

  @override
  Widget build(BuildContext context) {
    // Busca el State hacia arriba para llamar _load()
    final state =
        context.findAncestorStateOfType<_PointsPageState>(); // puede ser null
    return IconButton(
      tooltip: 'Actualizar',
      icon: const Icon(Icons.refresh),
      onPressed: state?._load,
    );
  }
}
