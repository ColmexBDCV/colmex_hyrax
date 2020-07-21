// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= 
//= require turbolinks
//
// Required by Blacklight
//= require jquery
//= require 'blacklight_advanced_search'


//= require jquery_ujs
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require blacklight/blacklight

//= require_tree .
//= require hyrax



// For blacklight_range_limit built-in JS, if you don't want it you don't need
// this:
//= require 'blacklight_range_limit'

var appReady = function() {
  
  var queryString = window.location.search;
  
  var urlParams = new URLSearchParams(queryString);

  var entries = urlParams.entries();

  
  
  for(var entry of entries) {
    if(entry[0].includes("_sim") || entry[0].includes("_tesim") || entry[0] == "q") {
      console.log("chale")
      $("#search-results a, #search-results dd, .work-type h2, .work-type dd a").each(function(){
        //console.log($(this).prop("tagName"))
        
        if ( $(this).children().length < 1 ) {
          console.log($(this).html())
          txt = $(this).text()
          for(var ent of entry[1].split(" ")) {
            $(this).html(txt.split(ent).join("<mark>"+ent+"</mark>"))
          }
        }
      });  
    }
  }
    
 

  $(".search-result-title > a").each(function () {
    var oldUrl = $(this).attr("href").split("?"); // Get current url
    var newUrl = oldUrl[0]+queryString; // Create new url
    $(this).attr("href", newUrl); // Set herf value
  });
}
  $(document).on('turbolinks:load', appReady);