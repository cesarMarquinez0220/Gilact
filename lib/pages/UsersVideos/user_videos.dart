import 'package:flutter/material.dart';
import 'package:flutter_login/pages/UsersVideos/search_json.dart';
import 'package:google_fonts/google_fonts.dart';

class User_videos extends StatefulWidget {
  const User_videos({super.key});

  @override
  State<User_videos> createState() => _User_videosState();
}

class _User_videosState extends State<User_videos> {
   int _selectedIndex = 0;
   
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(119, 2, 80, 71),
      appBar: getAppBar(),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.transparent, 
        selectedItemColor: Color.fromARGB(255, 114, 215, 249), 
        unselectedItemColor: Color.fromARGB(255, 255, 255, 255).withOpacity(0.60), 
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget getAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Container(
        height: 35,
        width: double.infinity,
        margin: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.40),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Buscar",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(0.5),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 10.0), 
          ),
        ),
      ),
    );
  }

  SingleChildScrollView getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
     child: Padding(
       padding: const EdgeInsets.only(top: 35, left: 20, right: 18),
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Videos Disponibles",
            style: TextStyle(
              fontFamily: 'Quicksand',
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Column(
            children: List.generate(searchJson.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: (size.width - 40) * 0.8,
                      height: 80,
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 70,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                    image: AssetImage(searchJson[index]['img']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 15),
                          Container(
                            width: (size.width - 36) * 0.4,
                            child: Text(
                              searchJson[index]['title'],
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: (size.width - 36) * 0.2,
                      height: 80,
                      child: Center(
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.white),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              );
            })
          ),
        ],
       ),
     ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}


