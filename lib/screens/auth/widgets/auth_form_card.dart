import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import '../../../utils/colors.dart';

class AuthFormCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String buttonText;
  final VoidCallback onSubmit;
  final bool loading;
  final Widget? footer;
  final String? logopath;
  final Color? buttonTextColor;
  final bool useCard;

  const AuthFormCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.buttonText,
    required this.onSubmit,
    required this.loading,
    this.footer,
    this.logopath,
    this.buttonTextColor,
    this.useCard = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: useCard ? _buildCardStyle(context) : _buildPlainStyle(context),
      ),
    );
  }

  Widget _buildCardStyle(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildFormContent(context),
        ),
      ),
    );
  }

  Widget _buildPlainStyle(BuildContext context) {
    return VStack([
      50.heightBox,
      if (logopath != null) Center(child: Image.asset(logopath!, height: 200)),
      20.heightBox,
      title.text.xl3.bold.color(AppColors.textDark).make(),
      10.heightBox,
      subtitle.text.color(AppColors.textLight).make(),
      30.heightBox,
      ...fields.map((f) => VStack([f, 10.heightBox])),
      10.heightBox,
      loading
          ? const _AnimatedLoader()
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: onSubmit,
              child: buttonText.text.white.xl.make(),
            ).wFull(context),
      if (footer != null) ...[10.heightBox, footer!],
    ]).scrollVertical().p16().centered();
  }

  List<Widget> _buildFormContent(BuildContext context) {
    return [
      if (logopath != null) Image.asset(logopath!, height: 160),
      Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.textLight),
      ),
      const SizedBox(height: 20),
      ...fields.map(
        (field) =>
            Padding(padding: const EdgeInsets.only(bottom: 10), child: field),
      ),
      const SizedBox(height: 10),
      loading
          ? const SizedBox(height: 60, child: Center(child: _AnimatedLoader()))
          : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: onSubmit,
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: buttonTextColor ?? Colors.white,
                  ),
                ),
              ),
            ),
      if (footer != null) ...[const SizedBox(height: 20), footer!],
    ];
  }
}

// Animated Loader Widget
class _AnimatedLoader extends StatefulWidget {
  const _AnimatedLoader();

  @override
  State<_AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<_AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _controller,
      child: Icon(Icons.fastfood, size: 36, color: AppColors.primary),
    );
  }
}
