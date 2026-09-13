import 'package:flutter/material.dart';

class ProjectModel {
  String id;
  String name;
  String city;
  String propertyType;
  double? projectArea;
  String? description;
  String selectedRoom;
  double roomLength;
  double roomWidth;
  double roomHeight;
  String unit; // 'ft' or 'in'
  DateTime createdAt;

  // Calculator results
  double flooringCost;
  double paintCost;
  double tilesCost;
  double ceilingCost;
  double doorsWindowsCost;
  double furnitureCost;
  double electricalCost;
  double plumbingCost;

  // Flooring
  String selectedFlooringMaterial;
  double flooringWastage;

  // Paint
  double paintWallHeight;
  String paintType;
  double paintCoats;
  double paintCoverage;

  // Tiles
  String tilesType; // 'floor' or 'wall'
  String tileSize;
  double tilesWastage;
  double tilePrice;

  // Ceiling
  String ceilingType;
  double ceilingRatePerSqFt;

  // Doors & Windows
  int mainDoors;
  int roomDoors;
  int bathroomDoors;
  int windows;
  int ventilators;

  // Furniture
  Map<String, int> furnitureItems;

  // Which calculators the user selected to use in this project
  List<String> selectedCalculators;

  ProjectModel({
    required this.id,
    required this.name,
    this.city = 'Lahore, Pakistan',
    this.propertyType = 'House',
    this.projectArea,
    this.description,
    this.selectedRoom = 'Living Room',
    this.roomLength = 15,
    this.roomWidth = 12,
    this.roomHeight = 10,
    this.unit = 'ft',
    DateTime? createdAt,
    this.flooringCost = 0,
    this.paintCost = 0,
    this.tilesCost = 0,
    this.ceilingCost = 0,
    this.doorsWindowsCost = 0,
    this.furnitureCost = 0,
    this.electricalCost = 45000,
    this.plumbingCost = 25000,
    this.selectedFlooringMaterial = 'Tiles',
    this.flooringWastage = 10,
    this.paintWallHeight = 10,
    this.paintType = 'Emulsion Paint',
    this.paintCoats = 2,
    this.paintCoverage = 160,
    this.tilesType = 'floor',
    this.tileSize = '2 x 2 ft (24 x 24 inch)',
    this.tilesWastage = 10,
    this.tilePrice = 150,
    this.ceilingType = 'Plain',
    this.ceilingRatePerSqFt = 200,
    this.mainDoors = 1,
    this.roomDoors = 2,
    this.bathroomDoors = 1,
    this.windows = 2,
    this.ventilators = 1,
    Map<String, int>? furnitureItems,
    List<String>? selectedCalculators,
  })  : createdAt = createdAt ?? DateTime.now(),
        furnitureItems = furnitureItems ??
            {
              'Sofa Set': 1,
              'TV Unit': 1,
              'Coffee Table': 1,
              'Curtains': 2,
              'Lights': 4,
            },
        selectedCalculators = selectedCalculators ??
            ['flooring', 'paint', 'tiles', 'ceiling', 'doors_windows', 'furniture', 'electrical', 'plumbing'];

  double get roomArea => roomLength * roomWidth;

  double get totalEstimatedCost {
    double total = 0;
    for (final key in selectedCalculators) {
      switch (key) {
        case 'flooring':      total += flooringCost; break;
        case 'paint':         total += paintCost; break;
        case 'tiles':         total += tilesCost; break;
        case 'ceiling':       total += ceilingCost; break;
        case 'doors_windows': total += doorsWindowsCost; break;
        case 'furniture':     total += furnitureCost; break;
        case 'electrical':    total += electricalCost; break;
        case 'plumbing':      total += plumbingCost; break;
      }
    }
    return total;
  }

  String formattedTotal(String currencySymbol) =>
      '$currencySymbol ${totalEstimatedCost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  // ── SQLite serialization ─────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'propertyType': propertyType,
      'projectArea': projectArea,
      'description': description,
      'selectedRoom': selectedRoom,
      'roomLength': roomLength,
      'roomWidth': roomWidth,
      'roomHeight': roomHeight,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'flooringCost': flooringCost,
      'paintCost': paintCost,
      'tilesCost': tilesCost,
      'ceilingCost': ceilingCost,
      'doorsWindowsCost': doorsWindowsCost,
      'furnitureCost': furnitureCost,
      'electricalCost': electricalCost,
      'plumbingCost': plumbingCost,
      'selectedFlooringMaterial': selectedFlooringMaterial,
      'flooringWastage': flooringWastage,
      'paintWallHeight': paintWallHeight,
      'paintType': paintType,
      'paintCoats': paintCoats,
      'paintCoverage': paintCoverage,
      'tilesType': tilesType,
      'tileSize': tileSize,
      'tilesWastage': tilesWastage,
      'tilePrice': tilePrice,
      'ceilingType': ceilingType,
      'ceilingRatePerSqFt': ceilingRatePerSqFt,
      'mainDoors': mainDoors,
      'roomDoors': roomDoors,
      'bathroomDoors': bathroomDoors,
      'windows': windows,
      'ventilators': ventilators,
      // Store furniture as "key1:qty1,key2:qty2"
      'furnitureItems': furnitureItems.entries
          .map((e) => '${e.key}:${e.value}')
          .join(','),
      'selectedCalculators': selectedCalculators.join(','),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    // Parse furniture string back to map
    Map<String, int> furniture = {};
    final furnitureStr = map['furnitureItems'] as String? ?? '';
    if (furnitureStr.isNotEmpty) {
      for (final part in furnitureStr.split(',')) {
        final kv = part.split(':');
        if (kv.length == 2) {
          furniture[kv[0]] = int.tryParse(kv[1]) ?? 0;
        }
      }
    }
    return ProjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      city: map['city'] as String? ?? 'Lahore, Pakistan',
      propertyType: map['propertyType'] as String? ?? 'House',
      projectArea: map['projectArea'] as double?,
      description: map['description'] as String?,
      selectedRoom: map['selectedRoom'] as String? ?? 'Living Room',
      roomLength: (map['roomLength'] as num?)?.toDouble() ?? 15,
      roomWidth: (map['roomWidth'] as num?)?.toDouble() ?? 12,
      roomHeight: (map['roomHeight'] as num?)?.toDouble() ?? 10,
      unit: map['unit'] as String? ?? 'ft',
      createdAt: DateTime.parse(map['createdAt'] as String),
      flooringCost: (map['flooringCost'] as num?)?.toDouble() ?? 0,
      paintCost: (map['paintCost'] as num?)?.toDouble() ?? 0,
      tilesCost: (map['tilesCost'] as num?)?.toDouble() ?? 0,
      ceilingCost: (map['ceilingCost'] as num?)?.toDouble() ?? 0,
      doorsWindowsCost: (map['doorsWindowsCost'] as num?)?.toDouble() ?? 0,
      furnitureCost: (map['furnitureCost'] as num?)?.toDouble() ?? 0,
      electricalCost: (map['electricalCost'] as num?)?.toDouble() ?? 45000,
      plumbingCost: (map['plumbingCost'] as num?)?.toDouble() ?? 25000,
      selectedFlooringMaterial: map['selectedFlooringMaterial'] as String? ?? 'Tiles',
      flooringWastage: (map['flooringWastage'] as num?)?.toDouble() ?? 10,
      paintWallHeight: (map['paintWallHeight'] as num?)?.toDouble() ?? 10,
      paintType: map['paintType'] as String? ?? 'Emulsion Paint',
      paintCoats: (map['paintCoats'] as num?)?.toDouble() ?? 2,
      paintCoverage: (map['paintCoverage'] as num?)?.toDouble() ?? 160,
      tilesType: map['tilesType'] as String? ?? 'floor',
      tileSize: map['tileSize'] as String? ?? '2 x 2 ft (24 x 24 inch)',
      tilesWastage: (map['tilesWastage'] as num?)?.toDouble() ?? 10,
      tilePrice: (map['tilePrice'] as num?)?.toDouble() ?? 150,
      ceilingType: map['ceilingType'] as String? ?? 'Plain',
      ceilingRatePerSqFt: (map['ceilingRatePerSqFt'] as num?)?.toDouble() ?? 200,
      mainDoors: (map['mainDoors'] as num?)?.toInt() ?? 1,
      roomDoors: (map['roomDoors'] as num?)?.toInt() ?? 2,
      bathroomDoors: (map['bathroomDoors'] as num?)?.toInt() ?? 1,
      windows: (map['windows'] as num?)?.toInt() ?? 2,
      ventilators: (map['ventilators'] as num?)?.toInt() ?? 1,
      furnitureItems: furniture,
      selectedCalculators: (map['selectedCalculators'] as String? ?? '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
    );
  }
}


// Flooring materials with price per sq ft
const Map<String, double> kFlooringMaterials = {
  'Tiles': 220,
  'Marble': 450,
  'Vinyl': 180,
  'Wooden': 550,
  'Granite': 600,
};

// Furniture items with prices
const Map<String, double> kFurniturePrices = {
  'Sofa Set': 45000,
  'TV Unit': 25000,
  'Coffee Table': 12000,
  'Curtains': 5000,
  'Lights': 2000,
  'Dining Table': 35000,
  'Bed': 40000,
  'Wardrobe': 30000,
};

// Ceiling types
const Map<String, double> kCeilingTypes = {
  'Plain': 200,
  'False Ceiling (Gypsum)': 350,
  'False Ceiling (PVC)': 280,
  'Wooden': 500,
};

// Door prices
const Map<String, double> kDoorPrices = {
  'Main Door': 25000,
  'Room Doors': 15000,
  'Bathroom Doors': 12000,
};

// Window prices
const Map<String, double> kWindowPrices = {
  'Windows': 9500,
  'Ventilators': 3000,
};

// Property types
const List<String> kPropertyTypes = ['House', 'Apartment', 'Office'];

// Pakistani cities
const List<String> kPakistaniCities = [
  'Lahore, Pakistan',
  'Karachi, Pakistan',
  'Islamabad, Pakistan',
  'Rawalpindi, Pakistan',
  'Faisalabad, Pakistan',
  'Multan, Pakistan',
  'Peshawar, Pakistan',
  'Quetta, Pakistan',
];

// Rooms
const List<Map<String, dynamic>> kRooms = [
  {'name': 'Living Room', 'icon': Icons.weekend},
  {'name': 'Bedroom', 'icon': Icons.bed},
  {'name': 'Kitchen', 'icon': Icons.kitchen},
  {'name': 'Bathroom', 'icon': Icons.bathtub},
  {'name': 'Dining Room', 'icon': Icons.dining},
  {'name': 'Office', 'icon': Icons.desk},
  {'name': 'Kids Room', 'icon': Icons.child_care},
  {'name': 'Other Room', 'icon': Icons.door_back_door},
];
