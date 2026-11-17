
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final String? label;
  final double iconSize;
  final bool neutral;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.label,
    this.iconSize = 42,
    this.neutral = false,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = _ImageFallback(
      label: label,
      iconSize: iconSize,
      neutral: neutral,
    );

    final url = imageUrl?.trim() ?? '';
    final catalogo = _catalogAsset(label);

    // Fotos locales para los productos cuya URL de internet no carga en el navegador.
    if (catalogo != null) {
      return Image.asset(
        catalogo,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error cargando imagen local: $catalogo');
          debugPrint('$error');
          return fallback;
        },
      );
    }

    // Si no existe una ruta, mostrar el icono predeterminado.
    if (url.isEmpty) {
      return fallback;
    }

    // Identificar si el producto es un balon de futbol.
    final nombreProducto = (label ?? '').toLowerCase();

    final esBalon = nombreProducto.contains('balon') ||
        nombreProducto.contains('balón');

    // IMAGEN LOCAL DE FLUTTER
    if (url.startsWith('assets/')) {
      return Padding(
        // Reducir solamente el tamaño del balon.
        padding: EdgeInsets.all(esBalon ? 35.0 : 0.0),
        child: Image.asset(
          url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error cargando imagen local: $url');
            debugPrint('$error');
            return fallback;
          },
        ),
      );
    }

    // IMAGEN DESDE INTERNET O SERVIDOR NODE.JS
    final uri = Uri.tryParse(url);

    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(esBalon ? 35.0 : 0.0),
        child: Image.network(
          url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error cargando imagen de Internet: $url');
            debugPrint('$error');
            return fallback;
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) {
              return child;
            }

            return fallback;
          },
        ),
      );
    }

    // Ruta no reconocida.
    debugPrint('Ruta de imagen no válida: $url');
    return fallback;
  }

  static String? _catalogAsset(String? label) {
    final value = (label ?? '').toLowerCase();

    if (value.contains('camiseta')) return 'assets/images/camiseta.jpg';
    if (value.contains('chaqueta')) return 'assets/images/chaqueta.jpg';
    if (value.contains('mancuerna')) return 'assets/images/mancuernas.jpg';
    if (value.contains('laptop') ||
        value.contains('ultrabook') ||
        value.contains('portatil') ||
        value.contains('portátil')) {
      return 'assets/images/laptop.jpg';
    }
    if (value.contains('lampara') || value.contains('lámpara')) {
      return 'assets/images/lampara.jpg';
    }
    if (value.contains('sabana') ||
        value.contains('sábana') ||
        value.contains('sabanas')) {
      return 'assets/images/sabanas.jpg';
    }

    return null;
  }
}

// ===================================================
// IMAGEN DE RESPALDO CUANDO NO EXISTE UNA FOTOGRAFIA
// ===================================================

class _ImageFallback extends StatelessWidget {
  final String? label;
  final double iconSize;
  final bool neutral;

  const _ImageFallback({
    required this.label,
    required this.iconSize,
    required this.neutral,
  });

  static const _palettes = [
    [Color(0xFF1B4F72), Color(0xFF5DADE2)],
    [Color(0xFF1A5276), Color(0xFF48C9B0)],
    [Color(0xFF6C3483), Color(0xFFBB8FCE)],
    [Color(0xFF1E8449), Color(0xFF7DCEA0)],
    [Color(0xFFB9770E), Color(0xFFF5CBA7)],
    [Color(0xFF922B21), Color(0xFFE6B0AA)],
  ];

  @override
  Widget build(BuildContext context) {
    final name = label ?? '';

    if (neutral) {
      return ColoredBox(
        color: const Color(0xFFF4F6F8),
        child: Center(
          child: Icon(
            _iconFor(name),
            size: iconSize,
            color: const Color(0xFF98A2B3),
          ),
        ),
      );
    }

    final palette =
        _palettes[name.hashCode.abs() % _palettes.length];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette,
        ),
      ),
      child: Center(
        child: Icon(
          _iconFor(name),
          size: iconSize,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    final value = name.toLowerCase();

    if (value.contains('laptop') ||
        value.contains('tablet')) {
      return Icons.laptop_mac_outlined;
    }

    if (value.contains('smart') ||
        value.contains('phone') ||
        value.contains('auricular')) {
      return Icons.smartphone_outlined;
    }

    if (value.contains('chaqueta') ||
        value.contains('camiseta') ||
        value.contains('jean') ||
        value.contains('ropa')) {
      return Icons.checkroom_outlined;
    }

    if (value.contains('sabana') ||
        value.contains('sábana') ||
        value.contains('hogar')) {
      return Icons.bed_outlined;
    }

    if (value.contains('lampara') ||
        value.contains('lámpara')) {
      return Icons.light_outlined;
    }

    if (value.contains('balon') ||
        value.contains('balón') ||
        value.contains('futbol')) {
      return Icons.sports_soccer_outlined;
    }

    if (value.contains('mancuerna')) {
      return Icons.fitness_center_outlined;
    }

    return Icons.shopping_bag_outlined;
  }
}
