import 'package:flutter/material.dart';
import 'config.dart';
import 'models.dart';
import 'dialogs.dart';

class ProductGrid extends StatelessWidget {
  final Stream<List<Product>> stream;
  final String col;
  final bool isLab, admin;
  final void Function(Product) onAdd;
  const ProductGrid({
    super.key,
    required this.stream,
    required this.col,
    required this.isLab,
    required this.admin,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: ${snap.error}')));
        }
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        if (list.isEmpty) return const Center(child: Text('Abhi koi item nahi hai'));
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.78,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12),
          itemCount: list.length,
          itemBuilder: (c, i) => ProductCard(
              p: list[i], col: col, isLab: isLab, admin: admin, onAdd: onAdd),
        );
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product p;
  final String col;
  final bool isLab, admin;
  final void Function(Product) onAdd;
  const ProductCard({
    super.key,
    required this.p,
    required this.col,
    required this.isLab,
    required this.admin,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 96,
          width: double.infinity,
          color: kPrimary.withOpacity(0.1),
          child: Stack(children: [
            Center(
                child: Icon(isLab ? Icons.biotech : Icons.medication,
                    size: 46, color: kPrimary)),
            if (admin)
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: kPrimary),
                  onSelected: (v) {
                    if (v == 'edit') {
                      showProductDialog(context, col: col, isLab: isLab, product: p);
                    } else {
                      confirmDelete(context, col, p);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(p.sub, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('₹${p.price}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17, color: kPrimary)),
            FilledButton(
              style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 16)),
              onPressed: () => onAdd(p),
              child: Text(isLab ? 'BOOK' : 'ADD'),
            ),
          ]),
        ),
      ]),
    );
  }
}
