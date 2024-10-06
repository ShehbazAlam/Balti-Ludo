import 'package:balti_ludo/constants.dart';
import 'package:flutter/material.dart'; 
import 'package:balti_ludo/ludo_provider.dart';
import 'package:balti_ludo/widgets/board_widget.dart';
import 'package:balti_ludo/widgets/dice_widget.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Row(
        children: [
          Image(image: AssetImage("assets/images/icon/icon.png"), width: 50, height: 50, fit: BoxFit.contain,),
          Text('Balti Ludo')
        ],
      ),),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 50, height: 50, child: Image(image: AssetImage('assets/images/player/p1.png'), fit: BoxFit.contain,)),
                          Consumer<LudoProvider>(
                            builder: (context, value, child) {
                              return value.currentPlayer.type == LudoPlayerType.green ? const SizedBox(width: 50, height: 50, child: DiceWidget(),) : const SizedBox(width: 50, height: 50,);
                            },
                            )
                        ],
                      ),
                      Row(
                        children: [
                          
                          Consumer<LudoProvider>(
                            builder: (context, value, child) {
                              return value.currentPlayer.type == LudoPlayerType.yellow ? const SizedBox(width: 50, height: 50, child: DiceWidget(),) : const SizedBox(width: 50, height: 50,);
                            },
                            ),
                            const SizedBox(width: 50, height: 50, child: Image(image: AssetImage('assets/images/player/p2.png'), fit: BoxFit.contain,)),
                        ],
                      )
                    ],),
                ),
                const BoardWidget(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 50, height: 50, child: Image(image: AssetImage('assets/images/player/p4.png'), fit: BoxFit.contain,)),
                          Consumer<LudoProvider>(
                            builder: (context, value, child) {
                              return value.currentPlayer.type == LudoPlayerType.red ? const SizedBox(width: 50, height: 50, child: DiceWidget(),) : const SizedBox(width: 50, height: 50,);
                            },
                            )
                        ],
                      ),
                      Row(
                        children: [
                          
                          Consumer<LudoProvider>(
                            builder: (context, value, child) {
                              return value.currentPlayer.type == LudoPlayerType.blue ? const SizedBox(width: 50, height: 50, child: DiceWidget(),) : const SizedBox(width: 50, height: 50,);
                            },
                            ),
                            const SizedBox(width: 50, height: 50, child: Image(image: AssetImage('assets/images/player/p3.png'), fit: BoxFit.contain,)),
                        ],
                      )
                    ],),
                ),
              ],
            ),
          ),
          Consumer<LudoProvider>(
            builder: (context, value, child) => value.winners.length == 3
                ? Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset("assets/images/thankyou.gif"),
                          const Text("Thank you for playing 😙", style: TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center),
                          Text("The Winners are: ${value.winners.map((e) => e.name.toUpperCase()).join(", ")}", style: const TextStyle(color: Colors.white, fontSize: 30), textAlign: TextAlign.center),
                          const Divider(color: Colors.white),
                          const Text("This game made with Flutter ❤️ by Shehbaz Alam", style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          TextButton(child: const Text("play again", style: TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center), onPressed: () => value.startGame(),),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
