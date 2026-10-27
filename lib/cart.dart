import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';
import 'models.dart';

void openCart(BuildContext context, List<Product> cart, VoidCallback onChanged) {
  final name = TextEditingController();
  final phone = TextEditingController();
  final addr = TextEditingController();
  String? err;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
      final total = cart.fold<int>(0, (s, p) => s + p.price);
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Aapka Cart',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (cart.isEmpty)
              const Padding(padding: EdgeInsets.all(24), child: Text('Cart khaali hai'))
            else ...[
              for (final p in List<Product>.from(cart))
                ListTile(
                  dense: true,
                  title: Text(p.name),
                  subtitle: Text('₹${p.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      cart.remove(p);
                      onChanged();
                      setS(() {});
                    },
                  ),
                ),
              const Divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('₹$total',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold, color: kPrimary)),
              ]),
              TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Aapka naam')),
              TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile number')),
              TextField(
                  controller: addr,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Pura pata')),
              if (err != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(err!, style: TextStyle(color: Colors.red[800])),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.chat),
                  label: const Text('WhatsApp par Order karein'),
                  onPressed: () async {
                    if (name.text.trim().isEmpty ||
                        phone.text.trim().isEmpty ||
                        addr.text.trim().isEmpty) {
                      setS(() => err = 'Naam, mobile aur pata bharein');
                      return;
                    }
                    final items = cart.map((p) => '${p.name} - ₹${p.price}').toList();
                    final msg = 'Naya Order - $storeName\n\n'
                        '${items.map((e) => '• $e').join('\n')}\n\n'
                        'Total: ₹$total\n\n'
                        'Naam: ${name.text.trim()}\n'
                        'Mobile: ${phone.text.trim()}\n'
                        'Pata: ${addr.text.trim()}';
                    try {
                      await FirebaseFirestore.instance.collection('orders').add({
                        'name': name.text.trim(),
                        'phone': phone.text.trim(),
                        'address': addr.text.trim(),
                        'items': items,
                        'total': total,
                        'status': 'new',
                        'time': FieldValue.serverTimestamp(),
                      });
                    } catch (_) {}
                    final uri = Uri.parse(
                        'https://wa.me/$kWhatsApp?text=${Uri.encodeComponent(msg)}');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    cart.clear();
                    onChanged();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ]),
        ),
      );
    }),
  );
}
