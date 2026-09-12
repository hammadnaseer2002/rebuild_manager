/// Holds all configurable market rates for the app.
/// Default values mirror the original hardcoded constants so the app
/// works correctly even before the user completes the first-time setup.
class RatesModel {
  // ── Flooring (Rs per sq ft) ─────────────────────────────────────────────
  double flooringTiles;
  double flooringMarble;
  double flooringVinyl;
  double flooringWooden;
  double flooringGranite;

  // ── Paint ───────────────────────────────────────────────────────────────
  double paintPricePerLiter; // Rs per litre

  // ── Tiles (default tile price per sq ft) ───────────────────────────────
  double defaultTilePrice;

  // ── Ceiling (Rs per sq ft) ─────────────────────────────────────────────
  double ceilingPlain;
  double ceilingGypsum;
  double ceilingPVC;
  double ceilingWooden;

  // ── Doors (Rs per unit) ────────────────────────────────────────────────
  double mainDoorPrice;
  double roomDoorPrice;
  double bathroomDoorPrice;

  // ── Windows (Rs per unit) ──────────────────────────────────────────────
  double windowPrice;
  double ventilatorPrice;

  // ── Furniture (Rs per unit) ────────────────────────────────────────────
  double sofaSetPrice;
  double tvUnitPrice;
  double coffeeTablePrice;
  double curtainsPrice;
  double lightsPrice;
  double diningTablePrice;
  double bedPrice;
  double wardrobePrice;

  // ── Electrical (Rs per unit) ───────────────────────────────────────────
  double electricalPointRate;   // light/switch board
  double fanRate;               // ceiling/exhaust fan
  double acPointRate;           // AC point
  double socketRate;            // power socket
  double electricalLightRate;   // light fixture

  // ── Plumbing (Rs per unit) ─────────────────────────────────────────────
  double washroomRate;          // full plumbing per washroom
  double kitchenPlumbingRate;   // sink + pipe connections
  double waterTankRate;         // water tank installation
  double motorPumpRate;         // motor/pump
  double extraFixtureRate;      // extra fixtures

  RatesModel({
    // Flooring
    this.flooringTiles    = 220,
    this.flooringMarble   = 450,
    this.flooringVinyl    = 180,
    this.flooringWooden   = 550,
    this.flooringGranite  = 600,
    // Paint
    this.paintPricePerLiter = 800,
    // Tiles
    this.defaultTilePrice = 150,
    // Ceiling
    this.ceilingPlain   = 200,
    this.ceilingGypsum  = 350,
    this.ceilingPVC     = 280,
    this.ceilingWooden  = 500,
    // Doors
    this.mainDoorPrice      = 25000,
    this.roomDoorPrice      = 15000,
    this.bathroomDoorPrice  = 12000,
    // Windows
    this.windowPrice      = 9500,
    this.ventilatorPrice  = 3000,
    // Furniture
    this.sofaSetPrice     = 45000,
    this.tvUnitPrice      = 25000,
    this.coffeeTablePrice = 12000,
    this.curtainsPrice    = 5000,
    this.lightsPrice      = 2000,
    this.diningTablePrice = 35000,
    this.bedPrice         = 40000,
    this.wardrobePrice    = 30000,
    // Electrical
    this.electricalPointRate  = 3500,
    this.fanRate              = 4000,
    this.acPointRate          = 6000,
    this.socketRate           = 2500,
    this.electricalLightRate  = 2000,
    // Plumbing
    this.washroomRate         = 45000,
    this.kitchenPlumbingRate  = 25000,
    this.waterTankRate        = 15000,
    this.motorPumpRate        = 20000,
    this.extraFixtureRate     = 5000,
  });

  /// Creates a RatesModel with all rates set to 0
  factory RatesModel.zero() {
    return RatesModel(
      flooringTiles: 0,
      flooringMarble: 0,
      flooringVinyl: 0,
      flooringWooden: 0,
      flooringGranite: 0,
      paintPricePerLiter: 0,
      defaultTilePrice: 0,
      ceilingPlain: 0,
      ceilingGypsum: 0,
      ceilingPVC: 0,
      ceilingWooden: 0,
      mainDoorPrice: 0,
      roomDoorPrice: 0,
      bathroomDoorPrice: 0,
      windowPrice: 0,
      ventilatorPrice: 0,
      sofaSetPrice: 0,
      tvUnitPrice: 0,
      coffeeTablePrice: 0,
      curtainsPrice: 0,
      lightsPrice: 0,
      diningTablePrice: 0,
      bedPrice: 0,
      wardrobePrice: 0,
      electricalPointRate: 0,
      fanRate: 0,
      acPointRate: 0,
      socketRate: 0,
      electricalLightRate: 0,
      washroomRate: 0,
      kitchenPlumbingRate: 0,
      waterTankRate: 0,
      motorPumpRate: 0,
      extraFixtureRate: 0,
    );
  }

  // ── Convenience getters matching the old const-map keys ─────────────────

  /// Map used by Flooring calculator cards.
  Map<String, double> get flooringMaterials => {
    'Tiles':   flooringTiles,
    'Marble':  flooringMarble,
    'Vinyl':   flooringVinyl,
    'Wooden':  flooringWooden,
    'Granite': flooringGranite,
  };

  /// Map used by Ceiling calculator cards.
  Map<String, double> get ceilingTypes => {
    'Plain':                  ceilingPlain,
    'False Ceiling (Gypsum)': ceilingGypsum,
    'False Ceiling (PVC)':    ceilingPVC,
    'Wooden':                 ceilingWooden,
  };

  /// Map used by Doors & Windows calculator.
  Map<String, double> get doorPrices => {
    'Main Door':      mainDoorPrice,
    'Room Doors':     roomDoorPrice,
    'Bathroom Doors': bathroomDoorPrice,
  };

  Map<String, double> get windowPrices => {
    'Windows':    windowPrice,
    'Ventilators': ventilatorPrice,
  };

  /// Map used by Furniture calculator.
  Map<String, double> get furniturePrices => {
    'Sofa Set':     sofaSetPrice,
    'TV Unit':      tvUnitPrice,
    'Coffee Table': coffeeTablePrice,
    'Curtains':     curtainsPrice,
    'Lights':       lightsPrice,
    'Dining Table': diningTablePrice,
    'Bed':          bedPrice,
    'Wardrobe':     wardrobePrice,
  };

  // ── SharedPreferences serialization ─────────────────────────────────────

  Map<String, double> toPrefsMap() => {
    'flooring_tiles':       flooringTiles,
    'flooring_marble':      flooringMarble,
    'flooring_vinyl':       flooringVinyl,
    'flooring_wooden':      flooringWooden,
    'flooring_granite':     flooringGranite,
    'paint_per_liter':      paintPricePerLiter,
    'default_tile_price':   defaultTilePrice,
    'ceiling_plain':        ceilingPlain,
    'ceiling_gypsum':       ceilingGypsum,
    'ceiling_pvc':          ceilingPVC,
    'ceiling_wooden':       ceilingWooden,
    'main_door':            mainDoorPrice,
    'room_door':            roomDoorPrice,
    'bathroom_door':        bathroomDoorPrice,
    'window':               windowPrice,
    'ventilator':           ventilatorPrice,
    'sofa_set':             sofaSetPrice,
    'tv_unit':              tvUnitPrice,
    'coffee_table':         coffeeTablePrice,
    'curtains':             curtainsPrice,
    'lights':               lightsPrice,
    'dining_table':         diningTablePrice,
    'bed':                  bedPrice,
    'wardrobe':             wardrobePrice,
    'elec_point':           electricalPointRate,
    'elec_fan':             fanRate,
    'elec_ac_point':        acPointRate,
    'elec_socket':          socketRate,
    'elec_light':           electricalLightRate,
    'plumb_washroom':       washroomRate,
    'plumb_kitchen':        kitchenPlumbingRate,
    'plumb_tank':           waterTankRate,
    'plumb_motor':          motorPumpRate,
    'plumb_fixture':        extraFixtureRate,
  };

  factory RatesModel.fromPrefsMap(Map<String, double> m) {
    double g(String k, double def) => m[k] ?? def;
    return RatesModel(
      flooringTiles:         g('flooring_tiles',     220),
      flooringMarble:        g('flooring_marble',    450),
      flooringVinyl:         g('flooring_vinyl',     180),
      flooringWooden:        g('flooring_wooden',    550),
      flooringGranite:       g('flooring_granite',   600),
      paintPricePerLiter:    g('paint_per_liter',    800),
      defaultTilePrice:      g('default_tile_price', 150),
      ceilingPlain:          g('ceiling_plain',      200),
      ceilingGypsum:         g('ceiling_gypsum',     350),
      ceilingPVC:            g('ceiling_pvc',        280),
      ceilingWooden:         g('ceiling_wooden',     500),
      mainDoorPrice:         g('main_door',          25000),
      roomDoorPrice:         g('room_door',          15000),
      bathroomDoorPrice:     g('bathroom_door',      12000),
      windowPrice:           g('window',             9500),
      ventilatorPrice:       g('ventilator',         3000),
      sofaSetPrice:          g('sofa_set',           45000),
      tvUnitPrice:           g('tv_unit',            25000),
      coffeeTablePrice:      g('coffee_table',       12000),
      curtainsPrice:         g('curtains',           5000),
      lightsPrice:           g('lights',             2000),
      diningTablePrice:      g('dining_table',       35000),
      bedPrice:              g('bed',                40000),
      wardrobePrice:         g('wardrobe',           30000),
      electricalPointRate:   g('elec_point',         3500),
      fanRate:               g('elec_fan',           4000),
      acPointRate:           g('elec_ac_point',      6000),
      socketRate:            g('elec_socket',        2500),
      electricalLightRate:   g('elec_light',         2000),
      washroomRate:          g('plumb_washroom',     45000),
      kitchenPlumbingRate:   g('plumb_kitchen',      25000),
      waterTankRate:         g('plumb_tank',         15000),
      motorPumpRate:         g('plumb_motor',        20000),
      extraFixtureRate:      g('plumb_fixture',      5000),
    );
  }

  /// Returns a copy with modified fields.
  RatesModel copyWith({
    double? flooringTiles, double? flooringMarble, double? flooringVinyl,
    double? flooringWooden, double? flooringGranite,
    double? paintPricePerLiter, double? defaultTilePrice,
    double? ceilingPlain, double? ceilingGypsum, double? ceilingPVC, double? ceilingWooden,
    double? mainDoorPrice, double? roomDoorPrice, double? bathroomDoorPrice,
    double? windowPrice, double? ventilatorPrice,
    double? sofaSetPrice, double? tvUnitPrice, double? coffeeTablePrice,
    double? curtainsPrice, double? lightsPrice, double? diningTablePrice,
    double? bedPrice, double? wardrobePrice,
    double? electricalPointRate, double? fanRate, double? acPointRate,
    double? socketRate, double? electricalLightRate,
    double? washroomRate, double? kitchenPlumbingRate, double? waterTankRate,
    double? motorPumpRate, double? extraFixtureRate,
  }) {
    return RatesModel(
      flooringTiles:        flooringTiles        ?? this.flooringTiles,
      flooringMarble:       flooringMarble       ?? this.flooringMarble,
      flooringVinyl:        flooringVinyl        ?? this.flooringVinyl,
      flooringWooden:       flooringWooden       ?? this.flooringWooden,
      flooringGranite:      flooringGranite      ?? this.flooringGranite,
      paintPricePerLiter:   paintPricePerLiter   ?? this.paintPricePerLiter,
      defaultTilePrice:     defaultTilePrice     ?? this.defaultTilePrice,
      ceilingPlain:         ceilingPlain         ?? this.ceilingPlain,
      ceilingGypsum:        ceilingGypsum        ?? this.ceilingGypsum,
      ceilingPVC:           ceilingPVC           ?? this.ceilingPVC,
      ceilingWooden:        ceilingWooden        ?? this.ceilingWooden,
      mainDoorPrice:        mainDoorPrice        ?? this.mainDoorPrice,
      roomDoorPrice:        roomDoorPrice        ?? this.roomDoorPrice,
      bathroomDoorPrice:    bathroomDoorPrice    ?? this.bathroomDoorPrice,
      windowPrice:          windowPrice          ?? this.windowPrice,
      ventilatorPrice:      ventilatorPrice      ?? this.ventilatorPrice,
      sofaSetPrice:         sofaSetPrice         ?? this.sofaSetPrice,
      tvUnitPrice:          tvUnitPrice          ?? this.tvUnitPrice,
      coffeeTablePrice:     coffeeTablePrice     ?? this.coffeeTablePrice,
      curtainsPrice:        curtainsPrice        ?? this.curtainsPrice,
      lightsPrice:          lightsPrice          ?? this.lightsPrice,
      diningTablePrice:     diningTablePrice     ?? this.diningTablePrice,
      bedPrice:             bedPrice             ?? this.bedPrice,
      wardrobePrice:        wardrobePrice        ?? this.wardrobePrice,
      electricalPointRate:  electricalPointRate  ?? this.electricalPointRate,
      fanRate:              fanRate              ?? this.fanRate,
      acPointRate:          acPointRate          ?? this.acPointRate,
      socketRate:           socketRate           ?? this.socketRate,
      electricalLightRate:  electricalLightRate  ?? this.electricalLightRate,
      washroomRate:         washroomRate         ?? this.washroomRate,
      kitchenPlumbingRate:  kitchenPlumbingRate  ?? this.kitchenPlumbingRate,
      waterTankRate:        waterTankRate        ?? this.waterTankRate,
      motorPumpRate:        motorPumpRate        ?? this.motorPumpRate,
      extraFixtureRate:     extraFixtureRate     ?? this.extraFixtureRate,
    );
  }
}
