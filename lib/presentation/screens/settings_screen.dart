import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/toast_utils.dart';
import '../../data/models/settings_model.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../blocs/settings/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _modelNameController = TextEditingController();
  bool _controllersSynced = false;
  bool _saveRequested = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  void _syncControllers(SettingsModel settings) {
    if (_controllersSynced &&
        _apiKeyController.text == settings.apiKey &&
        _baseUrlController.text == settings.baseUrl &&
        _modelNameController.text == settings.modelName) {
      return;
    }

    _apiKeyController.text = settings.apiKey;
    _baseUrlController.text = settings.baseUrl;
    _modelNameController.text = settings.modelName;
    _controllersSynced = true;
  }

  SettingsModel _settingsFromControllers({required bool darkMode}) {
    return SettingsModel(
      apiKey: _apiKeyController.text,
      baseUrl: _baseUrlController.text,
      modelName: _modelNameController.text,
      darkMode: darkMode,
    );
  }

  void _saveSettings(BuildContext context, {required bool darkMode}) {
    _saveRequested = true;
    context.read<SettingsBloc>().add(
          SaveSettings(_settingsFromControllers(darkMode: darkMode)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listenWhen: (previous, current) =>
            current is SettingsLoaded || current is SettingsError,
        listener: (context, state) {
          if (state is SettingsLoaded && _saveRequested) {
            _saveRequested = false;
            _syncControllers(state.settings);
            showSuccessToast(context);
          } else if (state is SettingsError) {
            _saveRequested = false;
            showErrorToast(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is SettingsLoaded) {
            _syncControllers(state.settings);
          }

          final darkMode =
              state is SettingsLoaded ? state.settings.darkMode : false;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(
                icon: Icons.api_outlined,
                title: 'API Configuration',
              ),
              const SizedBox(height: 12),
              _SettingsField(
                controller: _apiKeyController,
                label: 'API Key',
                hint: 'sk-...',
                icon: Icons.key_outlined,
                obscure: true,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                controller: _baseUrlController,
                label: 'Base URL',
                hint: 'https://api.openai.com/v1',
                icon: Icons.link_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                controller: _modelNameController,
                label: 'Model Name',
                hint: 'gpt-4o-mini',
                icon: Icons.smart_toy_outlined,
              ),
              const SizedBox(height: 24),
              _SectionHeader(
                icon: Icons.palette_outlined,
                title: 'Appearance',
              ),
              const SizedBox(height: 8),
              Material(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(12),
                child: SwitchListTile(
                  secondary: Icon(
                    darkMode ? Icons.dark_mode : Icons.light_mode,
                    color: colorScheme.primary,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle app theme'),
                  value: darkMode,
                  onChanged: (value) {
                    _saveSettings(context, darkMode: value);
                  },
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => _saveSettings(context, darkMode: darkMode),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save Settings'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SettingsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _SettingsField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
      ),
    );
  }
}
