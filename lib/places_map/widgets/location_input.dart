import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:vunh_places_map/places_map/models/place.dart';

import '../helpers/location_helper.dart';
import '../screens/map_screen.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;

  LocationInput(this.onSelectPlace);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;
  GoogleMapController _mapController;
  Uint8List _imageBytesUin8list;
  PlaceLocation _initialLocation = const PlaceLocation(latitude: 10.6933819, longitude: 106.7065317);
  LatLng _pickedLocation, _initialPosition ;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locData = await Location().getLocation();
      setState(() {
        _initialPosition = LatLng(locData.latitude, locData.longitude);
      });
    } catch (error) {
      return;
    }
  }

  void _selectLocation(LatLng position) {
    widget.onSelectPlace(position.latitude, position.longitude);
    setState(() {
      _pickedLocation = position;
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_pickedLocation.latitude, _pickedLocation.longitude), 16));
    });
  }

  void _showPreview(double lat, double lng) {
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
      latitude: lat,
      longitude: lng,
    );
    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _getCurrentUserLocation() async {
    try {
      final locData = await Location().getLocation();
      setState(() {
        _initialPosition = LatLng(locData.latitude, locData.longitude);
      });
    } catch (error) {
      return;
    }
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
              isSelecting: true,
            ),
      ),
    );
    if (selectedLocation == null) {
      return;
    }
    // _showPreview(selectedLocation.latitude, selectedLocation.longitude); //load image google map
    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
    setState(() {
      _pickedLocation = selectedLocation;
      _mapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_pickedLocation.latitude, _pickedLocation.longitude), 16));
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              color: Colors.grey[300],
              icon: Icon(
                Icons.location_on,
              ),
              label: Text('Current Location'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _getCurrentUserLocation,
            ),
            SizedBox(
              width: 10,
            ),
            FlatButton.icon(
              color: Colors.grey[300],
              icon: Icon(
                Icons.map,
              ),
              label: Text('Select on Map'),
              textColor: Theme.of(context).primaryColor,
              onPressed: _selectOnMap,
            ),
          ],
        ),
        Expanded(
          child: Container(
            // height: 170,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: _initialPosition == null
                ? Container(child: Center(child:Text('loading map..', style: TextStyle(fontFamily: 'Avenir-Medium', color: Colors.grey[400]),),),)
                : GoogleMap(
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 16,
              ),
              onTap: _selectLocation,
              markers: (_pickedLocation == null)
                  ? null
                  : {
                Marker(
                  markerId: MarkerId('m1'),
                  position: _pickedLocation ??
                      LatLng(
                        _initialLocation.latitude,
                        _initialLocation.longitude,
                      ),
                ),
              },
            ),
          ),
        ),
      ],
    );
  }
}
