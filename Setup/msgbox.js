var wsh = WScript.CreateObject("WScript.Shell");
var objArgs = WScript.Arguments;
var result = -1;

result = wsh.popup(objArgs(1),0,objArgs(0),objArgs(2));
//WScript.Echo(result);
WScript.Quit(result);
