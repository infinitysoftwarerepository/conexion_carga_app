import 'package:flutter/material.dart';

import 'package:conexion_carga_app/app/widgets/load_card.dart';
import 'package:conexion_carga_app/features/loads/data/loads_api.dart';
import 'package:conexion_carga_app/features/loads/domain/trip.dart';
import 'package:conexion_carga_app/features/loads/presentation/pages/trip_detail_page.dart';
import 'package:conexion_carga_app/core/auth_session.dart';

class MyLoadsPage extends StatefulWidget {
  const MyLoadsPage({super.key});

  @override
  State<MyLoadsPage> createState() => _MyLoadsPageState();
}

class _MyLoadsPageState extends State<MyLoadsPage> {
  late Future<List<Trip>> _future;

  @override
  void initState() {
    super.initState();
    _future = LoadsApi.fetchMine(status: 'all');
  }

  Future<void> _refresh() async {
    setState(() {
      _future = LoadsApi.fetchMine(status: 'all');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis viajes')),
      body: FutureBuilder<List<Trip>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final items = snap.data ?? <Trip>[];
          if (items.isEmpty) {
            return const Center(child: Text('No tienes viajes publicados.'));
          }

          final myId = AuthSession.instance.user.value?.id ?? '';

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final t = items[i];
                final isMine = (t.comercialId ?? '') == myId;

                // ✅ No pasamos onTap a LoadCard (no existe). Envolvemos la card.
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TripDetailPage(trip: t)),
                      );
                      // refrescar al volver (por si se eliminó o editó)
                      await _refresh();
                    },
                    child: LoadCard(
                      trip: t,
                      isMine: isMine,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
