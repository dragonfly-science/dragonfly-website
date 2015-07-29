import menuInit from './menu';
/* global $ */


function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

function tagFilter(tags){    
    $('.tag').show().each(function(i, elem){
        tags.split(',').forEach(function(t){
            if (!(t === "") & (!$(elem).hasClass('tag-' + t ))){
                $(elem).hide();
                console.log(t);
            }
        });
    });
}

$(document).ready(function() {
    menuInit();
    var options = {
        valueNames: ['citation']
    };
    var publicationList = new List('publication-list', options);

    publicationList.on('updated', function(){
        if (publicationList.searched) {
            $('#publication-count').show();
            var n = publicationList.visibleItems.length;
            if (n == 0){
                $('#publication-count').text('Oops! There are no matching publications');
            } else if (n == 1){
                $('#publication-count').text('One matching publication');
            } else {
                $('#publication-count').text(n + ' matching publications');
            }
        } else {
            $('#publication-count').hide();
        }
    });
     
    tagFilter(getParameterByName('tag'));
    
    //Dropdown menus
    $(".dropdown-button").click(function() {
        console.log('Dropdown clicked')
        var $button, $menu;
        $button = $(this);
        $menu = $button.siblings(".dropdown-menu");
        $menu.toggleClass("show-menu");
        $menu.children("li").click(function() {
            $menu.removeClass("show-menu");
            $button.html($(this).html());
            if ($(this)[0].hasAttribute("data-tag")) {
                $button.attr("data-tag", $(this)[0].getAttribute("data-tag"));
            }
            var t = []; 
            $(".dropdown-button").each(function(){
                t.push($(this).attr("data-tag"));
            });
            tagFilter(t.toString());
        });
    });
    $(document).mouseup(function (e){
        $(".dropdown-menu").each(function() {
            if (!$(this).is(e.target)  // if the target of the click isn't the container...
                    && $(this).has(e.target).length === 0) { // ... nor a descendant of the container
                $(this).removeClass("show-menu");
            }
        });
    });
});




