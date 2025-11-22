import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class APICall extends StatefulWidget {
  const APICall({super.key});

  @override
  State<APICall> createState() => _APICallState();
}

class _APICallState extends State<APICall> {
  List products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  // -------------------------
  // READ API
  // -------------------------
  Future<void> getProducts() async {
    final url = Uri.parse("http://35.73.30.144:2008/api/v1/ReadProduct");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      setState(() {
        products = jsonResponse["data"];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // -------------------------
  // DELETE API
  // -------------------------
  Future<void> deleteProduct(String id) async {
    final url = Uri.parse("http://35.73.30.144:2008/api/v1/DeleteProduct/$id");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Product Deleted")));
      getProducts();
    }
  }

  // -------------------------
  // SHOW ADD / EDIT DIALOG
  // -------------------------
  void showProductDialog({Map? product}) {
    final img = TextEditingController(text: product?["Img"] ?? "");
    final name = TextEditingController(text: product?["ProductName"] ?? "");
    final price =
    TextEditingController(text: product?["UnitPrice"]?.toString() ?? "");
    final qty =
    TextEditingController(text: product?["Qty"]?.toString() ?? "");

    final bool isEdit = product != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? "Edit Product" : "Add Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: img, decoration: InputDecoration(labelText: "Image URL")),
            TextField(controller: name, decoration: InputDecoration(labelText: "Product Name")),
            TextField(controller: price, decoration: InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
            TextField(controller: qty, decoration: InputDecoration(labelText: "Quantity"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final data = {
                "Img": img.text,
                "ProductName": name.text,
                "UnitPrice": price.text,
                "Qty": qty.text,
              };

              if (isEdit) {
                updateProduct(product["_id"], data);
              } else {
                addProduct(data);
              }

              Navigator.pop(context);
            },
            child: Text(isEdit ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // ADD API
  // -------------------------
  Future<void> addProduct(Map data) async {
    final url = Uri.parse("http://35.73.30.144:2008/api/v1/CreateProduct");
    final res = await http.post(url, body: data);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Product Added")));
      getProducts();
    }
  }

  // -------------------------
  // UPDATE API
  // -------------------------
  Future<void> updateProduct(String id, Map data) async {
    final url = Uri.parse("http://35.73.30.144:2008/api/v1/UpdateProduct/$id");
    final res = await http.post(url, body: data);

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Product Updated")));
      getProducts();
    }
  }

  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products",
        style: TextStyle(
          color: Colors.white,
        ),

        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          childAspectRatio: 0.589,
        ),
        itemBuilder: (context, index) {
          final item = products[index];

          return Card(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Image.network(item["Img"]),
                ),

                Text(
                  item["ProductName"],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),

                Text("Price: \$${item["UnitPrice"]}"),
                Text("Qty: ${item["Qty"]}"),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () =>
                          showProductDialog(product: item),
                    ),

                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          deleteProduct(item["_id"]),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showProductDialog(),
      ),
    );
  }
}
