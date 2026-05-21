import 'package:apna_business_app/app/routes/route_names.dart';
import 'package:apna_business_app/app/themes/app_colors.dart';
import 'package:apna_business_app/app/themes/app_dimensions.dart';
import 'package:apna_business_app/app/themes/app_text_styles.dart';
import 'package:apna_business_app/domain/entities/auth_session_entity.dart';
import 'package:apna_business_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:apna_business_app/presentation/widgets/buttons/primary_button.dart';
import 'package:apna_business_app/presentation/widgets/inputs/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

const List<Map<String, dynamic>> _shopTypes = [
  {'value': 'kirana',   'label': 'Kirana / Grocery', 'icon': Icons.shopping_basket_outlined},
  {'value': 'hardware', 'label': 'Hardware',          'icon': Icons.construction_outlined},
  {'value': 'medical',  'label': 'Medical / Pharma',  'icon': Icons.local_pharmacy_outlined},
  {'value': 'garments', 'label': 'Cloth / Garments',  'icon': Icons.checkroom_outlined},
  {'value': 'general',  'label': 'General / Other',   'icon': Icons.store_outlined},
];

/// First-time profile setup screen shown after OTP when is_new_user = true.
class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({required this.phone, super.key});

  final String phone;

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ValueNotifier<AutovalidateMode> _autoValidate =
      ValueNotifier<AutovalidateMode>(AutovalidateMode.disabled);

  String _selectedShopType = 'general';

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    _autoValidate.dispose();
    super.dispose();
  }

  void _submit() {
    _autoValidate.value = AutovalidateMode.onUserInteraction;
    if (_formKey.currentState?.validate() != true) return;
    context.read<AuthBloc>().add(
          AuthSetupBusinessRequested(
            fullName: _fullNameController.text.trim(),
            businessName: _businessNameController.text.trim(),
            location: _locationController.text.trim(),
            shopType: _selectedShopType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state is AuthSuccess &&
            state.session.status == AuthStatus.authenticated) {
          context.go(RouteNames.home);
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
        if (state is AuthValidationError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
              vertical: AppDimensions.space3XL,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.store_outlined,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spaceXXL),
                  const Text('Profile Setup', style: AppTextStyles.display),
                  const SizedBox(height: AppDimensions.spaceSM),
                  const Text(
                    'Apna naam, business ka naam, aur optional location batayein',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: AppDimensions.space3XL),
                  ValueListenableBuilder<AutovalidateMode>(
                    valueListenable: _autoValidate,
                    builder: (context, mode, _) {
                      return Form(
                        key: _formKey,
                        autovalidateMode: mode,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AppTextField(
                              controller: _fullNameController,
                              labelText: 'Full Name',
                              hintText: 'Akash Kumar',
                              textInputAction: TextInputAction.next,
                              validator: (String? v) {
                                if (v == null || v.trim().length < 2) {
                                  return 'Full name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppDimensions.spaceLG),
                            AppTextField(
                              controller: _businessNameController,
                              labelText: 'Business Name',
                              hintText: 'Yadav Kirana Store',
                              textInputAction: TextInputAction.next,
                              validator: (String? v) {
                                if (v == null || v.trim().length < 2) {
                                  return 'Business name must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppDimensions.spaceLG),
                            AppTextField(
                              controller: _locationController,
                              labelText: 'Location (Optional)',
                              hintText: 'Karol Bagh',
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                              validator: (String? v) {
                                final String value = v?.trim() ?? '';
                                if (value.isEmpty) return null;
                                if (value.length < 2) {
                                  return 'Location must be at least 2 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppDimensions.spaceXXL),
                            const Text('Shop Type', style: AppTextStyles.label),
                            const SizedBox(height: AppDimensions.spaceSM),
                            _ShopTypeSelector(
                              selected: _selectedShopType,
                              onChanged: (v) => setState(() => _selectedShopType = v),
                            ),
                            const SizedBox(height: AppDimensions.spaceXXL),
                            BlocBuilder<AuthBloc, AuthState>(
                              buildWhen: (p, c) =>
                                  (p is AuthLoading) != (c is AuthLoading),
                              builder: (context, state) {
                                return PrimaryButton(
                                  label: 'Continue',
                                  isLoading: state is AuthLoading,
                                  onPressed: _submit,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceXXL),
                  const _FeatureBullet(
                    icon: Icons.chat_bubble_outline,
                    text: 'Message bhejo — AI automatically samajh leta hai',
                  ),
                  const _FeatureBullet(
                    icon: Icons.auto_awesome_outlined,
                    text: 'Al samjhega — Hisab auto manage hoga',
                  ),
                  const _FeatureBullet(
                    icon: Icons.notifications_outlined,
                    text: 'Payment reminders auto-send karein',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShopTypeSelector extends StatelessWidget {
  const _ShopTypeSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _shopTypes.map((Map<String, dynamic> shop) {
        final bool isSelected = selected == shop['value'];
        return GestureDetector(
          onTap: () => onChanged(shop['value'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  shop['icon'] as IconData,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  shop['label'] as String,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  const _FeatureBullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppDimensions.spaceMD),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(text, style: AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}
