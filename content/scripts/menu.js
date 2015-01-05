var section = 'none';
export default function() {
    var menu = $('#js-responsive-navigation-menu');
    var menuToggle = $('.responsive-navigation-menu-button');
    var wrapper = $('.responsive-navigation-wrapper');

    menu.removeClass("show");

    $(menuToggle).on('click', function(e) {
        e.preventDefault();
        var current = wrapper.attr('data-section');
        if (current !== 'open') {
            wrapper.attr('data-section', 'open');
            section = current;
        } else {
                wrapper.attr('data-section', section);
        }
        menu.slideToggle(function(){
            if(menu.is(':hidden')) {
                menu.removeAttr('style');
            }
        });
    });
}
