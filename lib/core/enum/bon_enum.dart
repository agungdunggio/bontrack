import 'package:flutter/material.dart';

enum BonType { piutang, utang }

Color bonTypeColor(BonType type) {
  switch (type) {
    case BonType.piutang:
      return const Color(0xFF11998E);
    case BonType.utang:
      return const Color(0xFFFF512F);
  }
}