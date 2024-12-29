import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Status/auth_provider.dart';
import 'Layout/cyberpunk_theme.dart';
import 'shop_controller.dart';

class CustomToggleSwitch extends StatelessWidget {
  final bool value;
  final Function(bool) onChanged;

  const CustomToggleSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 50,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? CyberpunkTheme.neonBlue.withOpacity(0.2)
              : CyberpunkTheme.neonPink.withOpacity(0.2),
          border: Border.all(
            color: value ? CyberpunkTheme.neonBlue : CyberpunkTheme.neonPink,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: value ? 22 : 2,
              top: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      value ? CyberpunkTheme.neonBlue : CyberpunkTheme.neonPink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late ShopController _controller;

  @override
  void initState() {
    super.initState();
    final username = context.read<AppAuthProvider>().username ?? '';
    _controller = ShopController(username: username);
    _controller.checkAndCreateUserRewardConfig();
    _loadRewards(); // Hier die neue Zeile
  }

  Future<void> _loadRewards() async {
    // Neue Methode
    await _controller.initializeRewards();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showPasswordDialog(
      String title, Function(String) onConfirm) async {
    TextEditingController passwordController = TextEditingController();
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CyberpunkTheme.darkGrey,
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Lehrer-Passwort',
              labelStyle: TextStyle(color: CyberpunkTheme.neonBlue),
              enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: CyberpunkTheme.neonBlue.withOpacity(0.3)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Abbrechen',
                  style: TextStyle(color: CyberpunkTheme.neonPink)),
            ),
            TextButton(
              onPressed: () {
                onConfirm(passwordController.text);
                Navigator.pop(context);
              },
              child: Text('Bestätigen',
                  style: TextStyle(color: CyberpunkTheme.neonBlue)),
            ),
          ],
        );
      },
    );
  }

  void _handleToggleReward(String rewardName, bool currentStatus) async {
    await _showPasswordDialog(
      currentStatus ? 'Belohnung deaktivieren' : 'Belohnung aktivieren',
      (password) async {
        final success = await _controller.toggleRewardStatus(
            rewardName, currentStatus, password);
        if (success) {
          await _controller.initializeRewards();
          setState(() {});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(currentStatus
                    ? 'Belohnung deaktiviert'
                    : 'Belohnung aktiviert'),
                backgroundColor: CyberpunkTheme.neonBlue.withOpacity(0.3),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Falsches Passwort!'),
                backgroundColor: CyberpunkTheme.neonPink.withOpacity(0.3),
              ),
            );
          }
        }
      },
    );
  }

  void _handlePurchaseReward(Reward reward, int currentPoints) async {
    final result = await _controller.purchaseReward(reward, currentPoints);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success']
              ? CyberpunkTheme.neonBlue.withOpacity(0.3)
              : CyberpunkTheme.neonPink.withOpacity(0.3),
        ),
      );
    }
  }

  void _handleValidateReward(String documentId, Reward reward) async {
    await _showPasswordDialog(
      'Lehrer-Bestätigung',
      (password) async {
        final success = await _controller.validateReward(documentId, password);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Belohnung eingelöst!'),
                backgroundColor: CyberpunkTheme.neonBlue.withOpacity(0.3),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Falsches Passwort!'),
                backgroundColor: CyberpunkTheme.neonPink.withOpacity(0.3),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildHeader(int points) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CyberpunkTheme.darkGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: CyberpunkTheme.neonBlue,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/game'),
                  tooltip: 'Zurück zum Spiel',
                ),
              ),
              Text(
                'Belohnungsshop',
                style: GoogleFonts.orbitron(
                  color: CyberpunkTheme.neonBlue,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.5),
                      offset: const Offset(0, 0),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.darkGrey,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CyberpunkTheme.neonBlue.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      color: CyberpunkTheme.neonBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$points',
                      style: GoogleFonts.orbitron(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }

  Widget _buildRewardsList(int userPoints) {
    return Container(
      height: 380,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _controller.rewards.length,
        itemBuilder: (context, index) {
          final reward = _controller.rewards[index];
          final canPurchase = userPoints >= reward.points && reward.isActive;

          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: reward.isActive
                  ? CyberpunkTheme.darkGrey
                  : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: reward.isActive
                    ? (canPurchase
                        ? CyberpunkTheme.neonBlue.withOpacity(0.3)
                        : CyberpunkTheme.neonPink.withOpacity(0.3))
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (reward.isActive
                          ? (canPurchase
                              ? CyberpunkTheme.neonBlue
                              : CyberpunkTheme.neonPink)
                          : Colors.grey)
                      .withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                if (!reward.isActive)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: CyberpunkTheme.neonPink.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Deaktiviert',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color:
                                      CyberpunkTheme.neonPink.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        reward.name,
                        style: GoogleFonts.rajdhani(
                          color: Colors.white
                              .withOpacity(reward.isActive ? 0.9 : 0.5),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          reward.imageUrl,
                          fit: BoxFit.cover,
                          opacity: reward.isActive
                              ? null
                              : const AlwaysStoppedAnimation(0.5),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: reward.isActive
                                  ? (canPurchase
                                      ? CyberpunkTheme.neonBlue.withOpacity(0.1)
                                      : CyberpunkTheme.neonPink
                                          .withOpacity(0.1))
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: reward.isActive
                                    ? (canPurchase
                                        ? CyberpunkTheme.neonBlue
                                            .withOpacity(0.3)
                                        : CyberpunkTheme.neonPink
                                            .withOpacity(0.3))
                                    : Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  size: 18,
                                  color: reward.isActive
                                      ? (canPurchase
                                          ? CyberpunkTheme.neonBlue
                                          : CyberpunkTheme.neonPink)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${reward.points}',
                                  style: GoogleFonts.rajdhani(
                                    color: reward.isActive
                                        ? (canPurchase
                                            ? CyberpunkTheme.neonBlue
                                            : CyberpunkTheme.neonPink)
                                        : Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: reward.isActive && canPurchase
                                ? () =>
                                    _handlePurchaseReward(reward, userPoints)
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: reward.isActive
                                  ? (canPurchase
                                      ? CyberpunkTheme.neonBlue.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1))
                                  : Colors.grey.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: reward.isActive
                                      ? (canPurchase
                                          ? CyberpunkTheme.neonBlue
                                              .withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.2))
                                      : Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              'Kaufen',
                              style: GoogleFonts.rajdhani(
                                color: reward.isActive
                                    ? (canPurchase
                                        ? CyberpunkTheme.neonBlue
                                        : Colors.grey)
                                    : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
                Positioned(
                  left: 16,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    child: CustomToggleSwitch(
                      value: reward.isActive,
                      onChanged: (value) =>
                          _handleToggleReward(reward.name, reward.isActive),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPurchasedRewards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 8),
          child: Text(
            'Deine Gutscheine',
            style: GoogleFonts.orbitron(
              color: CyberpunkTheme.neonBlue.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          height: 175,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: CyberpunkTheme.darkGrey.withOpacity(0.5),
            border: Border(
              top: BorderSide(
                color: CyberpunkTheme.neonBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: CyberpunkTheme.neonBlue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _controller.purchasedRewardsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Ein Fehler ist aufgetreten'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final purchasedRewards = snapshot.data?.docs
                      .where((doc) => doc.get('isUsed') == false)
                      .toList() ??
                  [];

              if (purchasedRewards.isEmpty) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: CyberpunkTheme.lightGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CyberpunkTheme.neonBlue.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Noch keine\nGutscheine',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: purchasedRewards.length,
                itemBuilder: (context, index) {
                  final reward = purchasedRewards[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: CyberpunkTheme.lightGrey,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CyberpunkTheme.neonBlue.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CyberpunkTheme.neonBlue.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _handleValidateReward(
                          reward.id,
                          Reward(
                            name: reward.get('rewardName'),
                            points: reward.get('rewardPoints'),
                            imageUrl: reward.get('imageUrl'),
                          )),
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              reward.get('imageUrl'),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              reward.get('rewardName'),
                              style: GoogleFonts.rajdhani(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CyberpunkTheme.background,
              CyberpunkTheme.backgroundAccent,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _controller.userPointsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Ein Fehler ist aufgetreten',
                      style: TextStyle(color: CyberpunkTheme.neonPink),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final userPoints = snapshot.data?.get('points') ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(userPoints),
                    _buildRewardsList(userPoints),
                    const SizedBox(height: 30),
                    _buildPurchasedRewards(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
