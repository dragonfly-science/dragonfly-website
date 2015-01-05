var section = 'none';
export default function() {
    var menuToggle = $('.responsive-navigation-menu-button');
    var wrapper = document.getElementById('js-responsive-navigation-menu');

    $(menuToggle).on('click', function(e) {
        e.preventDefault();
        if(wrapper.dataset.mode  === 'open') {
            wrapper.dataset.mode = 'closed';
        } else {
            wrapper.dataset.mode = 'open';
        }
    });
}
