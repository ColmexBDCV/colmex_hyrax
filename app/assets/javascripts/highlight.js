
var HighLight = function() {
  
  const queryString = window.location.search;
  
  const urlParams = new URLSearchParams(queryString);

  const entries = urlParams.entries();

  const entries_ = urlParams.entries();

  const stopwords = [
    "a",
    "ahi",
    "ahora",
    "al",
    "algo",
    "algunas",
    "algunos",
    "ante",
    "antes",
    "asi",
    "aun",
    "cada",
    "como",
    "con",
    "contra",
    "cual",
    "cuando",
    "da",
    "de",
    "deben",
    "debe",
    "debemos",
    "del",
    "desde",
    "deber",
    "donde",
    "durante",
    "e",
    "el",
    "ella",
    "ellas",
    "ello",
    "ellos",
    "en",
    "entre",
    "era",
    "erais",
    "eramos",
    "eran",
    "eras",
    "eres",
    "es",
    "esa",
    "esas",
    "ese",
    "eso",
    "esos",
    "esta",
    "esta",
    "estaba",
    "estabais",
    "estabamos",
    "estaban",
    "estabas",
    "estad",
    "estada",
    "estadas",
    "estais",
    "estamos",
    "estan",
    "estando",
    "estar",
    "estara",
    "estaran",
    "estaras",
    "estare",
    "estareis",
    "estaremos",
    "estaria",
    "estariais",
    "estariamos",
    "estarian",
    "estarias",
    "estas",
    "estas",
    "este",
    "este",
    "este",
    "esteis",
    "estemos",
    "esten",
    "estes",
    "esto",
    "estos",
    "estoy",
    "estuve",
    "estuviera",
    "estuvierais",
    "estuvieramos",
    "estuvieran",
    "estuvieras",
    "estuvieron",
    "estuviese",
    "estuvieseis",
    "estuviesemos",
    "estuviesen",
    "estuvieses",
    "estuvimos",
    "estuviste",
    "estuvisteis",
    "estuvo",
    "fin",
    "fue",
    "fuera",
    "fuerais",
    "fueramos",
    "fueran",
    "fueras",
    "fueron",
    "fuese",
    "fueseis",
    "fuesemos",
    "fuesen",
    "fueses",
    "fui",
    "fuimos",
    "fuiste",
    "fuisteis",
    "ha",
    "habeis",
    "habia",
    "habiais",
    "habiamos",
    "habian",
    "habias",
    "habida",
    "habidas",
    "habido",
    "habidos",
    "habiendo",
    "habra",
    "habran",
    "habras",
    "habre",
    "habreis",
    "habremos",
    "habria",
    "habriais",
    "habriamos",
    "habrian",
    "habrias",
    "hacer",
    "hacia",
    "hago",
    "haces",
    "han",
    "has",
    "hasta",
    "hay",
    "haya",
    "hayais",
    "hayamos",
    "hayan",
    "hayas",
    "he",
    "hemos",
    "hoy",
    "hube",
    "hubiera",
    "hubierais",
    "hubieramos",
    "hubieran",
    "hubieras",
    "hubieron",
    "hubiese",
    "hubieseis",
    "hubiesemos",
    "hubiesen",
    "hubieses",
    "hubimos",
    "hubiste",
    "hubisteis",
    "hubo",
    "la",
    "las",
    "le",
    "les",
    "lo",
    "los",
    "mas",
    "me",
    "mi",
    "mi",
    "mia",
    "mias",
    "mio",
    "mios",
    "mis",
    "mucho",
    "muchos",
    "muy",
    "nada",
    "ni",
    "no",
    "nos",
    "nosotras",
    "nosotros",
    "nuestra",
    "nuestras",
    "nuestro",
    "nuestros",
    "o",
    "os",
    "otra",
    "otras",
    "otro",
    "otros",
    "para",
    "pero",
    "poco",
    "por",
    "porque",
    "pues",
    "que",
    "que",
    "quien",
    "quienes",
    "se",
    "sea",
    "seais",
    "seamos",
    "sean",
    "seas",
    "sera",
    "seran",
    "seras",
    "sere",
    "sereis",
    "seremos",
    "seria",
    "seriais",
    "seriamos",
    "serian",
    "serias",
    "si",
    "si",
    "sido",
    "siendo",
    "sin",
    "sino",
    "sobre",
    "sois",
    "solo",
    "somos",
    "son",
    "soy",
    "su",
    "sus",
    "suya",
    "suyas",
    "suyo",
    "suyos",
    "tal",
    "tambien",
    "tan",
    "tanto",
    "te",
    "tendra",
    "tendran",
    "tendras",
    "tendre",
    "tendreis",
    "tendremos",
    "tendria",
    "tendriais",
    "tendriamos",
    "tendrian",
    "tendrias",
    "tened",
    "teneis",
    "tenemos",
    "tenga",
    "tengais",
    "tengamos",
    "tengan",
    "tengas",
    "tengo",
    "tenia",
    "teniais",
    "teniamos",
    "tenian",
    "tenias",
    "tenida",
    "tenidas",
    "tenido",
    "tenidos",
    "teniendo",
    "ti",
    "tiene",
    "tienen",
    "tienes",
    "toda",
    "todas",
    "todo",
    "todos",
    "traves",
    "tu",
    "tu",
    "tus",
    "tuve",
    "tuviera",
    "tuvierais",
    "tuvieramos",
    "tuvieran",
    "tuvieras",
    "tuvieron",
    "tuviese",
    "tuvieseis",
    "tuviesemos",
    "tuviesen",
    "tuvieses",
    "tuvimos",
    "tuviste",
    "tuvisteis",
    "tuvo",
    "tuya",
    "tuyas",
    "tuyo",
    "tuyos",
    "un",
    "una",
    "uno",
    "unos",
    "vez",
    "via",
    "vosotras",
    "vosotros",
    "vuestra",
    "vuestras",
    "vuestro",
    "vuestros",
    "y",
    "ya",
    "yo", 
    
  ]

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
  range_dates = []
  for(const e of entries_) {
    if(e[0].includes("begin")){
      range_dates.push(e[1])
    }
    if(e[0].includes("end")){
      range_dates.push(e[1])
    }
  }

  highlight_years = false

  if(range_dates.length > 1){
    highlight_years = numberRange(parseInt(range_dates[0]), parseInt(range_dates[1]))
    
    $('span[itemprop="dateCreated"] a').each(function(){
      $(this).html("<mark>"+$(this).html()+"</mark>")
    })
  }



  for(const entry of entries) {    
    if((entry[0].includes("_sim") || parameters.includes(entry[0])) && entry[1] != "") {
      if(entry[0].includes("begin")){
        continue
      }
      if(entry[0].includes("end")){
        continue
      }
      $("#search-results a, #search-results dd, .work-type .panel-heading h2, .work-type dd a, .work-type dd li").each(function(){
        value = entry[1].split('"').join("")

        if ( $(this).children().length < 1 ) {
          
          if (parameters.includes(entry[0])){
            
            for(const ent of value.split(" ")) {
              txt = $(this).html()
              txt = set_highlight(txt, value)
              $(this).html(txt)
           
            }
          }else{
            
            txt = $(this).html()
            txt = set_highlight(txt, value)
            $(this).html(txt)
            
          }
        }
      });  
    }
  }
  
  // function set_highlight(txt, value){
  //   txt_mod= txt.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-zA-Z0-9 \-]/g, "").split(" ")
  //   txt = txt.split(" ")
  //   val = value.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/[^a-zA-Z0-9 \-]/g, "").split(" ")
  //   for (index = 0; index < txt.length; index++) { 
  //       if(isInArray(txt_mod[index], val) && !isInArray(txt_mod[index], stopwords) && txt_mod[index] != "" ) {
           
  //         txt[index] = "<mark>"+txt[index]+"</mark>"
  //       }
        
  //   }
   
  //   return txt.join(" ")

    

  // }

  function set_highlight(txt, value){
    let regex = new RegExp(`\\b(${value})\\b`, "gi"); 
    return txt.replace(regex, '<mark>$1</mark>');
  }

  function numberRange (start, end) {
    return new Array((end + 1) - start).fill().map((d, i) => i + start);
  }
    
  function isInArray(value, array) {
    return array.indexOf(value) > -1;
  } 

  $(".search-result-title > a").each(function () {
    var oldUrl = $(this).attr("href").split("?"); // Get current url
    var newUrl = oldUrl[0]+queryString; // Create new url
    $(this).attr("href", newUrl); // Set herf value
  });
}