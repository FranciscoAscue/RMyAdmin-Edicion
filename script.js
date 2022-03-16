function get_id(clicked_id) {
     Shiny.setInputValue("current_id", clicked_id, {priority: "event"});
}
$(document).keyup(function(event) {if ($("#ncorrida").is(":focus") && (event.key == "Enter")) { $("#Buscar").click();}});
$(document).keyup(function(event) {if ($("#minR").is(":focus") && (event.key == "Enter")) { $("#Buscar").click();}});
$(document).keyup(function(event) {if ($("#maxR").is(":focus") && (event.key == "Enter")) { $("#Buscar").click();}});