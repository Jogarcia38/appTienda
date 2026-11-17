import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/store_style.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  final _gridController = ScrollController();

  final Set<int> _categories = {};
  final Set<String> _priceBands = {};
  final Set<String> _colors = {};
  final Set<int> _ratings = {};
  final Set<String> _shipping = {};
  final Set<int> _favorites = {};

  final Map<String, bool> _open = {
    'category': true,
    'price': true,
    'color': true,
    'rating': true,
    'shipping': true,
  };

  String _sort = 'ratings';
  bool _english = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minController.dispose();
    _maxController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final products = context.read<ProductProvider>();
    await products.loadCategories();
    if (!mounted) return;
    await products.loadProducts();
    if (!mounted) return;
    await context.read<CartProvider>().loadCart();
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.read<CartProvider>().clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openCart() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
    );
  }

  Future<void> _add(Product product) async {
    final cart = context.read<CartProvider>();
    final ok = await cart.addToCart(product.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (_english ? '${product.name} added to cart' : '${product.name} agregado al carrito')
              : (cart.error ?? (_english ? 'Could not add the product' : 'No se pudo agregar')),
        ),
      ),
    );
  }

  String _t(String en, String es) => _english ? en : es;

  void _clearFilters() {
    setState(() {
      _categories.clear();
      _priceBands.clear();
      _colors.clear();
      _ratings.clear();
      _shipping.clear();
      _minController.clear();
      _maxController.clear();
    });
  }

  double? _readPrice(TextEditingController controller) {
    final text = controller.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  bool _matchesBand(double price, String band) {
    switch (band) {
      case '0-50':
        return price <= 50;
      case '50-75':
        return price >= 50 && price <= 75;
      case '75-150':
        return price >= 75 && price <= 150;
      case '150+':
        return price > 150;
    }
    return true;
  }

  List<Product> _visible(List<Product> source) {
    final minPrice = _readPrice(_minController);
    final maxPrice = _readPrice(_maxController);
    final query = _query.trim().toLowerCase();

    final items = source.where((product) {
      final facts = ProductFacts.of(product);
      if (_categories.isNotEmpty && !_categories.contains(product.categoryId)) return false;
      if (_colors.isNotEmpty && !_colors.contains(facts.color)) return false;
      if (_shipping.isNotEmpty && !_shipping.contains(facts.shipping)) return false;
      if (_ratings.isNotEmpty && !_ratings.any((threshold) => facts.stars > threshold)) {
        return false;
      }
      if (_priceBands.isNotEmpty && !_priceBands.any((band) => _matchesBand(product.price, band))) {
        return false;
      }
      if (minPrice != null && product.price < minPrice) return false;
      if (maxPrice != null && product.price > maxPrice) return false;
      if (query.isNotEmpty) {
        final haystack = '${product.name} ${product.categoryName ?? ''} ${product.description ?? ''}'
            .toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();

    items.sort((a, b) {
      switch (_sort) {
        case 'price-asc':
          return a.price.compareTo(b.price);
        case 'price-desc':
          return b.price.compareTo(a.price);
        case 'name':
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        default:
          final byStars = ProductFacts.of(b).stars.compareTo(ProductFacts.of(a).stars);
          if (byStars != 0) return byStars;
          return ProductFacts.of(b).reviews.compareTo(ProductFacts.of(a).reviews);
      }
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();
    final products = _visible(productProvider.products);

    final viewport = MediaQuery.sizeOf(context).width;
    final wide = viewport >= 1180;
    final showFilters = viewport >= 1080;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: StoreColors.canvasMid,
      drawer: showFilters
          ? null
          : Drawer(
              width: 320,
              backgroundColor: Colors.white,
              child: SafeArea(child: _filters(productProvider)),
            ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [StoreColors.canvasTop, StoreColors.canvasMid, StoreColors.canvasBottom],
          ),
        ),
        child: Stack(
          children: [
            const _Blob(top: -140, left: -90, size: 460, color: Color(0x33FFFFFF)),
            const _Blob(top: 80, right: -120, size: 520, color: Color(0x2EFFFFFF)),
            const _Blob(bottom: -180, left: 40, size: 420, color: Color(0x2667B7AE)),
            const _Blob(bottom: -60, right: 160, size: 280, color: Color(0x2267B7AE)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A0C3C38),
                            blurRadius: 36,
                            offset: Offset(0, 16),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Row(
                          children: [
                            if (wide) _sidebar(auth.user?.name ?? ''),
                            Expanded(
                              child: Column(
                                children: [
                                  _header(cart.itemCount, showFilters),
                                  const Divider(height: 1, color: StoreColors.line),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        if (showFilters)
                                          SizedBox(
                                            width: 268,
                                            child: DecoratedBox(
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  right: BorderSide(color: StoreColors.line),
                                                ),
                                              ),
                                              child: _filters(productProvider),
                                            ),
                                          ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              _productsHeader(products, productProvider),
                                              Expanded(
                                                child: LayoutBuilder(
                                                  builder: (context, gridConstraints) {
                                                    return _grid(
                                                      productProvider,
                                                      products,
                                                      gridConstraints.maxWidth,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebar(String name) {
    final initial = name.trim().isEmpty ? 'C' : name.trim()[0].toUpperCase();
    final items = <_RailItem>[
      _RailItem(Icons.grid_view_rounded, _scrollTop),
      _RailItem(Icons.inventory_2_outlined, () => _soon('Inventory')),
      _RailItem(Icons.shopping_bag_outlined, _openCart),
      _RailItem(Icons.sell_outlined, () => _soon('Offers')),
      _RailItem(Icons.calendar_today_outlined, () => _soon('Calendar')),
      _RailItem(Icons.chat_bubble_outline, () => _soon('Messages')),
      _RailItem(Icons.notifications_none, () => _soon('Notifications')),
      _RailItem(Icons.bar_chart_outlined, () => _soon('Reports')),
      _RailItem(Icons.star_border_rounded, () => _soon('Favorites')),
      _RailItem(Icons.info_outline, () => _soon('About')),
      _RailItem(Icons.settings_outlined, _logout),
    ];

    return SizedBox(
      width: 76,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(right: BorderSide(color: StoreColors.line)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _PlusButton(onTap: _scrollTop),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 6),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return IconButton(
                    onPressed: item.onTap,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 40),
                    icon: Icon(item.icon, size: 22, color: const Color(0xFF98A2B3)),
                  );
                },
              ),
            ),
            PopupMenuButton<String>(
              tooltip: name,
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Text(_t('Log out', 'Cerrar sesión')),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFD9E4EA),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: StoreColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(int cartCount, bool filtersVisible) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            if (!filtersVisible)
              IconButton(
                tooltip: _t('Filters', 'Filtros'),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.tune_rounded, color: StoreColors.label),
              ),
            const _LogoMark(),
            const SizedBox(width: 10),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Corelystics Store',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: StoreColors.ink,
                        fontSize: 14,
                      ),
                    ),
                    const TextSpan(
                      text: '  ›  ',
                      style: TextStyle(color: StoreColors.muted, fontSize: 14),
                    ),
                    TextSpan(
                      text: _t('Products', 'Productos'),
                      style: const TextStyle(color: StoreColors.muted, fontSize: 14),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _t('Search Products...', 'Buscar productos...'),
                      hintStyle: const TextStyle(color: Color(0xFFB4BCC8), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFB4BCC8), size: 20),
                      suffixIcon: const Icon(Icons.tune_rounded, color: Color(0xFF98A2B3), size: 18),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: StoreColors.teal),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<bool>(
              tooltip: _t('Language', 'Idioma'),
              onSelected: (value) => setState(() => _english = value),
              itemBuilder: (context) => const [
                PopupMenuItem(value: true, child: Text('English')),
                PopupMenuItem(value: false, child: Text('Español')),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Row(
                  children: [
                    const Text('🇬🇧', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      _english ? 'EN' : 'ES',
                      style: const TextStyle(
                        color: StoreColors.en,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: StoreColors.muted),
                  ],
                ),
              ),
            ),
            _roundIcon(Icons.mail_outline, onTap: () => _soon(_t('Messages', 'Mensajes'))),
            _roundIcon(
              Icons.shopping_cart_outlined,
              onTap: _openCart,
              badge: cartCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _productsHeader(List<Product> products, ProductProvider provider) {
    String subtitle = _t(
      'Showing ${products.length} Products',
      'Mostrando ${products.length} productos',
    );
    if (_categories.length == 1) {
      final match = provider.categories.where((c) => c.id == _categories.first);
      if (match.isNotEmpty) {
        subtitle = _t(
          'Showing ${products.length} Products for "${match.first.name}"',
          'Mostrando ${products.length} productos de "${match.first.name}"',
        );
      }
    }

    final sortLabel = switch (_sort) {
      'price-asc' => _t('Price ↑', 'Precio ↑'),
      'price-desc' => _t('Price ↓', 'Precio ↓'),
      'name' => _t('Name', 'Nombre'),
      _ => _t('Ratings', 'Valoración'),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 18, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _t('Products', 'Productos'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: StoreColors.ink,
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: _t('More', 'Más'),
                      icon: const Icon(Icons.more_horiz, color: StoreColors.muted),
                      onSelected: (value) {
                        if (value == 'refresh') _load();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(value: 'refresh', child: Text(_t('Refresh', 'Actualizar'))),
                      ],
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.5, color: StoreColors.muted),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: _t('Sort', 'Ordenar'),
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'ratings', child: Text(_t('Ratings', 'Valoración'))),
              PopupMenuItem(value: 'price-asc', child: Text(_t('Price: Low to High', 'Precio: menor a mayor'))),
              PopupMenuItem(value: 'price-desc', child: Text(_t('Price: High to Low', 'Precio: mayor a menor'))),
              PopupMenuItem(value: 'name', child: Text(_t('Name', 'Nombre'))),
            ],
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    _t('Sort by', 'Ordenar'),
                    style: const TextStyle(color: StoreColors.muted, fontSize: 13),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star_rounded, color: StoreColors.star, size: 16),
                  const SizedBox(width: 2),
                  Text(
                    sortLabel,
                    style: const TextStyle(
                      color: StoreColors.ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, size: 18, color: StoreColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(ProductProvider provider) {
    final chips = <_FilterChipData>[
      for (final id in _categories)
        if (provider.categories.any((c) => c.id == id))
          _FilterChipData(
            _t('Category', 'Categoría'),
            provider.categories.firstWhere((c) => c.id == id).name,
            () => setState(() => _categories.remove(id)),
          ),
      for (final band in _priceBands)
        _FilterChipData(_t('Price', 'Precio'), _bandLabel(band), () => setState(() => _priceBands.remove(band))),
      for (final color in _colors)
        _FilterChipData(_t('Color', 'Color'), _colorLabel(color), () => setState(() => _colors.remove(color))),
      for (final rating in _ratings)
        _FilterChipData(_t('Rating', 'Valoración'), '>$rating', () => setState(() => _ratings.remove(rating))),
      for (final option in _shipping)
        _FilterChipData(
          _t('Shipping', 'Envío'),
          _shippingLabel(option),
          () => setState(() => _shipping.remove(option)),
        ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            const Icon(Icons.tune_rounded, size: 18, color: StoreColors.ink),
            const SizedBox(width: 8),
            Text(
              _t('Filters', 'Filtros'),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: StoreColors.ink),
            ),
            const Spacer(),
            TextButton(
              onPressed: _clearFilters,
              style: TextButton.styleFrom(
                foregroundColor: StoreColors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(_t('Clear All', 'Limpiar'), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final chip in chips)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: StoreColors.chip,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${chip.group}: ${chip.value}',
                        style: const TextStyle(fontSize: 11, color: StoreColors.label),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: chip.onRemove,
                        child: const Icon(Icons.close, size: 13, color: StoreColors.muted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        _section(
          'category',
          _t('Category', 'Categoría'),
          children: [
            for (final category in provider.categories)
              _checkRow(
                category.name,
                _categories.contains(category.id),
                () => setState(() {
                  if (!_categories.add(category.id)) _categories.remove(category.id);
                }),
              ),
            if (provider.categories.isEmpty)
              Text(
                _t('No categories', 'Sin categorías'),
                style: const TextStyle(color: StoreColors.muted, fontSize: 12),
              ),
          ],
        ),
        _section(
          'price',
          _t('Price', 'Precio'),
          children: [
            _checkRow(r'$0–$50', _priceBands.contains('0-50'), () => _toggleBand('0-50')),
            _checkRow(r'$50–$75', _priceBands.contains('50-75'), () => _toggleBand('50-75')),
            _checkRow(r'$75–$150', _priceBands.contains('75-150'), () => _toggleBand('75-150')),
            _checkRow(_t('Over \$150', 'Más de \$150'), _priceBands.contains('150+'), () => _toggleBand('150+')),
            const SizedBox(height: 8),
            Row(
              children: [
                _priceField(_minController, _t('Min', 'Mín')),
                const SizedBox(width: 10),
                _priceField(_maxController, _t('Max', 'Máx')),
              ],
            ),
          ],
        ),
        _section(
          'color',
          _t('Color', 'Color'),
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                _colorDot('Red', const Color(0xFFE11D48)),
                _colorDot('Blue', const Color(0xFF3B82F6)),
                _colorDot('Orange', const Color(0xFFF59E0B)),
                _colorDot('Black', const Color(0xFF111827)),
              ],
            ),
          ],
        ),
        _section(
          'rating',
          _t('Rating', 'Valoración'),
          children: [
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in [4, 3, 2, 1]) _ratingChip(value),
              ],
            ),
          ],
        ),
        _section(
          'shipping',
          _t('Shipping Options', 'Opciones de envío'),
          children: [
            for (final option in ProductFacts.shippings)
              _checkRow(
                _shippingLabel(option),
                _shipping.contains(option),
                () => setState(() {
                  if (!_shipping.add(option)) _shipping.remove(option);
                }),
              ),
          ],
        ),
      ],
    );
  }

  Widget _section(String key, String title, {required List<Widget> children}) {
    final open = _open[key] ?? true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _open[key] = !open),
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: StoreColors.ink,
                    ),
                  ),
                ),
                Icon(
                  open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 18,
                  color: StoreColors.muted,
                ),
              ],
            ),
          ),
        ),
        if (open) ...children,
      ],
    );
  }

  Widget _checkRow(String label, bool checked, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: checked ? StoreColors.teal : Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: checked ? StoreColors.teal : const Color(0xFFD0D5DD)),
              ),
              child: checked ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13, color: StoreColors.label)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceField(TextEditingController controller, String caption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          height: 34,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: '0',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: StoreColors.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: StoreColors.teal),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(caption, style: const TextStyle(fontSize: 10, color: StoreColors.muted)),
      ],
    );
  }

  Widget _colorDot(String name, Color color) {
    final selected = _colors.contains(name);
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => setState(() {
          if (!_colors.add(name)) _colors.remove(name);
        }),
        customBorder: const CircleBorder(),
        child: Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? StoreColors.teal : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _ratingChip(int threshold) {
    final selected = _ratings.contains(threshold);
    return InkWell(
      onTap: () => setState(() {
        if (!_ratings.add(threshold)) _ratings.remove(threshold);
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7F6F4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 15, color: StoreColors.star),
            Text(
              '>$threshold',
              style: const TextStyle(fontSize: 12, color: StoreColors.label, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grid(ProductProvider provider, List<Product> products, double width) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: StoreColors.teal));
    }

    if (provider.error != null && provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(provider.error!, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: Text(_t('Retry', 'Reintentar'))),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Text(
          _t('No products match these filters', 'No hay productos con estos filtros'),
          style: const TextStyle(color: StoreColors.muted),
        ),
      );
    }

    final columns = width >= 900 ? 4 : width >= 620 ? 3 : 2;

    return GridView.builder(
      controller: _gridController,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisExtent: columns >= 4 ? 348 : 360,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          favorite: _favorites.contains(product.id),
          english: _english,
          addLabel: _t('Add to Cart', 'Agregar'),
          onTap: () => _openProduct(product),
          onFavorite: () => setState(() {
            if (!_favorites.add(product.id)) _favorites.remove(product.id);
          }),
          onAddToCart: () => _add(product),
        );
      },
    );
  }

  Widget _roundIcon(IconData icon, {required VoidCallback onTap, int badge = 0}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: badge > 0
              ? Badge(
                  label: Text('$badge'),
                  backgroundColor: StoreColors.teal,
                  child: Icon(icon, size: 18, color: StoreColors.label),
                )
              : Icon(icon, size: 18, color: StoreColors.label),
        ),
      ),
    );
  }

  void _toggleBand(String band) {
    setState(() {
      if (!_priceBands.add(band)) _priceBands.remove(band);
    });
  }

  void _scrollTop() {
    if (_gridController.hasClients) {
      _gridController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  void _soon(String section) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_english ? '$section is not available yet' : '$section todavía no está disponible')),
    );
  }

  String _bandLabel(String band) {
    switch (band) {
      case '0-50':
        return r'$0–$50';
      case '50-75':
        return r'$50–$75';
      case '75-150':
        return r'$75–$150';
      default:
        return _t('Over \$150', 'Más de \$150');
    }
  }

  String _colorLabel(String color) {
    if (_english) return color;
    switch (color) {
      case 'Red':
        return 'Rojo';
      case 'Blue':
        return 'Azul';
      case 'Orange':
        return 'Naranja';
      case 'Black':
        return 'Negro';
      default:
        return color;
    }
  }

  String _shippingLabel(String option) {
    if (_english) return option;
    switch (option) {
      case 'Regular':
        return 'Regular';
      case 'Economic':
        return 'Económico';
      case 'Next Day':
        return 'Día siguiente';
      case 'Instant':
        return 'Instantáneo';
      default:
        return option;
    }
  }
}

class _RailItem {
  final IconData icon;
  final VoidCallback onTap;

  const _RailItem(this.icon, this.onTap);
}

class _FilterChipData {
  final String group;
  final String value;
  final VoidCallback onRemove;

  const _FilterChipData(this.group, this.value, this.onRemove);
}

class _PlusButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PlusButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StoreColors.teal,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.add, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(color: StoreColors.teal, shape: BoxShape.circle),
      child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
    );
  }
}

class _Blob extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double size;
  final Color color;

  const _Blob({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
