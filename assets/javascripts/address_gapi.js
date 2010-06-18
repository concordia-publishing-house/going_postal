/******************************************
 *    Base functions for use in code      *
 ******************************************/

var displayDebug = true; //TODO: turn off for production!
function debug(msg) {
  if(!displayDebug){return}
  if(window.console){window.console.log(msg)}
  //else { alert(msg) }
}

//dumpProps uses 'debug' method
function dumpProps(obj, parent) {
  // Go through all the properties of the passed-in object
  for (var i in obj) {
    // if a parent (2nd parameter) was passed in, then use that to
    // build the message. Message includes i (the object's property name)
    // then the object's property value on a new line
    if (parent) {var msg = parent + "." + i + "\n" + obj[i];} else {var msg = i + "\n" + obj[i];}
    // Display the message. If the user clicks "OK", then continue. If they
    // click "CANCEL" then quit this level of recursion
    if (!debug(msg)) {return;}
    // If this property (i) is an object, then recursively process the object
    if (typeof obj[i] == "object") {
      if (parent) {dumpProps(obj[i], parent + "." + i);} else {dumpProps(obj[i], i);}
    }
  }
}


/******************************************
 *                                        *
 *   Map API using Google Maps Geocoder   *
 *                                        *
 ******************************************/
var geocoder;
var map;
var latlng = new google.maps.LatLng(-43.53262,172.63504); // IF no address in form, it starts here (City: Christchurch, Country: New Zealand).
// var latlng = new google.maps.LatLng(0,0); // IF no address in form, it starts here (mid-ocean blue).
var myOptions = {
  center: latlng,
  mapTypeId: google.maps.MapTypeId.ROADMAP,
  zoom: 15,
  disableDefaultUI: true,
  keyboardShortcuts: false,
  disableDoubleClickZoom: true,
  navigationControl: false,
  scaleControl: false,
  scrollwheel: false,
  draggable: true 
}

function map_initialize(mapTypeID) {
  if (mapTypeID) { 
    geocoder = new google.maps.Geocoder(); 
    switch(mapTypeID) {
      case 'map_perm':
        map_perm = new google.maps.Map(document.getElementById(mapTypeID+'_address'), myOptions);
        break;
      case 'map_mail':
        map_mail = new google.maps.Map(document.getElementById(mapTypeID+'_address'), myOptions);
        break;
      case 'map_away':
        map_away = new google.maps.Map(document.getElementById(mapTypeID+'_address'), myOptions);
        break;
    }
  } else {
    debug("!No mapTypeID passed as argument to map_initialize!")
  }
}

function mapAddress(addressSource, mapName, init) {
  if(!init) {init=false;}
  addressSource ? address = concatAddress(addressSource) : address = 'unknown';
  debug("mapAddressSource: " + addressSource );
  if(!init) { var check = checkAddress(address); }

  if (geocoder) {
    geocoder.geocode( {
      'address': address
    }, function(results, status) {
      debug("---->geocode function starts for: " +addressSource);              //debug
      if (status == google.maps.GeocoderStatus.OK) {
        debug("-->Geocode Status OK");
        mapName.setCenter(results[0].geometry.location);
        var marker = new google.maps.Marker({
          map: mapName,
          title: 'Click to open map of this address.',
           //shape: (coords=[60,50,10,15], type='rect'),
          position: results[0].geometry.location,
          icon: '/javascripts/going_postal/home_icon_small.png',
          clickable: true
        });
      } else {
        debug("Geocode was not successful with "+ addressSource +" for the following status reason: " + status); //TODO: remove from debug, send message to end user.
        //        alert("Geocode was not successful with "+ addressSource +" for the following status reason: " + status);
      }
    });
  }
}

function checkAddress(addressSource) {
  // ToDo: function to check if address is verifiable or if multiple are found
  geocoder.geocode( {
    'address': addressSource
  }, function(results, status) {
    debug("---->checkAddress function starts: "+addressSource);              //debug
    if (status == google.maps.GeocoderStatus.OK) {
      debug("-->GeocoderStatus OK");
      if (results.length > 1) {
        alert("We found more than one address with your '"+ addressSource +"', please be more specific.");
        debug("-->checkAddress found multiple addresses:");
        debug(results);
        return 2; //multiple
      }
    } else if (results.length = 1) {  
        debug("-->success, one address found");                      //debug
        return 1; //success, one address found
    } else  {
        debug("-->status not ok, no address found");                      //debug
      //alert("We had trouble finding your '"+ addressSource +"'.");
      return 0; //error
    }
  })
  return 1; //success, one address found
}

function concatAddress(addressName) {
  if(addressName) {
    var addr_str = document.getElementsByName(addressName+"[street]")[0].value + ", "
                 + document.getElementsByName(addressName+"[city]")[0].value + ", "
                 + document.getElementsByName(addressName+"[state]")[0].value + ", "
                 + document.getElementsByName(addressName+"[zip]")[0].value ;
    debug(addr_str);
  } else {
    addr_str("Address source 'unknown' in concatenate address function.");
  }
  return addr_str;
}

