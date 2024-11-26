import 'package:flutter/material.dart';

class PlaceListItem extends StatelessWidget {
  final Map<String, dynamic> place;
  final VoidCallback onTap;
  final VoidCallback onFetchEvent;

  const PlaceListItem({
    required this.place,
    required this.onTap,
    required this.onFetchEvent,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: const Icon(Icons.place, color: Colors.green),
        title: Text(place['name']!),
        subtitle: Text(place['address']!),
        trailing: IconButton(
          onPressed: onFetchEvent,
          icon: const Icon(Icons.notifications, color: Colors.green),
          tooltip: 'get notifications of events',
        ),
        onTap: onTap,
      ),
    );
  }
}
