import menuInit from './menu';
/* global $ */

function tagFilter(){
    function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    };
    
    var tags = getParameterByName('tag').split(',');
    $('.tag').show().each(function(i, elem){
        tags.forEach(function(t){
            if (!(t === "") & (!$(elem).hasClass('tag-' + t ))){
                $(elem).hide();
            }
            console.log(t);
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
     
    tagFilter();
    
});


