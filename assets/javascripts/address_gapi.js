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
//var latlng = new google.maps.LatLng(-43.53262,172.63504); // IF no address in form, it starts here (City: Christchurch, Country: New Zealand).
var latlng = new google.maps.LatLng(0,0); // IF no address in form, it starts here (mid-ocean blue).
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
  draggable: false
}

function map_initialize() {
  geocoder = new google.maps.Geocoder();
  map_perm = new google.maps.Map(document.getElementById("map_perm_address"), myOptions);
  codeAddress('address',map_perm,true); // Permanent Address
  map_mail = new google.maps.Map(document.getElementById("map_mail_address"), myOptions);
  codeAddress('mailing_address',map_mail,true);
  map_away = new google.maps.Map(document.getElementById("map_away_address"), myOptions);
  codeAddress('away_address',map_away,true);
}

function codeAddress(addressSource, mapName, init) {
  if(!init) {init=false;}
  var address = concatAddress(addressSource);
  debug("addressSource: " + addressSource );
  if(!init) { var check = checkAddress(address); }

  if (geocoder) {
    geocoder.geocode( {
      'address': address
    }, function(results, status) {
      debug("---->geocode function starts for: " +addressSource);              //debug
      if (status == google.maps.GeocoderStatus.OK) {
        debug("-->GeocoderStatus OK");
        mapName.setCenter(results[0].geometry.location);
        var marker = new google.maps.Marker({
          map: mapName,
          title: 'Click to open map of this address.',
          //shape: (coords=[60,50,10,15], type='rect'),
          position: results[0].geometry.location,
          icon: '/javascripts/going_postal/home_icon_small.png',
          clickable: true
        });
        debug("-->marker results:");                      //debug
        debug(results);                                   //debug
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
    debug("---->checkAddress function starts");              //debug
    if (status == google.maps.GeocoderStatus.OK) {
      debug("-->GeocoderStatus OK");
      if (results.length>1) {
        //alert("We found more than one address with your '"+ addressSource +"', please be more specific.");
        debug("-->checkAddress found multiples:");
        debug(results);
        return 2; //multiple
      }
    } else {
      //alert("We had trouble finding your '"+ addressSource +"'.");
      return 0; //error
    }
  })
  return 1; //success
}

function concatAddress(addressName) {
  if(addressName) {
    addr = addressName;
  } else {
    addr = "unk";
    debug("Address source 'unknown' in concatenate address function.");
  }
  var addr_str = document.getElementsByName(addr+"[street]")[0].value + ", "
    + document.getElementsByName(addr+"[city]")[0].value + ", "
    + document.getElementsByName(addr+"[state]")[0].value + ", "
    + document.getElementsByName(addr+"[zip]")[0].value ;
  debug(addr_str);
  return addr_str;
}

