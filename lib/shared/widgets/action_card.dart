// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../core/theme/tokens.dart';

// class ActionCard extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;
//   final Color? color;
//   final Widget? trailing;
//   final Widget? leadingWidget;

//   const ActionCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//     this.color,
//     this.trailing,
//     this.leadingWidget,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final primaryColor = color ?? theme.colorScheme.primary;

//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? AppTokens.darkCard : AppTokens.lightCard,
//         borderRadius: AppTokens.borderRadiusXl,
//         border: Border.all(
//           color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
//           width: 1,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: AppTokens.borderRadiusXl,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 16.0,
//             ),
//             child: Row(
//               children: [
//                 leadingWidget ??
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: primaryColor.withValues(alpha: 0.12),
//                         borderRadius: AppTokens.borderRadiusMd,
//                       ),
//                       child: Icon(icon, color: primaryColor, size: 22),
//                     ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         title,
//                         style: GoogleFonts.outfit(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w700,
//                           color: isDark
//                               ? AppTokens.darkForeground
//                               : AppTokens.lightForeground,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         subtitle,
//                         style: GoogleFonts.outfit(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w400,
//                           color: isDark
//                               ? AppTokens.darkMutedForeground
//                               : AppTokens.lightMutedForeground,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 trailing ??
//                     Icon(
//                       Icons.chevron_right_rounded,
//                       color: isDark
//                           ? AppTokens.darkMutedForeground
//                           : AppTokens.lightMutedForeground,
//                       size: 20,
//                     ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
