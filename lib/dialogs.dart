import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config.dart';
import 'models.dart';

void showProductDialog(BuildContext context,
    {required String col, required bool isLab, Product? product}) {
  final it = product;
  final n = TextEditingController(text: it?.name ?? '');
  final u = TextEditingController(text: it?.sub ?? '');
  final p = TextEditingController(text: it == null ? '' : '${it.price}');
  final what = isLab ? 'Lab Test' : 'Medicine';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(it == null ? 'Naya $what Add Karein' : '$what Edit Karein'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: n,
              decoration: InputDecoration(
                  labelText: isLab ? 'Test ka naam' : 'Medicine ka naam')),
          TextField(
              controller: u,
              decoration: InputDecoration(
                  labelText:
                      isLab ? 'Report time (Report: 24 hrs)' : 'Use (jaise Fever)')),
          TextField(
              controller: p,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price (₹)')),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            if (n.text.trim().isEmpty) return;
            final data = {
              'name': n.text.trim(),
              'sub': u.text.trim().isEmpty ? 'General' : u.text.trim(),
              'price': int.tryParse(p.text.trim()) ?? 0,
            };
            final ref = FirebaseFirestore.instance.collection(col);
            try {
              if (it == null) {
                await ref.add(data);
              } else {
                await ref.doc(it.id).update(data);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Save nahi hua: $e')));
              }
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void confirmDelete(BuildContext context, String col, Product p) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete karein?'),
      content: Text('"${p.name}" hamesha ke liye hata diya jayega.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
          onPressed: () async {
            try {
              await FirebaseFirestore.instance.collection(col).doc(p.id).delete();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Delete nahi hua: $e')));
              }
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

void showLoginDialog(BuildContext context) {
  final e = TextEditingController();
  final p = TextEditingController();
  String? err;
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => AlertDialog(
        title: const Text('Admin Login'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: e,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email')),
          TextField(
              controller: p,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password')),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(err!, style: TextStyle(color: Colors.red[800])),
            ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: e.text.trim(), password: p.text);
                if (ctx.mounted) Navigator.pop(ctx);
              } on FirebaseAuthException catch (x) {
                setS(() => err = x.message ?? x.code);
              }
            },
            child: const Text('Login'),
          ),
        ],
      ),
    ),
  );
}

void showOrders(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(
          title: const Text('Orders'),
          backgroundColor: kPrimary,
          foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (c, s) {
          if (s.hasError) return Center(child: Text('Error: ${s.error}'));
          if (!s.hasData) return const Center(child: CircularProgressIndicator());
          final docs = s.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Abhi koi order nahi'));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (c, i) {
              final d = docs[i];
              final m = d.data();
              final done = m['status'] == 'delivered';
              return Card(
                child: ListTile(
                  isThreeLine: true,
                  title: Text('${m['name']} • ₹${m['total']}'),
                  subtitle: Text(
                      '${m['phone']}\n${m['address']}\n${(m['items'] as List?)?.join(', ') ?? ''}'),
                  trailing: IconButton(
                    icon: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: done ? Colors.green : Colors.grey),
                    onPressed: () =>
                        d.reference.update({'status': done ? 'new' : 'delivered'}),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  ));
}
