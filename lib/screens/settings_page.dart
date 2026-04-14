import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../utils/ad_manager.dart';
import '../utils/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance Section
          const _SectionHeader(title: 'Appearance'),
          ListTile(
            leading: Icon(provider.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: AppTheme.primaryColor),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: provider.isDarkMode,
              onChanged: (_) => provider.toggleTheme(),
              activeTrackColor: AppTheme.primaryColor,
            ),
          ),
          const Divider(),

          // Premium Section
          const _SectionHeader(title: 'Premium Features'),
          Card(
            elevation: 0,
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Temporary Ad-Free Experience',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: provider.isDarkMode ? Colors.white : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Watch a short video to remove all banner ads for the next 10 minutes.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  if (provider.areAdsRemoved)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text('Ads Removed Successfully!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () {
                        AdManager.showRewarded(
                          onRewardEarned: (reward) {
                            provider.removeAdsFor(10);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ads removed for 10 minutes!')),
                            );
                          },
                          onAdClosed: () {},
                          onAdFailed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ad failed to load. Please try again later.')),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Remove Ads for 10 Minutes'),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'v1.0.0 | Built by Moiz Baloch',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
