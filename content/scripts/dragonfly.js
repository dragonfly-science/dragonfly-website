import menuInit from './menu';
/* global $ */

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
});

