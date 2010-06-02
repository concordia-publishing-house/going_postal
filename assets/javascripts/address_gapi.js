var displayDebug = true; //TODO: turn off for production!

function debug(msg) {
 if(!displayDebug){ return }
 if(window.console){ window.console.log(msg) }
 // else { alert(msg) }
}

var geocoder;
var map;
function map_initialize() {
 geocoder = new google.maps.Geocoder();
 var latlng = new google.maps.LatLng(-34.397, 150.644); // IF not address for the person, it starts here.
 var myOptions = {
 center: latlng,
 mapTypeId: google.maps.MapTypeId.ROADMAP,
 zoom: 16,
 disableDefaultUI: true,
 keyboardShortcuts: false,
 disableDoubleClickZoom: true,
 navigationControl: false,
 scaleControl: false,
 scrollwheel: true,
 draggable: false
 }
 map_perm = new google.maps.Map(document.getElementById("map_perm_address"), myOptions);
 codeAddress('address',map_perm); //householdPermanentAddress
 map_mail = new google.maps.Map(document.getElementById("map_mail_address"), myOptions);
 codeAddress('mailing_address',map_mail);
// map_away = new google.maps.Map(document.getElementById("map_away_address"), myOptions);
// codeAddress('away_address',map_away);
}

function codeAddress(addressSource, mapName) {
 var address = buildAddress(addressSource);
 debug("addressSource: " + addressSource );

 if (geocoder) {
 debug("--->geocoder starts.");
 geocoder.geocode( {
 'address': address
 }, function(results, status) {
 debug("--->geocode function");
 if (status == google.maps.GeocoderStatus.OK) {
 debug("--->GeocoderStatus OK");
 mapName.setCenter(results[0].geometry.location);
 var marker = new google.maps.Marker({
 map: mapName,
 title: 'Home Address',
 //shape: (coords=[60,50,10,15], type='rect'),
 position: results[0].geometry.location
 });
 debug("--->marker done");
 debug("--->marker results:" + results[0]);
 } else {
 alert("Geocode was not successful for the following reason: " + status);
 }
 });
 }
}

function buildAddress(addressName) {
 if(addressName) {
 addr = addressName;
 } else {
 addr = "unk";
 }
// form_field_name = address + '[' + addr_fields[i] + ']';
// document.getElementsByName(form_field_name)[0].value + ", "
// debug(addr+"[street]");

// var addr_str = document.getElementsByName(addr+"[street]")[0].value + ", "
// + document.getElementsByName(addr+"[city]")[0].value + ", "
// + document.getElementsByName(addr+"[state]")[0].value + ", "
// + document.getElementsByName(addr+"[zip]")[0].value ;

 var addr_str = document.getElementsByName("address[street]")[0].value + ", "
 + document.getElementsByName("address[city]")[0].value + ", "
 + document.getElementsByName("address[state]")[0].value + ", "
 + document.getElementsByName("address[zip]")[0].value ;
// debug(addr_str);
 return addr_str;
}

/*
The types[] array within the returned result indicates the address type. These types may also be returned within address_components[] arrays to indicate the type of the particular address component. Addresses within the geocoder may have multiple types; the types may be considered "tags". For example, many cities are tagged with the political and locality type.
The following types are supported and returned by the HTTP Geocoder:
street_address indicates a precise street address.
political indicates a political entity. Usually, this type indicates a polygon of some civil administration.
country indicates the national political entity, and is typically the highest order type returned by the Geocoder.
administrative_area_level_1 indicates a first-order civil entity below the country level. Within the United States, these administrative levels are states. Not all nations exhibit these administrative levels.
administrative_area_level_2 indicates a second-order civil entity below the country level. Within the United States, these administrative levels are counties. Not all nations exhibit these administrative levels.
administrative_area_level_3 indicates a third-order civil entity below the country level. This type indicates a minor civil division. Not all nations exhibit these administrative levels.
colloquial_area indicates a commonly-used alternative name for the entity.
locality indicates an incorporated city or town political entity.
sublocality indicates an first-order civil entity below a locality
neighborhood indicates a named neighborhood
premise indicates a named location, usually a building or collection of buildings with a common name
subpremise indicates a first-order entity below a named location, usually a singular building within a collection of buildings with a common name
postal_code indicates a postal code as used to address postal mail within the country.
natural_feature indicates a prominent natural feature.
airport indicates an airport.
park indicates a named park.
In addition to the above, address components may exhibit the following types:
post_box indicates a specific postal box.
street_number indicates the precise street number.
floor indicates the floor of a building address.
room indicates the room of a building address.
 */
