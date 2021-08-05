const MobileMenu = (): void => {
  $('.mobile-menu').on('click', function (this: HTMLElement, e): void {
    e.preventDefault()
    e.stopPropagation()

    const wrapper = $('.main-nav')

    wrapper.toggleClass('open')

    if (wrapper.is('.open')) {
      $(this).addClass('dragonfly-close transform rotate-45').removeClass('dragonfly-hamburger')
    } else {
      $(this).addClass('dragonfly-hamburger').removeClass('dragonfly-close transform rotate-45')
    }
  })
}

export default MobileMenu
