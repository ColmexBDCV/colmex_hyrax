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

// String.prototype.replaceAt=function(index, char) {return this.substr(0, index) + char + this.substr(index+char.length);}


var appReady = function() {
  
  const queryString = window.location.search;
  
  const urlParams = new URLSearchParams(queryString);

  const entries = urlParams.entries();

  const parameters = [
    "all_fields",
    "title",
    "creator",
    "contributor",
    "description",
    "publisher",
    "date_created",
    "subject_work",
    "subject_person",
    "subject_corporate",
    "subject_family",
    "subject",
    "geographic_coverage",
    "temporary_coverage",
    "director",
    "degree_program",
    "q"    
  ]

  for(const entry of entries) {
    if((entry[0].includes("_sim") || parameters.includes(entry[0])) && entry[1] != "") {
      
      $("#search-results a, #search-results dd, .work-type .panel-heading h2, .work-type dd a, .work-type dd li").each(function(){
        value = entry[1].split('"').join("")
        if ( $(this).children().length < 1 ) {
          
          if (parameters.includes(entry[0])){
            for(const ent of value.split(" ")) {
              txt = $(this).html()
              word_position = indexes(txt.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, ""),ent.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, ""))
              if (word_position.length > 0)
              {
                var word = txt.substring(word_position[0], word_position[0]+ ent.length)
                
                $(this).html(txt.split(word).join("<mark>"+word+"</mark>"))
              }
            }
          }else{
            txt = $(this).html()
            word_position = indexes(txt.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, ""),value.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, ""))
            if (word_position.length > 0)
            {
              var word = txt.substring(word_position[0], word_position[0]+ value.length)
              
              $(this).html(txt.split(word).join("<mark>"+word+"</mark>"))
            }
          }

        }
      });  
    }
  }
    
    
  function indexes(source, find) {
    if (!source) {
      return [];
    }
    if (!find) {
        return source.split('').map(function(_, i) { return i; });
    }
    var result = [];
    var i = 0;
    while(i < source.length) {
      if (source.substring(i, i + find.length) == find) {
        result.push(i);
        i += find.length;
      } else {
        i++;
      }
    }
    return result;
  }

    

  $(".search-result-title > a").each(function () {
    var oldUrl = $(this).attr("href").split("?"); // Get current url
    var newUrl = oldUrl[0]+queryString; // Create new url
    $(this).attr("href", newUrl); // Set herf value
  });
}


$(document).on('turbolinks:load', appReady);