/******************************************
 *    Base functions for use in code      *
 ******************************************/

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

