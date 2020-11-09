

var options = {

  url: function(phrase) {
    console.log(phrase)
    return "/persona_name?person="+phrase;
    // return "/client/persona_name";

  },
  requestDelay: 250,
  highlightPhrase: false,
  list: {
    maxNumberOfElements: 10,
   
   },

  // theme: "square"
};


$(document).on('turbolinks:load',function(){

  load_autofill();

  $(".multi_value .btn.add").click(function (){ 
    console.log("add field")
    setTimeout(
      function() 
      {
        load_autofill()
      }, 5000);
     
  });

});

function load_autofill(){
  console.log("load EAC");
  $('[name*="creator]"], [name*="contributor]"]').easyAutocomplete(options);

  $('.easy-autocomplete').removeAttr('style');
}
