import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../models/rates_model.dart';
import '../database/db_helper.dart';

// Ordered list of all available calculators
const List<Map<String, dynamic>> kAllCalculators = [
  {
    'key': 'flooring',
    'label': 'Flooring',
    'description': 'Tiles, marble, vinyl, wooden',
    'icon': Icons.grid_on,
    'color': Color(0xFF8B6914),
  },
  {
    'key': 'paint',
    'label': 'Paint',
    'description': 'Wall paint & coverage',
    'icon': Icons.format_paint,
    'color': Color(0xFF1565C0),
  },
  {
    'key': 'tiles',
    'label': 'Tiles',
    'description': 'Floor & wall tiles',
    'icon': Icons.view_module,
    'color': Color(0xFF4A148C),
  },
  {
    'key': 'ceiling',
    'label': 'Ceiling',
    'description': 'Plain, gypsum, PVC, wooden',
    'icon': Icons.workspaces,
    'color': Color(0xFF1B5E3B),
  },
  {
    'key': 'doors_windows',
    'label': 'Doors & Windows',
    'description': 'Doors, windows, ventilators',
    'icon': Icons.door_front_door,
    'color': Color(0xFF37474F),
  },
  {
    'key': 'furniture',
    'label': 'Furniture & Fixtures',
    'description': 'Sofa, beds, lighting',
    'icon': Icons.weekend,
    'color': Color(0xFF6A1B9A),
  },
  {
    'key': 'electrical',
    'label': 'Electrical',
    'description': 'Wiring, outlets, panels',
    'icon': Icons.electrical_services,
    'color': Color(0xFFE65100),
  },
  {
    'key': 'plumbing',
    'label': 'Plumbing',
    'description': 'Pipes, fittings, fixtures',
    'icon': Icons.plumbing,
    'color': Color(0xFF01579B),
  },
];

class ProjectProvider extends ChangeNotifier {
  List<ProjectModel> _projects = [];
  ProjectModel? _currentProject;
  int _newProjectStep = 1;
  bool _isLoading = false;

  // The ordered list of calculator keys chosen for this project
  List<String> _selectedCalculators = [];

  List<ProjectModel> get projects => _projects;
  ProjectModel? get currentProject => _currentProject;
  int get newProjectStep => _newProjectStep;
  bool get isLoading => _isLoading;
  List<String> get selectedCalculators => _selectedCalculators;

  double get totalEstimatedCost =>
      _projects.fold(0, (sum, p) => sum + p.totalEstimatedCost);

  // ── DB ─────────────────────────────────────────────────────────────────────

  Future<void> loadProjectsFromDb() async {
    _isLoading = true;
    notifyListeners();
    try {
      _projects = await DbHelper.instance.getProjects();
    } catch (e) {
      debugPrint('DB load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── New Project Flow ────────────────────────────────────────────────────────

  void startNewProject() {
    _currentProject = ProjectModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
    );
    _selectedCalculators = [];
    _newProjectStep = 1;
    notifyListeners();
  }

  void setSelectedCalculators(List<String> keys) {
    // Preserve the canonical order from kAllCalculators
    _selectedCalculators = kAllCalculators
        .map((c) => c['key'] as String)
        .where((k) => keys.contains(k))
        .toList();
    notifyListeners();
  }

  void updateCurrentProject(ProjectModel project) {
    _currentProject = project;
    notifyListeners();
  }

  void setProjectStep(int step) {
    _newProjectStep = step;
    notifyListeners();
  }

  Future<void> saveProject() async {
    if (_currentProject == null) return;
    // Persist selected calculators into the model before saving
    _currentProject = _copyWithCalculators(_currentProject!, _selectedCalculators);
    final idx = _projects.indexWhere((p) => p.id == _currentProject!.id);
    if (idx >= 0) {
      _projects[idx] = _currentProject!;
      await DbHelper.instance.updateProject(_currentProject!);
    } else {
      _projects.insert(0, _currentProject!);
      await DbHelper.instance.insertProject(_currentProject!);
    }
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects.removeWhere((p) => p.id == id);
    await DbHelper.instance.deleteProject(id);
    notifyListeners();
  }

  void selectProject(ProjectModel project) {
    _currentProject = project;
    _selectedCalculators = List.from(project.selectedCalculators);
    notifyListeners();
  }

  // ── Calculator Navigation ──────────────────────────────────────────────────

  /// Returns the screen widget for a given calculator key.
  /// Import the actual screen classes in the file that calls this.
  String? nextCalculatorKey(String currentKey) {
    final idx = _selectedCalculators.indexOf(currentKey);
    if (idx < 0 || idx >= _selectedCalculators.length - 1) return null;
    return _selectedCalculators[idx + 1];
  }

  /// Is [key] the last selected calculator?
  bool isLastCalculator(String key) {
    return _selectedCalculators.isNotEmpty &&
        _selectedCalculators.last == key;
  }

  /// Is [key] selected?
  bool isCalculatorSelected(String key) => _selectedCalculators.contains(key);

  /// How many calculators are selected?
  int get totalSelectedCalcs => _selectedCalculators.length;

  /// Index (1-based) of [key] in the selected list.
  int calcIndex(String key) => _selectedCalculators.indexOf(key) + 1;

  // ── Cost Calculations ───────────────────────────────────────────────────────

  double calculateFlooringCost(ProjectModel project, RatesModel rates) {
    final rateMap = rates.flooringMaterials;
    final rate = rateMap[project.selectedFlooringMaterial] ?? rates.flooringTiles;
    final areaWithWastage =
        project.roomArea * (1 + project.flooringWastage / 100);
    return areaWithWastage * rate;
  }

  double calculatePaintCost(ProjectModel project, RatesModel rates) {
    final totalWallArea =
        2 * (project.roomLength + project.roomWidth) * project.paintWallHeight;
    const doorsWindowsArea = 60.0;
    final netPaintable = totalWallArea - doorsWindowsArea;
    final litersNeeded =
        (netPaintable / project.paintCoverage) * project.paintCoats;
    return litersNeeded * rates.paintPricePerLiter;
  }

  double calculateTilesCost(ProjectModel project, RatesModel rates) {
    final areaWithWastage =
        project.roomArea * (1 + project.tilesWastage / 100);
    return areaWithWastage * project.tilePrice;
  }

  double calculateCeilingCost(ProjectModel project, RatesModel rates) =>
      project.roomArea * project.ceilingRatePerSqFt;

  double calculateDoorsWindowsCost(ProjectModel project, RatesModel rates) {
    double cost = 0;
    cost += project.mainDoors * (rates.doorPrices['Main Door'] ?? rates.mainDoorPrice);
    cost += project.roomDoors * (rates.doorPrices['Room Doors'] ?? rates.roomDoorPrice);
    cost += project.bathroomDoors * (rates.doorPrices['Bathroom Doors'] ?? rates.bathroomDoorPrice);
    cost += project.windows * (rates.windowPrices['Windows'] ?? rates.windowPrice);
    cost += project.ventilators * (rates.windowPrices['Ventilators'] ?? rates.ventilatorPrice);
    return cost;
  }

  double calculateFurnitureCost(ProjectModel project, RatesModel rates) {
    double cost = 0;
    project.furnitureItems.forEach((item, qty) {
      cost += (rates.furniturePrices[item] ?? 0) * qty;
    });
    return cost;
  }

  void recalculateAll(RatesModel rates) {
    if (_currentProject == null) return;
    _currentProject!.flooringCost = calculateFlooringCost(_currentProject!, rates);
    _currentProject!.paintCost = calculatePaintCost(_currentProject!, rates);
    _currentProject!.tilesCost = calculateTilesCost(_currentProject!, rates);
    _currentProject!.ceilingCost = calculateCeilingCost(_currentProject!, rates);
    _currentProject!.doorsWindowsCost =
        calculateDoorsWindowsCost(_currentProject!, rates);
    _currentProject!.furnitureCost = calculateFurnitureCost(_currentProject!, rates);
    notifyListeners();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  ProjectModel _copyWithCalculators(
      ProjectModel p, List<String> selectedCalculators) {
    return ProjectModel(
      id: p.id,
      name: p.name,
      city: p.city,
      propertyType: p.propertyType,
      projectArea: p.projectArea,
      description: p.description,
      selectedRoom: p.selectedRoom,
      roomLength: p.roomLength,
      roomWidth: p.roomWidth,
      roomHeight: p.roomHeight,
      unit: p.unit,
      createdAt: p.createdAt,
      flooringCost: p.flooringCost,
      paintCost: p.paintCost,
      tilesCost: p.tilesCost,
      ceilingCost: p.ceilingCost,
      doorsWindowsCost: p.doorsWindowsCost,
      furnitureCost: p.furnitureCost,
      electricalCost: p.electricalCost,
      plumbingCost: p.plumbingCost,
      selectedFlooringMaterial: p.selectedFlooringMaterial,
      flooringWastage: p.flooringWastage,
      paintWallHeight: p.paintWallHeight,
      paintType: p.paintType,
      paintCoats: p.paintCoats,
      paintCoverage: p.paintCoverage,
      tilesType: p.tilesType,
      tileSize: p.tileSize,
      tilesWastage: p.tilesWastage,
      tilePrice: p.tilePrice,
      ceilingType: p.ceilingType,
      ceilingRatePerSqFt: p.ceilingRatePerSqFt,
      mainDoors: p.mainDoors,
      roomDoors: p.roomDoors,
      bathroomDoors: p.bathroomDoors,
      windows: p.windows,
      ventilators: p.ventilators,
      furnitureItems: Map.from(p.furnitureItems),
      selectedCalculators: selectedCalculators,
    );
  }
}
