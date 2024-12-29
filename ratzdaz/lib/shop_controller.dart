import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String username;
  List<Reward> rewards = [];

  ShopController({required this.username});

  Stream<DocumentSnapshot> get userPointsStream =>
      _firestore.collection('quiz_progress').doc(username).snapshots();

  Stream<QuerySnapshot> get purchasedRewardsStream => _firestore
      .collection('purchased_rewards')
      .where('username', isEqualTo: username)
      .snapshots();

  Future<void> checkAndCreateUserRewardConfig() async {
    final userDoc = await _firestore.collection('users').doc(username).get();

    if (!userDoc.exists || !userDoc.data()!.containsKey('rewards_config')) {
      Map<String, bool> initialConfig = {
        'reward_seatmate': true,
        'reward_service': true,
        'reward_early_break': true,
        'reward_no_homework': true,
        'reward_tablet_time': true,
        'reward_sweets': true,
        'reward_class_game': true,
        'reward_teacher_desk': true,
      };

      await _firestore.collection('users').doc(username).set({
        'rewards_config': initialConfig,
      }, SetOptions(merge: true));
    }
  }

  Future<String> getImageUrl(String imagePath) async {
    try {
      final ref = _storage.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Fehler beim Laden des Bildes $imagePath: $e');
      return 'https://picsum.photos/200';
    }
  }

  Future<void> initializeRewards() async {
    final userDoc = await _firestore.collection('users').doc(username).get();
    Map<String, bool> activeStates = {};

    if (userDoc.exists && userDoc.data()!.containsKey('rewards_config')) {
      activeStates =
          Map<String, bool>.from(userDoc.data()!['rewards_config'] as Map);
    }

    rewards = [
      Reward(
        name: "1 Tag neben Wunschsitznachbar sitzen",
        points: 250,
        imageUrl: await getImageUrl("store/schoolmate.jpg"),
        isActive: activeStates['reward_seatmate'] ?? true,
      ),
      Reward(
        name: "Einen Dienst für die nächste Woche aussuchen",
        points: 100,
        imageUrl: await getImageUrl("store/dienst.jpg"),
        isActive: activeStates['reward_service'] ?? true,
      ),
      Reward(
        name: "Eher zur Pause dürfen mit einem Freund - 5min",
        points: 200,
        imageUrl: await getImageUrl("store/break.jpg"),
        isActive: activeStates['reward_early_break'] ?? true,
      ),
      Reward(
        name: "1 Mal keine Hausaufgaben",
        points: 200,
        imageUrl: await getImageUrl("store/noHomework.png"),
        isActive: activeStates['reward_no_homework'] ?? true,
      ),
      Reward(
        name: "20min Tabletspielzeit",
        points: 300,
        imageUrl: await getImageUrl("store/gaming.jpg"),
        isActive: activeStates['reward_tablet_time'] ?? true,
      ),
      Reward(
        name: "1x in die Süßighkeitenbox greifen",
        points: 100,
        imageUrl: await getImageUrl("store/sweets.jpg"),
        isActive: activeStates['reward_sweets'] ?? true,
      ),
      Reward(
        name: "5min am Ende der Stunde ein Spiel für die Klasse aussuchen",
        points: 120,
        imageUrl: await getImageUrl("store/classgame.jpg"),
        isActive: activeStates['reward_class_game'] ?? true,
      ),
      Reward(
        name: "1 Stunde am Lehrertisch sitzen",
        points: 300,
        imageUrl: await getImageUrl("store/teacherdesk.jpg"),
        isActive: activeStates['reward_teacher_desk'] ?? true,
      ),
    ];
  }

  Future<bool> toggleRewardStatus(
      String rewardName, bool currentStatus, String password) async {
    if (password != 'teacher') {
      return false;
    }

    final Map<String, String> rewardToId = {
      "1 Tag neben Wunschsitznachbar sitzen": "reward_seatmate",
      "Einen Dienst für die nächste Woche aussuchen": "reward_service",
      "Eher zur Pause dürfen mit einem Freund - 5min": "reward_early_break",
      "1 Mal keine Hausaufgaben": "reward_no_homework",
      "20min Tabletspielzeit": "reward_tablet_time",
      "1x in die Süßighkeitenbox greifen": "reward_sweets",
      "5min am Ende der Stunde ein Spiel für die Klasse aussuchen":
          "reward_class_game",
      "1 Stunde am Lehrertisch sitzen": "reward_teacher_desk",
    };

    final rewardId = rewardToId[rewardName];
    if (rewardId != null) {
      await _firestore.collection('users').doc(username).update({
        'rewards_config.$rewardId': !currentStatus,
      });
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> purchaseReward(
      Reward reward, int currentPoints) async {
    final userDoc = await _firestore.collection('users').doc(username).get();
    final rewardConfigs =
        userDoc.data()?['rewards_config'] as Map<String, dynamic>?;

    final Map<String, String> rewardToId = {
      "1 Tag neben Wunschsitznachbar sitzen": "reward_seatmate",
      "Einen Dienst für die nächste Woche aussuchen": "reward_service",
      "Eher zur Pause dürfen mit einem Freund - 5min": "reward_early_break",
      "1 Mal keine Hausaufgaben": "reward_no_homework",
      "20min Tabletspielzeit": "reward_tablet_time",
      "1x in die Süßighkeitenbox greifen": "reward_sweets",
      "5min am Ende der Stunde ein Spiel für die Klasse aussuchen":
          "reward_class_game",
      "1 Stunde am Lehrertisch sitzen": "reward_teacher_desk",
    };

    final rewardId = rewardToId[reward.name];
    final isCurrentlyActive = rewardConfigs?[rewardId] ?? true;

    if (!isCurrentlyActive) {
      return {'success': false, 'message': 'Diese Belohnung ist deaktiviert!'};
    }

    if (currentPoints < reward.points) {
      return {'success': false, 'message': 'Nicht genügend Punkte!'};
    }

    try {
      await _firestore.collection('quiz_progress').doc(username).update({
        'points': currentPoints - reward.points,
      });

      await _firestore.collection('purchased_rewards').add({
        'username': username,
        'rewardName': reward.name,
        'rewardPoints': reward.points,
        'imageUrl': reward.imageUrl,
        'purchaseDate': FieldValue.serverTimestamp(),
        'isUsed': false,
      });

      return {'success': true, 'message': 'Belohnung erfolgreich gekauft!'};
    } catch (e) {
      return {'success': false, 'message': 'Fehler beim Kauf der Belohnung'};
    }
  }

  Future<bool> validateReward(String documentId, String password) async {
    if (password != 'teacher') {
      return false;
    }

    await _firestore
        .collection('purchased_rewards')
        .doc(documentId)
        .update({'isUsed': true});
    return true;
  }
}

class Reward {
  final String name;
  final int points;
  final String imageUrl;
  final bool isActive;

  Reward({
    required this.name,
    required this.points,
    required this.imageUrl,
    this.isActive = true,
  });
}
