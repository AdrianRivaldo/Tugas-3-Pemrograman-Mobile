import 'dart:async';

import 'package:flutter/material.dart';

class CountdownStream extends StatefulWidget {
  final int totalDetik;
  final Color backgroundColor;

  const CountdownStream({
    super.key,
    this.totalDetik = 7845,
    this.backgroundColor = const Color(0xFF1a3a6b),
  });

  @override
  State<CountdownStream> createState() => _CountdownStreamState();
}

class _CountdownStreamState extends State<CountdownStream> {
  late Stream<int> _countdownStream;

  @override
  void initState() {
    super.initState();
    _countdownStream = _createCountdownStream(widget.totalDetik);
  }

  Stream<int> _createCountdownStream(int startDetik) async* {
    int sisa = startDetik;
    while (sisa > 0) {
      await Future.delayed(const Duration(seconds: 1));
      sisa--;
      yield sisa;
    }
  }

  String _formatWaktu(int totalDetik) {
    final jam = totalDetik ~/ 3600;
    final menit = (totalDetik % 3600) ~/ 60;
    final detik = totalDetik % 60;
    return '${jam.toString().padLeft(2, '0')}:'
        '${menit.toString().padLeft(2, '0')}:'
        '${detik.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _countdownStream,
      initialData: widget.totalDetik,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '️ Timer error',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final sisaDetik = snapshot.data ?? 0;

        if (sisaDetik <= 0) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Promo Berakhir!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Promo Kilat!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dapatkan diskon 20% untuk semua tiket VIP.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      _formatWaktu(sisaDetik),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
