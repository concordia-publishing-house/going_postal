var thescript = document.createElement('script');
thescript.setAttribute('type','text/javascript');
// next line is key for http://church360/
thescript.setAttribute('src','http://www.google.com/jsapi?key=ABQIAAAAFoEXS--8wPfX9yI9GB60ShQeBv3IGvTxncIXpB1V8FeP03rNVRSYWyb5H8fjMEltOdjPbK3Sg1SUmw');
// next line is key for http://church360.org
//thescript.setAttribute('src','http://www.google.com/jsapi?key=ABQIAAAAFoEXS--8wPfX9yI9GB60ShS2nENSybmWYSq8MgbOY85MooMpuxR8FxOEoV2RSocK3ennyxlKiIdZUQ');
document.getElementsByTagName('head')[0].appendChild(thescript);


/*    This uses Google Maps API    */
google.load("maps", "2"); // load the v.2 of maps api

var map;
var geocoder;

function initialize() {
  map = new GMap2(document.getElementById("map_canvas"));
  // map.setCenter(new GLatLng(34, 0), 10);
  geocoder = new GClientGeocoder();
}

// addAddressToMap() is called when the geocoder returns an
// answer.  It adds a marker to the map with an open info window
// showing the nicely formatted version of the address and the country code.
function showAddress(address) {
  if (geocoder) {
    geocoder.getLatLng(
      address,
      function(point) {
        if (!point) {
          alert(address + " not found");
        } else {
          map.setCenter(point, 13);
          var marker = new GMarker(point);
          map.addOverlay(marker);
          marker.openInfoWindowHtml(address);
        }
      }
      );
  }
}

function addAddressToMap(response) {
  map.clearOverlays();
  if (!response || response.Status.code != 200) {
    alert("Sorry, we were unable to geocode that address");
  } else {
    place = response.Placemark[0];
    point = new GLatLng(place.Point.coordinates[1],
      place.Point.coordinates[0]);
    marker = new GMarker(point);
    map.addOverlay(marker);
    marker.openInfoWindowHtml(place.address + '<br>' +
      '<b>Country code:</b> ' + place.AddressDetails.Country.CountryNameCode);
  }
}

// showLocation() is called when you click on the Search button
// in the form.  It geocodes the address entered into the form
// and adds a marker to the map at that location.
function showLocation() {
  var address = document.forms[0].q.value;
  geocoder.getLocations(address, addAddressToMap);
}

// findLocation() is used to enter the sample addresses into the form.
function findLocation(address) {
  document.forms[0].q.value = address;
  showLocation();
}

