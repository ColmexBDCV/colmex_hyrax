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
//= require jquery3
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
jQuery.noConflict();


$(document).on('turbolinks:load', HighLight);
$(document).on('turbolinks:load', TableView);
$(document).on('turbolinks:load', function(){

    $('h4.search-result-title > a').each(function(){
        if($(this).attr("href").includes("/collections/")) {
            console.log($(this).attr("href"))
            $(this).attr("href", "/catalog?f%5Bmember_of_collections_ssim%5D%5B%5D="+$(this).text())
        }
        
      }); 


});
