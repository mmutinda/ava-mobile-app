// import 'package:flutter/material.dart';

// class ProgressSteps extends StatelessWidget {
//   final int currentStep; // starts from 1
//   final int totalSteps;
//   final List<String> stepLabels;
//   final Color activeColor;
//   final Color nextStepColor;
//   final Color inactiveColor;

//   const ProgressSteps({
//     super.key,
//     required this.currentStep,
//     required this.stepLabels,
//     this.totalSteps = 4,
//     this.activeColor = const Color(0xFF2196F3),
//     this.nextStepColor = const Color(0xFF90CAF9),
//     this.inactiveColor = const Color(0xFFE0E0E0),
//   }) : assert(totalSteps == stepLabels.length,
//             'totalSteps must match the number of stepLabels');

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: List.generate(totalSteps, (index) {
//             bool isCompleted = index < currentStep;
//             bool isCurrent = index == currentStep;
//             bool isUpcoming = index > currentStep;

//             Color getStepColor() {
//               if (isCompleted) return activeColor;
//               if (isCurrent) return nextStepColor;
//               return inactiveColor;
//             }

//             Widget stepCircle = Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 gradient: isCompleted || isCurrent
//                     ? LinearGradient(
//                         colors: [activeColor, nextStepColor],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                     : LinearGradient(
//                         colors: [inactiveColor, inactiveColor],
//                       ),
//                 shape: BoxShape.circle,
//                 boxShadow: isCompleted
//                     ? [
//                         BoxShadow(
//                           color: activeColor.withOpacity(0.5),
//                           blurRadius: 6,
//                           offset: const Offset(0, 3),
//                         )
//                       ]
//                     : [],
//               ),
//               child: Center(
//                 child: Text(
//                   '${index + 1}',
//                   style: TextStyle(
//                     color: isCompleted || isCurrent
//                         ? Colors.white
//                         : Colors.black45,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             );

//             Widget connectorLine = Expanded(
//               child: Container(
//                 height: 4,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       index < currentStep - 1 ? activeColor : inactiveColor,
//                       index < currentStep ? nextStepColor : inactiveColor,
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//             );

//             return Expanded(
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       if (index != 0) connectorLine,
//                       stepCircle,
//                       if (index != totalSteps - 1) connectorLine,
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     stepLabels[index],
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight:
//                           isCurrent ? FontWeight.bold : FontWeight.normal,
//                       color: isCompleted || isCurrent
//                           ? Colors.black87
//                           : Colors.grey,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ],
//     );
//   }
// }
