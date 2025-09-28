import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

List<Map<String,dynamic>> transactionData = [
  { 
    'name' : 'Food',
    'icon' : FaIcon(FontAwesomeIcons.burger, color: Colors.white,),
    'color' : Colors.yellow,
    'toatlAmount' : '-80',
    'date' : 'Today'
  },
  { 
    'name' : 'Shopping',
    'icon' : FaIcon(FontAwesomeIcons.bagShopping, color: Colors.white,),
    'color' : Colors.purple,
    'toatlAmount' : '-800',
    'date' : 'Today'
  },
  { 
    'name' : 'Travel',
    'icon' : FaIcon(FontAwesomeIcons.bus, color: Colors.white,),
    'color' : Colors.green,
    'toatlAmount' : '-50',
    'date' : 'Today'
  },
  { 
    'name' : 'Study',
    'icon' : FaIcon(FontAwesomeIcons.pencil, color: Colors.white,),
    'color' : Colors.blue,
    'toatlAmount' : '-100',
    'date' : 'Today'
  },
];