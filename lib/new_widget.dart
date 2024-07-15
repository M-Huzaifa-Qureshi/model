import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScrlBar extends StatefulWidget {
  const ScrlBar({super.key});

  @override
  State<ScrlBar> createState() => _ScrlBarState();
}

class _ScrlBarState extends State<ScrlBar> {
  // final ScrollController _scrollController = ScrollController(initialScrollOffset: 10);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              radius: const Radius.circular(30),
              scrollbarOrientation:ScrollbarOrientation.left ,
              // controller: _scrollController,
              showTrackOnHover: true,
              thickness: 5,
              interactive: true,
              thumbVisibility: true,
              trackVisibility: true,
              child: ListView.builder(
                itemCount: 20,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return const SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Column(
                      children: [
                        Center(child: Text("huzzah "))
                      ],
                    ),
                  );
                },),
            ),
          ),

        ],
      ),
    );
  }
}
