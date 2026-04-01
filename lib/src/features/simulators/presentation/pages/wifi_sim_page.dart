import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_icons.dart';
import '../../../../app/theme.dart';

class WifiSimPage extends StatefulWidget {
  const WifiSimPage({super.key});

  @override
  State<WifiSimPage> createState() => _WifiSimPageState();
}

class _WifiSimPageState extends State<WifiSimPage> {
  SimWifiNetwork _selectedNetwork = wifiNetworks.first;
  bool _connected = false;
  bool _showAttackerView = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF17376C);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF365D9E);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const <Color>[Color(0xFF04153E), Color(0xFF0B2B66)]
                : const <Color>[Color(0xFFF8FBFF), Color(0xFFEAF3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TopButton(
                      label: 'Back',
                      onTap: () => context.go('/dashboard'),
                    ),
                    const Spacer(),
                    const ThemeToggleButton(),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Wi-Fi Simulator',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.02,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose which network you would trust in a public place. If you jump onto an unsafe hotspot, the screen flips to show what the Wi-Fi operator can watch or collect.',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;
                      if (wide) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 360,
                              child: _WifiSettingsPanel(
                                networks: wifiNetworks,
                                selectedNetwork: _selectedNetwork,
                                connected: _connected,
                                onSelect: (network) {
                                  setState(() {
                                    _selectedNetwork = network;
                                    _connected = false;
                                    _showAttackerView = false;
                                  });
                                },
                                onConnect: _connectToSelectedNetwork,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _WifiTrainingPanel(
                                network: _selectedNetwork,
                                connected: _connected,
                                showAttackerView: _showAttackerView,
                                onTryAgain: _resetSelection,
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView(
                        children: [
                          _WifiSettingsPanel(
                            networks: wifiNetworks,
                            selectedNetwork: _selectedNetwork,
                            connected: _connected,
                            onSelect: (network) {
                              setState(() {
                                _selectedNetwork = network;
                                _connected = false;
                                _showAttackerView = false;
                              });
                            },
                            onConnect: _connectToSelectedNetwork,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 620,
                            child: _WifiTrainingPanel(
                              network: _selectedNetwork,
                              connected: _connected,
                              showAttackerView: _showAttackerView,
                              onTryAgain: _resetSelection,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _connectToSelectedNetwork() {
    setState(() {
      _connected = true;
      _showAttackerView = _selectedNetwork.opensUserToSnooping;
    });
  }

  void _resetSelection() {
    setState(() {
      _connected = false;
      _showAttackerView = false;
    });
  }
}

class _WifiSettingsPanel extends StatelessWidget {
  const _WifiSettingsPanel({
    required this.networks,
    required this.selectedNetwork,
    required this.connected,
    required this.onSelect,
    required this.onConnect,
  });

  final List<SimWifiNetwork> networks;
  final SimWifiNetwork selectedNetwork;
  final bool connected;
  final ValueChanged<SimWifiNetwork> onSelect;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: appShadows(isDark),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSvgIcon(
                AppIcons.settings,
                color: isDark ? Colors.white : const Color(0xFF17376C),
                size: 20,
                semanticLabel: 'Settings',
              ),
              const SizedBox(width: 10),
              Text(
                'Wi-Fi Settings',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF17376C),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Cafe Corner - Available Networks',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : const Color(0xFF4D6EA2),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: networks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final network = networks[index];
                final selected = network.id == selectedNetwork.id;
                return _NetworkTile(
                  network: network,
                  selected: selected,
                  onTap: () => onSelect(network),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _PromptCard(network: selectedNetwork),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConnect,
              child: Text(connected ? 'Reconnect To Review' : 'Connect'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WifiTrainingPanel extends StatelessWidget {
  const _WifiTrainingPanel({
    required this.network,
    required this.connected,
    required this.showAttackerView,
    required this.onTryAgain,
  });

  final SimWifiNetwork network;
  final bool connected;
  final bool showAttackerView;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: showAttackerView ? 1 : 0),
      duration: const Duration(milliseconds: 620),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        final angle = value * math.pi;
        final showingBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: showingBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _AttackerViewCard(
                    network: network,
                    onTryAgain: onTryAgain,
                  ),
                )
              : _DecisionViewCard(
                  network: network,
                  connected: connected,
                  onTryAgain: onTryAgain,
                ),
        );
      },
    );
  }
}

class _DecisionViewCard extends StatelessWidget {
  const _DecisionViewCard({
    required this.network,
    required this.connected,
    required this.onTryAgain,
  });

  final SimWifiNetwork network;
  final bool connected;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = network.opensUserToSnooping
        ? const Color(0xFFB13232)
        : const Color(0xFF2E9A59);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A3C86) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: appShadows(isDark),
      ),
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(
            connected ? 'Connection Review' : 'Choose The Safest Wi-Fi',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            connected
                ? network.opensUserToSnooping
                      ? 'This network felt convenient, but now check what that hotspot owner can learn when traffic is not properly protected.'
                      : 'This was the safer call in this set because it reduces exposure compared with open guest networks and suspicious lookalikes.'
                : 'Free public Wi-Fi is not automatically bad, but open networks and convincing fakes create much more risk. Look for password protection, a legitimate name, and a reason to trust the network.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.72)
                  : const Color(0xFF4D6EA2),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'Selected Network',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  network.name,
                  style: const TextStyle(
                    color: Color(0xFF17376C),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(label: network.priceLabel),
                    _InfoPill(label: network.securityLabel),
                    _InfoPill(label: network.trustLabel),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  network.description,
                  style: const TextStyle(
                    color: Color(0xFF17376C),
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Hints To Notice',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: network.hints
                  .map(
                    (hint) =>
                        _BulletLine(text: hint, color: const Color(0xFF245FBC)),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Text(
              connected
                  ? network.opensUserToSnooping
                        ? 'Risky choice: this hotspot gives a nearby operator a much easier chance to watch browsing metadata, inject fake pages, or trick you into entering data on the wrong site.'
                        : 'Good choice: this network is the safer option in this room because it has a real venue link and basic protection instead of being a random open hotspot.'
                  : 'Safest in this list: venue-provided, password-protected Wi-Fi that staff can confirm is usually the strongest option here.',
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ),
          if (connected) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onTryAgain,
                child: const Text('Try Another Network'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AttackerViewCard extends StatelessWidget {
  const _AttackerViewCard({required this.network, required this.onTryAgain});

  final SimWifiNetwork network;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2B1020) : const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: appShadows(isDark),
      ),
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          Text(
            'Hotspot Owner View',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF8F2626),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you connect to an open or fake public network, the person running it may not instantly see every password, but they can still observe a lot and push you toward dangerous pages.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.74)
                  : const Color(0xFF934646),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            title: 'What They Can Learn Or Influence',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: network.exposureExamples
                  .map(
                    (item) =>
                        _BulletLine(text: item, color: const Color(0xFFB13232)),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'How The Trap Works',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: network.attackerMoves
                  .map(
                    (move) =>
                        _BulletLine(text: move, color: const Color(0xFFC48720)),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'How To Protect Yourself',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: network.saferHabits
                  .map(
                    (habit) => _BulletLine(
                      text: habit,
                      color: const Color(0xFF245FBC),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onTryAgain,
                  child: const Text('Pick Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onTryAgain,
                  child: const Text('Leave Network'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({
    required this.network,
    required this.selected,
    required this.onTap,
  });

  final SimWifiNetwork network;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? const Color(0xFF2A74EE)
        : isDark
        ? Colors.white.withValues(alpha: 0.1)
        : const Color(0xFFD7E0EF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2A74EE).withValues(alpha: isDark ? 0.22 : 0.08)
              : isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF6F9FF),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: selected ? 2 : 1.4),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: network.opensUserToSnooping
                    ? const Color(0xFFFFDADA)
                    : const Color(0xFFDDF2E3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: AppSvgIcon(
                  AppIcons.wifi,
                  color: network.opensUserToSnooping
                      ? const Color(0xFFB13232)
                      : const Color(0xFF2E9A59),
                  size: 20,
                  semanticLabel: network.name,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    network.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF17376C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    network.subtitle,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.68)
                          : const Color(0xFF5A77A6),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (network.showUnsecureLabel)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0E0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Unsecure',
                  style: TextStyle(
                    color: Color(0xFFB13232),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.network});

  final SimWifiNetwork network;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Question: Which network is safest to connect to right now? Staff-confirmed, password-protected Wi-Fi is usually the best option. Current pick: ${network.name}',
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF17376C),
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF17376C),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colorScheme.primary, width: 1.6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.86)
                    : const Color(0xFF17376C),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.primary, width: 3),
        ),
        child: Center(
          child: AppSvgIcon(
            AppIcons.arrowLeft,
            color: colorScheme.primary,
            size: 20,
            semanticLabel: label,
          ),
        ),
      ),
    );
  }
}

class SimWifiNetwork {
  const SimWifiNetwork({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.priceLabel,
    required this.securityLabel,
    required this.trustLabel,
    required this.showUnsecureLabel,
    required this.opensUserToSnooping,
    required this.hints,
    required this.exposureExamples,
    required this.attackerMoves,
    required this.saferHabits,
  });

  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String priceLabel;
  final String securityLabel;
  final String trustLabel;
  final bool showUnsecureLabel;
  final bool opensUserToSnooping;
  final List<String> hints;
  final List<String> exposureExamples;
  final List<String> attackerMoves;
  final List<String> saferHabits;
}

const List<SimWifiNetwork> wifiNetworks = <SimWifiNetwork>[
  SimWifiNetwork(
    id: 'cafe_guest',
    name: 'Cafe Corner Guest',
    subtitle: 'Free Wi-Fi • password from the counter',
    description:
        'This is the venue network printed on the receipt and confirmed by staff. It still is not perfect, but it is the most trustworthy option in this room.',
    priceLabel: 'Free',
    securityLabel: 'Password protected',
    trustLabel: 'Staff confirmed',
    showUnsecureLabel: false,
    opensUserToSnooping: false,
    hints: [
      'The name matches the venue branding exactly.',
      'Staff can confirm the network and password.',
      'Password protection is better than an open hotspot anyone can impersonate.',
    ],
    exposureExamples: [
      'Even on a legitimate network, the operator may still see what sites you visit at a high level if your traffic is not fully protected.',
    ],
    attackerMoves: [
      'Legitimate networks are still public spaces, so you should avoid sensitive logins unless needed.',
    ],
    saferHabits: [
      'Prefer password-protected venue Wi-Fi over random open hotspots.',
      'Use HTTPS and avoid handling banking or sensitive accounts unless necessary.',
      'Turn off auto-join when you leave.',
    ],
  ),
  SimWifiNetwork(
    id: 'free_airport_wifi',
    name: 'Free Airport WiFi',
    subtitle: 'Open network • no password',
    description:
        'This looks convenient and common, but it is completely open. That makes nearby snooping and fake captive-portal tricks much easier.',
    priceLabel: 'Free',
    securityLabel: 'Open network',
    trustLabel: 'Public hotspot',
    showUnsecureLabel: false,
    opensUserToSnooping: true,
    hints: [
      'No password means anyone nearby can join and monitor the hotspot environment.',
      'Generic names are easy to copy and spoof.',
      'Open public Wi-Fi is often the riskiest choice if safer alternatives exist.',
    ],
    exposureExamples: [
      'Domains you visit and app connections can often be observed as traffic metadata.',
      'If you type into a fake captive portal, the hotspot owner can collect that data directly.',
      'Unprotected sessions and downloads are easier to tamper with.',
    ],
    attackerMoves: [
      'Clone a normal-sounding hotspot name so users join the wrong network.',
      'Inject fake sign-in or update pages before you reach the real site.',
      'Watch for high-value actions like logins, downloads, or payment attempts.',
    ],
    saferHabits: [
      'Choose venue-confirmed Wi-Fi with a password when possible.',
      'Use mobile data or a trusted hotspot for sensitive accounts.',
      'Never enter credentials into surprise captive portals without verifying them.',
    ],
  ),
  SimWifiNetwork(
    id: 'coffeehouse_public',
    name: 'Coffeehouse_Public',
    subtitle: 'Open network • marked by the device as unsecure',
    description:
        'The device itself is warning you that this is an unsecure network. That is a strong hint to back out unless you have no better option and know how to protect yourself.',
    priceLabel: 'Free',
    securityLabel: 'Open network',
    trustLabel: 'Device warning shown',
    showUnsecureLabel: true,
    opensUserToSnooping: true,
    hints: [
      'The unsecure warning is there for a reason.',
      'Open Wi-Fi combined with a generic public name is a risky mix.',
      'Nothing ties this network clearly to the actual venue.',
    ],
    exposureExamples: [
      'A hotspot operator can log when your device connects and what services it reaches.',
      'They can present fake captive pages to capture email, social, or app sign-ins.',
      'They can manipulate or downgrade unsecured traffic.',
    ],
    attackerMoves: [
      'Use the hotspot as bait because many people ignore the warning label.',
      'Collect data from users who assume “free Wi-Fi” means harmless.',
      'Push phishing pages that look like normal hotel or cafe access screens.',
    ],
    saferHabits: [
      'Treat an unsecure label as a reason to pause, not something to dismiss.',
      'Ask staff for the correct Wi-Fi name.',
      'Disable auto-join for public networks.',
    ],
  ),
  SimWifiNetwork(
    id: 'staff_backoffice',
    name: 'Cafe Corner Staff',
    subtitle: 'Locked network • not for guests',
    description:
        'This is protected, but it is not meant for customers and you cannot verify that you should be on it. Password protection alone does not make a network the right choice.',
    priceLabel: 'Restricted',
    securityLabel: 'Password protected',
    trustLabel: 'Not intended for guests',
    showUnsecureLabel: false,
    opensUserToSnooping: false,
    hints: [
      'A locked network is not automatically the best one if it is not intended for you.',
      'Using the wrong network can still expose you to policy or security problems.',
    ],
    exposureExamples: [
      'Joining internal networks you do not trust or understand can expose your device to unnecessary risk.',
    ],
    attackerMoves: [
      'Attackers sometimes imitate employee or back-office names to look more legitimate than guest Wi-Fi.',
    ],
    saferHabits: [
      'Pick the network the venue actually tells guests to use.',
      'Do not assume “locked” means trustworthy without context.',
    ],
  ),
  SimWifiNetwork(
    id: 'city_free_secure',
    name: 'City WiFi Secure',
    subtitle: 'Free Wi-Fi • sign-in through the official city portal',
    description:
        'This is another comparatively safer choice because it is branded, documented, and protected, though you should still avoid unnecessary sensitive activity.',
    priceLabel: 'Free',
    securityLabel: 'Protected sign-in',
    trustLabel: 'Official portal',
    showUnsecureLabel: false,
    opensUserToSnooping: false,
    hints: [
      'Official branding and real documentation are useful trust signals.',
      'Protected access is usually safer than wide-open Wi-Fi.',
      'Safer does not mean zero risk.',
    ],
    exposureExamples: [
      'Even better-managed public Wi-Fi can still reveal some metadata and remains a shared environment.',
    ],
    attackerMoves: [
      'Attackers may copy official-sounding public network names nearby to confuse users.',
    ],
    saferHabits: [
      'Verify official public Wi-Fi names from signage or the organization website.',
      'Keep software updated and prefer HTTPS sites.',
      'Use MFA and avoid highly sensitive tasks when possible.',
    ],
  ),
];
