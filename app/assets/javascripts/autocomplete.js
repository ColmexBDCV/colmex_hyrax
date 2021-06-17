

var options = {

  url: function(phrase) {
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


var autofill = '[name*="creator]"], [name*="contributor]"]'

$(document).on('turbolinks:load',function(){
  
  load_autofill()
  $(".easy-autocomplete").removeAttr( 'style' );
    
  
  $(".multi_value .btn.add").click(function () { 
    element = $(this)
    setTimeout(
      function() 
      {
        let id_input = element.parent().children("ul").children("li:last-child").children("div").children("input").attr("id")
        element.parent().children("ul").children("li:last-child").children("div").children("input").attr("id",id_input+0)

        let id_div = element.parent().children("ul").children("li:last-child").children("div").children("div").attr("id")
        element.parent().children("ul").children("li:last-child").children("div").children("div").attr("id",id_div+0)
        load_autofill()
       
      }, 500);
    
  });
});


function load_autofill(){
  $(autofill).easyAutocomplete(options);  
}