import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/data_models.dart';

class Apex extends StatefulWidget {
  const Apex({super.key});

  @override
  State<Apex> createState() => _ApexState();
}

class _ApexState extends State<Apex> {
  List<Location> locations = [];
  List<Asset> assets = [];
  bool isLoading = true;
  Map<int, bool> expansionState = {};
  Map<int, bool> expansionStateAsset = {};
  Map<int, bool> expansionStateTile = {};
  bool isSensorActive = false;
  bool isCriticalActive = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse('https://fake-api.tractian.com/companies'));
    if (response.statusCode == 200) {
      final companies = json.decode(response.body) as List;
      print(companies);
      final companyId = companies[2]['id'];
      try {
        final locationsResponse = await http.get(Uri.parse(
            'https://fake-api.tractian.com/companies/$companyId/locations'));
        final assetsResponse = await http.get(Uri.parse(
            'https://fake-api.tractian.com/companies/$companyId/assets'));

        if (locationsResponse.statusCode == 200) {
          final locationsData = json.decode(locationsResponse.body) as List;
          locations = locationsData.map((loc) => Location.fromJson(loc)).toList();
        }

        if (assetsResponse.statusCode == 200) {
          final assetsData = json.decode(assetsResponse.body) as List;
          assets = assetsData.map((asset) => Asset.fromJson(asset)).toList();
        }
      } catch (error) {
        print("Error fetching data: $error");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool shouldShowAsset(Asset asset) {
    if (isSensorActive && asset.sensorType != "energy") {
      return false;
    } if (isCriticalActive && asset.status == "operating") {
      return false;
    }
    if (searchQuery.isNotEmpty) {
      if (asset.name.toLowerCase().contains(searchQuery.toLowerCase())) {
        return true;
      }
      final subAssets = assets.where((subAsset) => subAsset.parentId == asset.id).toList();
      return subAssets.any((subAsset) => shouldShowAsset(subAsset));
    }
    return true;
  }

  bool shouldShowLocation(Location location) {
    final associatedAssets = assets.where((asset) => asset.locationId == location.id).toList();
    final subLocations = locations.where((loc) => loc.parentId == location.id).toList();
    if (isSensorActive || isCriticalActive || searchQuery.isNotEmpty) {
      bool showAssets = associatedAssets.any((asset) => shouldShowAsset(asset));
      bool showSubLocations = subLocations.any((subLocation) => shouldShowLocation(subLocation));
      return showAssets || showSubLocations || location.name.toLowerCase().contains(searchQuery.toLowerCase());
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0XFF17192D),
        title: Text(
          "Assets",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ?
      Center(
          child: CircularProgressIndicator()
      )
          :
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: "Buscar Ativo ou Local",
                hintMaxLines: 1,
                hintStyle: TextStyle(color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[300],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: FilterButton(
                  icon: Icons.bolt,
                  isActive: isSensorActive,
                  onTap: () {
                    setState(() {
                      isSensorActive = !isSensorActive;
                    });
                  },
                  label: "Sensor de Energia",
                ),
              ),
              SizedBox(width: 8),
              FilterButton(
                icon: Icons.warning,
                isActive: isCriticalActive,
                onTap: () {
                  setState(() {
                    isCriticalActive = !isCriticalActive;
                  });
                },
                label: "Crítico",
              ),
            ],
          ),
          Expanded(
            child: buildLocationTree(),
          ),
        ],
      ),
    );
  }

  Widget buildLocationTree() {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ListView.builder(
        itemCount: locations.where((location) => location.parentId == null).length,
        itemBuilder: (context, index) {
          final location = locations.where((location) => location.parentId == null).elementAt(index);
          return buildLocationNode(location);
        }
      ),
    );
  }

  Widget buildLocationNode(Location location) {
    final subLocations = locations.where((loc) => loc.parentId == location.id).toList();
    final associatedAssets = assets.where((asset) => asset.locationId == location.id).toList();
    final locationChildren = [
      ...associatedAssets.where((asset) => shouldShowAsset(asset)).map((asset) => buildAssetNode(asset)).toList(),
      ...subLocations.map((subLocation) => buildLocationNode(subLocation)).toList(),
    ];

    return expansionLocation(
        locationTitle: location.name,
        context, locationChildren.isNotEmpty ? locationChildren : [ListTile(title: Text("No items to display"))],
        depth: 1,
        index: location.id.hashCode
    );
  }

  Widget buildAssetNode(Asset asset) {
    final subAssets = assets.where((subAsset) => subAsset.parentId == asset.id).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: expansionTileAsset(
          context,
          asset.name + (asset.sensorType != null ? " [Component - ${asset.sensorType}]" : ""),
          asset,
          subAssets.where((subAsset) => shouldShowAsset(subAsset)).map((subAsset) => buildAssetNode(subAsset)).toList(),
          depth: 1,
          index: asset.id.hashCode
      ),
    );
  }

  Widget expansionLocation(BuildContext context,
      List<Widget> children,
      {required int depth, required int index, bool isLocation = true, required String locationTitle}) {
    bool isExpanded = expansionStateTile[index] ?? false;

    return ExpansionTile(
      key: PageStorageKey<int>(index),
      title: Text(locationTitle),
      onExpansionChanged: (bool expanded) {
        setState(() {
          expansionStateTile[index] = expanded;
        });
      },
      trailing: SizedBox.shrink(),
      children: children,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Icon(Icons.keyboard_arrow_down)),
          SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            child: isLocation
                ? Image.asset("assets/location.png")
                : Image.asset("assets/asset.png"),
          ),
        ],
      ),
    );
  }

  Widget expansionTileAsset(BuildContext context, String title, Asset tileAsset,
      List<Widget> children, {required int depth, required int index}) {
    bool isExpanded = expansionStateAsset[index] ?? false;
    return ExpansionTile(
      key: PageStorageKey<int>(index),
      title: Text(title),
      onExpansionChanged: (bool expanded) {
        setState(() {
          expansionStateAsset[index] = expanded;
        });
      },
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tileAsset.sensorType == "energy")
            Padding(
              padding: const EdgeInsets.only(right: 60.0),
              child: Icon(Icons.bolt, color: tileAsset.status == "operating" ? Colors.green : Colors.red),
            )
          else if (tileAsset.sensorType == "vibration")
            Padding(
              padding: const EdgeInsets.only(right: 60.0),
              child: Icon(Icons.circle, color: tileAsset.status == "operating" ? Colors.green : Colors.red),
            )
        ],
      ),
      children: children,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tileAsset.sensorType != null ? SizedBox(height: 0) : AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: Duration(milliseconds: 200),
              child: Icon(Icons.keyboard_arrow_down)),
          SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            child: tileAsset.sensorType != null ? Image.asset("assets/component.png") : Image.asset("assets/asset.png"),
          ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const FilterButton({required this.icon, required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.grey),
            SizedBox(width: 4.0),
            Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
