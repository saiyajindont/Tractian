class Location {
  final String id;
  final String name;
  final String? parentId;

  Location({required this.id, required this.name, this.parentId});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
    );
  }
}

class Asset {
  final String id;
  final String name;
  final String? parentId;
  final String? locationId;
  final String? sensorId;
  final String? sensorType;
  final String? status;
  final String? gatewayId;

  Asset({
  required this.id,
  required this.name,
  this.parentId,
  this.locationId,
  this.sensorId,
  this.sensorType,
  this.status,
  this.gatewayId,
});

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      parentId: json['parentId'],
      locationId: json['locationId'],
      sensorId: json['sensorId'],
      sensorType: json['sensorType'],
      status: json['status'],
      gatewayId: json['gatewayId'],
    );
  }
}

List<Location> locations = [
  Location(id: "65674204664c41001e91ecb4", name: "PRODUCTION AREA - RAW MATERIAL"),
  Location(id: "656a07b3f2d4a1001e2144bf", name: "CHARCOAL STORAGE SECTOR", parentId: "65674204664c41001e91ecb4"),
];

List<Asset> assets = [
  Asset(id: "656734821f4664001f296973", name: "Fan - External", sensorId: "MTC052", sensorType: "energy", status: "operating", gatewayId: "QHI640"),
  Asset(id: "656a07bbf2d4a1001e2144c2", name: "CONVEYOR BELT ASSEMBLY", locationId: "656a07b3f2d4a1001e2144bf"),
  Asset(id: "656a07c3f2d4a1001e2144c5", name: "MOTOR TC01 COAL UNLOADING AF02", parentId: "656a07bbf2d4a1001e2144c2"),
  Asset(id: "656a07cdc50ec9001e84167b", name: "MOTOR RT COAL AF01", parentId: "656a07c3f2d4a1001e2144c5", sensorId: "FIJ309", sensorType: "vibration", status: "operating", gatewayId: "FRH546"),
];
