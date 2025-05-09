import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InformesScreen extends StatelessWidget {
  const InformesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (l10n == null) {
      return const Center(child: Text('Error: Localizations not found!'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const _UserInfoSection(),
            const SizedBox(height: 20),
            const _SearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _ReportCard(
                    title: l10n.weekly,
                    amount: '\$149.868',
                    percentage: '+40.00%',
                    imagePath: 'assets/images/informe.png',
                  ),
                  const SizedBox(height: 16),
                  _ReportCard(
                    title: l10n.monthly,
                    amount: '\$149.868',
                    percentage: '+40.00%',
                    imagePath: 'assets/images/informe.png',
                  ),
                  const SizedBox(height: 16),
                  _ReportCard(
                    title: l10n.yearly,
                    amount: '\$149.868',
                    percentage: '+40.00%',
                    imagePath: 'assets/images/informe.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavigationBar(),
      floatingActionButton: CircularMenu(
        alignment: Alignment.bottomRight,
        toggleButtonColor: Colors.teal,
        toggleButtonIconColor: Colors.white,
        items: [
          CircularMenuItem(
            icon: Icons.settings,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/configuracion');
            },
          ),
          CircularMenuItem(
            icon: Icons.bar_chart,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/informes');
            },
          ),
          CircularMenuItem(
            icon: Icons.emoji_events,
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/logros');
            },
          ),
        ],
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage: AssetImage('assets/images/informe.png'),
                radius: 25,
              ),
              const SizedBox(width: 10),
              Text(
                'Nombre Usuario',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: l10n.search,
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 16.0,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String amount;
  final String percentage;
  final String imagePath;

  const _ReportCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.percentage,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  percentage,
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(imagePath, width: 120, height: 90, fit: BoxFit.cover),
        ],
      ),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: const Icon(FontAwesomeIcons.dollarSign),
            onPressed: () {
              Navigator.pushNamed(context, '/informes');
            },
          ),
        ],
      ),
    );
  }
}
