import $ from 'zepto'

const MobileMenu = () => {
    $('.mobile-menu').on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
  
        let wrapper = $('.main-nav')
  
        wrapper.toggleClass('open')
  
        if (wrapper.is('.open')) {
            $(this).addClass('dragonfly-close')
                .removeClass('dragonfly-hamburger')
        } else {
            $(this).addClass('dragonfly-hamburger')
                .removeClass('dragonfly-close')
        }
    })
}

export default MobileMenu
