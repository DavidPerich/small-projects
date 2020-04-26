function selectAll(id, isSelected) {

  //alert("id="+id+" selected? "+isSelected);
  var selectObj=document.getElementById(id);
  //alert("obj="+selectObj.type);
  var options=selectObj.options;
  //alert("option length="+options.length);
  for(var i=0; i<options.length; i++) {
     options[i].selected=isSelected;
  }
 }

 function goBack() {
   window.history.back()
 }