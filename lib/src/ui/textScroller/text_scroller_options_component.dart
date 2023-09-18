// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teleprompter/src/data/state/teleprompter_state.dart';
import 'package:teleprompter/src/shared/my_snack_bar.dart';
import 'package:teleprompter/src/ui/textScroller/options/text_option_modify_component.dart';
import 'package:teleprompter/src/ui/textScroller/options/text_option_navigator_icon_component.dart';
import 'package:teleprompter/src/ui/timer/stopwatch_widget.dart';

class TextScrollerOptionsComponent extends StatelessWidget {
  final int index;
  final UpdateIndexCallback? updateIndex;
  final Color? sliderColor;
  final String savedToGallery;
  final String errorSavingToGallery;
  final String opacityLabel;
  final String speedLabel;
  final String fontSizeLabel;
  final String pauseLabel;
  final String playLabel;

  const TextScrollerOptionsComponent({
    required this.index,
    required this.updateIndex,
    required this.savedToGallery,
    required this.errorSavingToGallery,
    required this.opacityLabel,
    required this.speedLabel,
    required this.fontSizeLabel,
    required this.pauseLabel,
    required this.playLabel,
    this.sliderColor = Colors.blue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TeleprompterState teleprompterState = Provider.of<TeleprompterState>(context, listen: false);

    return SizedBox(
      height: teleprompterState.getShowValue()?225:177,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            if(teleprompterState.getShowValue())Slider(
              value: teleprompterState.getValueForIndex(index),
              min: teleprompterState.minValueForIndex(index),
              max: teleprompterState.maxValueForIndex(index),
              activeColor: sliderColor,
              onChanged: (value) {
                final double old = teleprompterState.getValueForIndex(index);
                final double min = teleprompterState.minValueForIndex(index);
                final double max = teleprompterState.maxValueForIndex(index);
                if (old > value && value > min) {
                  teleprompterState.decreaseValueForIndex(index);
                } else if (old < value && value < max) {
                  teleprompterState.increaseValueForIndex(index);
                }
              },
            ),
            SizedBox(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: NavigationBar(
                height: 100,
                backgroundColor: Colors.transparent,
                onDestinationSelected: (index) {
                  if(teleprompterState.getOptionIndex() == index){
                    teleprompterState.toggleShowHide();
                  }
                  else{
                    updateIndex!(index);
                  }
                },
                selectedIndex: teleprompterState.getOptionIndex(),
                destinations: [
                  NavigationDestination(
                      icon: Icon(
                        Icons.opacity,
                      ),
                      label: opacityLabel),
                  NavigationDestination(
                    icon: Icon(
                      Icons.speed,
                    ),
                    label: speedLabel,
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.text_format,
                    ),
                    label: fontSizeLabel,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  // onTap: teleprompterState.toggleCamera,
                  onTap: teleprompterState.toggleStartStop,
                  child: Container(
                    height: 50,
                    width: 125,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sliderColor,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: Text(teleprompterState.isScrolling() ? pauseLabel : playLabel, style: TextStyle(color: Colors.white)),
                  ),
                ),
                Flexible(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: teleprompterState.isRecording()
                        ? IconButton(
                            onPressed: () async {
                              final bool success = await teleprompterState.stopRecording();
                              teleprompterState.refresh();

                              if (success) {
                                MySnackBar.show(
                                  context: context,
                                  text: savedToGallery,
                                );
                              } else {
                                MySnackBar.showError(
                                  context: context,
                                  text: errorSavingToGallery,
                                );
                              }
                            },
                            icon: Icon(Icons.stop, color: Colors.red),
                          )
                        : IconButton(
                            onPressed: () {
                              teleprompterState.startRecording(teleprompterState);
                              teleprompterState.refresh();
                            },
                            icon: Icon(Icons.fiber_manual_record_sharp, color: Colors.red),
                          ),
                  ),
                ),
                Container(
                  height: 50,
                  width: 125,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sliderColor,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: teleprompterState.isRecording()
                      ? StopwatchWidget()
                      : FittedBox(
                          child: Text(
                            '00:00:00',
                            overflow: TextOverflow.fade,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
