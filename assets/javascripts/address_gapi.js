// date: 2010-06-18
// author: Jamin Leopold

/******************************************
 *    Base functions for use in code      *
 ******************************************/

// function importJS(path){ 
//   var script = document.createElement('script');
//   script.type = 'text/javascript'; 
//   script.src = path;
//   document.getElementsByTagName('head')[0].appendChild(script); 
// 
//   // var i, base, src = "grid.js", scripts = document.getElementsByTagName("script"); 
//   // for (i=0; i<scripts.length; i++){if (scripts[i].src.match(src)){ base = scripts[i].src.replace(src, "");break;}}
//   // document.write("<" + "script src=\"" + base + path + "\"></" + "script>"); 
// } 

var displayDebug = true; //TODO: turn off for production!
function debug(msg) {
  if(!displayDebug){return}
  if(window.console){window.console.log(msg)}
  //else { alert(msg) }
}

//displayProps uses 'debug' method
function displayProps(obj) {
  var str ="Object properties:\n";
  for(prop in obj) {
    str+=prop + " value :"+ obj[prop]+"\n";//Concatenate prop and its value from object
    }
  debug(str);
}


/******************************************
 *                                        *
 *   Map API using Google Maps Geocoder   *
 *                                        *
 ******************************************/

 // Load google maps api with key here at start!
 // importJS('http://maps.google.com/maps/api/js?sensor=false&key=ABQIAAAASklC1xi8fElpu98ovSmxkBS2nENSybmWYSq8MgbOY85MooMpuxSuV-mV3BvfBWM7ag5kx1HB9CSPiQ'); //for church360.org
 // importJS('http://maps.google.com/maps/api/js?sensor=false&key=ABQIAAAAnfs7bKE82qgb3Zc2YyS-oBT2yXp_ZAY8_ufC3CFXhHIE1NvwkxSySz_REpPq-4WZA27OwgbtyR3VcA'); //for localhost

var geocoder;
var map;
var latlng = new google.maps.LatLng(-43.53262,172.63504); // IF no address in form, it starts here (City: Christchurch, Country: New Zealand).
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
  draggable: true 
}

function map_initialize(mapTypeID) {
  if (mapTypeID) { 
    geocoder = new google.maps.Geocoder(); 
    // mapTypeID = new google.maps.Map(document.getElementById(mapTypeID+'_address'), myOptions); //Create map object using a variable's contents as name of object gives "not defined"
    switch(mapTypeID) {
      case 'map_perm': map_perm = new google.maps.Map(document.getElementById(mapTypeID+'_address'), myOptions); 
                       mapAddress('address',map_perm,true); break;
      case 'map_mail': map_mail = new google.maps.Map(document.getElementById(mapTypeID+'_address'), myOptions); 
                       mapAddress('mail_address',map_mail,true); break;
      case 'map_away': map_away = new google.maps.Map(document.getElementById(mapTypeID+'_address'), myOptions); 
                       mapAddress('away_address',map_away,true); break;
    }
  } else {
    debug("!No map ID passed as argument to map_initialize!")
  }
}

function mapAddress(addressSource, mapName, init) {
  addressSource ? address = concatAddress(addressSource) : address = 'unknown';
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
          position: mapName.center,
          icon: '/javascripts/going_postal/home_icon_small.png',
          clickable: true
        });
        var infowindow = infoAddress(mapName);
        google.maps.event.addListener(marker, 'click', function() {
          infowindow.open(mapName,marker);
        });
      } else {
        debug("Geocode was not successful with "+ addressSource +" for the following status reason: " + status); 
        //displayProps(mapName.c.id);
        document.getElementById(mapName.c.id).style.display="none";
      }
    });
  }
}

function infoAddress(mapName) {
  var infoVar = new google.maps.InfoWindow({ 
    content: "<a href='http://maps.google.com/maps?q="+mapName.center+"' target='_blank'>Click to open large<br/>map of this address.</a>",
    position: mapName.center,
    maxWidth: 50,
    size: new google.maps.Size(50,50)
  });
  return infoVar;
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
        alert("We found more than one address with your '"+ addressSource +"', please be more specific.");  // this doesn't ever run...
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

