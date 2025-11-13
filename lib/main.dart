import 'package:knob_widget/knob_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knob Example',
      home: const ArchSlider(),
    );
  }
}






class ArchSlider extends StatefulWidget {
  final void Function(double)? onChanged; // optional callback
  const ArchSlider({super.key, this.onChanged});

  @override
  State<ArchSlider> createState() => _ArchSliderState();
}

class _ArchSliderState extends State<ArchSlider> with SingleTickerProviderStateMixin {
  double manTemp = 20.0;
  double realTemp = 24.7;
  int selectedIndex = 1;
  static const programs = {
    0:"Week",
    1:"Comfort",
    2:"Eco",
    3:"Manual"
  };
  Map<int,double> programSettings = {
    0:20.0,
    1:25.0,
    2:15.0,
  };
  late double setTemp;









  final double _minimum = 10;
  final double _maximum = 30;
  late KnobController _controller;
  late double _knobValue;

  //ANIMATION
  late AnimationController _animController;
  late Animation<double> _animation;

  static const LinearGradient shadeGradient = LinearGradient(colors: [Color.fromARGB(255, 255, 36, 21),Color(0xFFd93529),Color(0xFF387adf)]);


  @override
  void initState() {


    super.initState();

    setTemp = programSettings[selectedIndex] ?? manTemp;

    //ANIMATION
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );



    //KNOB
    _knobValue = setTemp;
    _controller = KnobController(
      initial: _knobValue,
      minimum: _minimum,
      maximum: _maximum,
      startAngle: -10,
      endAngle: 190,
    );

    _controller.addOnValueChangedListener(valueChangedListener);
  }




  bool _isAnimating = false;

  void valueChangedListener(double value) {
    setState(() {
      manTemp = value;
      setTemp = manTemp;      
    });

  }

  void animateKnob(double value){
    if (_isAnimating) return;

    _isAnimating = true;
    _animController.stop();

    _animation = Tween<double>(
      begin: setTemp,
      end: value,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    ))
      ..addListener(() {
        setState(() {
          setTemp = _animation.value;
          _controller.setCurrentValue(_animation.value);
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          _isAnimating = false;
        }
      });

    _animController
      ..reset()
      ..forward();
    
  }


  Color getColorFromGradient(Gradient gradient, double t) {
    final colors = gradient.colors;
    final stops = gradient.stops ?? 
        List.generate(colors.length, (i) => i / (colors.length - 1));

    for (int i = 0; i < stops.length - 1; i++) {
      if (t >= stops[i] && t <= stops[i + 1]) {
        final localT = (t - stops[i]) / (stops[i + 1] - stops[i]);
        return Color.lerp(colors[i], colors[i + 1], localT)!;
      }
    }
    return colors.last;
  }



  @override
  Widget build(BuildContext context) {
    void resetManTemp(){
      setState(() {
        manTemp = setTemp;        
      });
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Center(child:Text("Test"))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Spacer(),
            SizedBox(
              height: 150,
              child: Center(
                child: selectedIndex == 3 ? Text("Nastaviť teplotu na:\n${setTemp.toStringAsFixed(1)} °C",style: TextStyle(fontSize: 32),textAlign: TextAlign.center,) : Text("Program:\n${programs[selectedIndex]}\n${setTemp.toStringAsFixed(1)}°C",style: TextStyle(fontSize: 32),textAlign: TextAlign.center,)
              )
            ),
            Spacer(),

            Knob(
              controller: _controller,
              width: 250,
              height: 250,
              enable: selectedIndex == 3,
              style: KnobStyle(
                labelStyle: TextStyle(fontSize: 16),
                showMinorTickLabels: false,
                tickOffset: 5,
                labelOffset: 10,
                minorTicksPerInterval: 2,
                pointerStyle: PointerStyle(color:getColorFromGradient(shadeGradient, _maximum/setTemp-1)),
                majorTickStyle: MajorTickStyle(highlightColor: getColorFromGradient(shadeGradient, _maximum/setTemp-1), color: getColorFromGradient(shadeGradient, _maximum/setTemp-1)),
                minorTickStyle: MinorTickStyle(highlightColor: getColorFromGradient(shadeGradient, _maximum/setTemp-1), color: getColorFromGradient(shadeGradient, _maximum/setTemp-1)),
                controlStyle: ControlStyle(tickStyle: ControlTickStyle(count: 20), shadowColor: getColorFromGradient(shadeGradient, _maximum/setTemp-1),glowColor: getColorFromGradient(shadeGradient, _maximum/setTemp-1))
              ),
            ),
            Spacer(),
            
            SizedBox(
              height: 60,
              width: screenWidth-40,
              child: Center(
                child:CustomSlidingSegmentedControl<int>(
                  initialValue: selectedIndex,
                  isStretch: true,
                  height: 60,
                  children: {
                    0: Center(child: SvgPicture.asset("week.svg", height: 50, width: 50,fit: BoxFit.contain, colorFilter:  selectedIndex == 0 ?  ColorFilter.mode(Color(0xFF746258), BlendMode.srcIn) : ColorFilter.mode(Color(0xFFA2958F), BlendMode.srcIn),)),
                    1: Center(child: SvgPicture.asset("comfort.svg", height: 50, width: 50,fit: BoxFit.contain, colorFilter:  selectedIndex == 1 ?  ColorFilter.mode(Color(0xFF746258), BlendMode.srcIn) : ColorFilter.mode(Color(0xFFA2958F), BlendMode.srcIn),)),
                    2: Center(child: SvgPicture.asset("eco.svg", height: 50, width: 50,fit: BoxFit.contain, colorFilter:  selectedIndex == 2 ?  ColorFilter.mode(Color(0xFF746258), BlendMode.srcIn) : ColorFilter.mode(Color(0xFFA2958F), BlendMode.srcIn),)),
                    3: Center(child: SvgPicture.asset("man.svg", height: 50, width: 50,fit: BoxFit.contain, colorFilter:  selectedIndex == 3 ?  ColorFilter.mode(Color(0xFF746258), BlendMode.srcIn) : ColorFilter.mode(Color(0xFFA2958F), BlendMode.srcIn),)),
                  },
                  decoration: BoxDecoration(
                    color: CupertinoColors.lightBackgroundGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  thumbDecoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 4.0,
                        spreadRadius: 2.0,
                        offset: Offset(
                          0.0,
                          4.0,
                        ),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  onValueChanged: (index) => setState(() { 
                    selectedIndex = index;
                    if (index != 3){
                      animateKnob(programSettings[index]??0.0); 
                    } else {
                      resetManTemp();
                      animateKnob(manTemp);
                    }
                  })
                ),
              )
            ),
            Spacer(),
            SizedBox(
              height: 50,
              width: screenWidth-100,
              child: TextButton(onPressed: (){}, style: ButtonStyle(backgroundColor:WidgetStateProperty.all(Color(0xFF387adf)),shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))), child: Text("Uložiť zmenu",style: TextStyle(fontSize: 24,color: Colors.white))),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }
}
