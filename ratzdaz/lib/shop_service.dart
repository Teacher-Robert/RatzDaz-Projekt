import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ratzdaz/shop_screen.dart';

import 'shop_controller.dart';

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Punkte des Benutzers abrufen
  Stream<int> getUserPoints(String username) {
    return _firestore
        .collection('quiz_progress')
        .doc(username)
        .snapshots()
        .map((doc) => doc.data()?['points'] ?? 0);
  }

  // Gekaufte Belohnungen speichern
  Future<void> savePurchasedReward(String username, Reward reward) async {
    final userDoc = _firestore.collection('quiz_progress').doc(username);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentPoints = snapshot.data()?['points'] ?? 0;

      if (currentPoints < reward.points) {
        throw Exception('Nicht genügend Punkte');
      }

      // Belohnung zur Liste der gekauften Belohnungen hinzufügen
      transaction.update(userDoc, {
        'points': currentPoints - reward.points,
        'purchased_rewards': FieldValue.arrayUnion([
          {
            'name': reward.name,
            'points': reward.points,
            'imageUrl': reward.imageUrl,
            'purchaseDate': FieldValue.serverTimestamp(),
            'isRedeemed': false
          }
        ])
      });
    });
  }

  // Belohnung als eingelöst markieren
  Future<void> redeemReward(
      String username, Map<String, dynamic> reward) async {
    final userDoc = _firestore.collection('quiz_progress').doc(username);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      List<dynamic> purchasedRewards =
          snapshot.data()?['purchased_rewards'] ?? [];

      // Finde und aktualisiere die spezifische Belohnung
      int index = purchasedRewards.indexWhere((r) =>
          r['name'] == reward['name'] &&
          r['purchaseDate'] == reward['purchaseDate']);

      if (index != -1) {
        purchasedRewards[index]['isRedeemed'] = true;
        transaction.update(userDoc, {'purchased_rewards': purchasedRewards});
      }
    });
  }

  // Stream der gekauften Belohnungen
  Stream<List<Map<String, dynamic>>> getPurchasedRewards(String username) {
    return _firestore
        .collection('quiz_progress')
        .doc(username)
        .snapshots()
        .map((doc) {
      List<dynamic> rewards = doc.data()?['purchased_rewards'] ?? [];
      return rewards
          .where((reward) => reward['isRedeemed'] == false)
          .map((reward) => reward as Map<String, dynamic>)
          .toList();
    });
  }
}
