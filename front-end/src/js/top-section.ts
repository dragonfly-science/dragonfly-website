import animateScrollTo from 'animated-scroll-to'

const TopSection = (): void => {
  $('a[href="#top-section"]').click((e) => {
    e.preventDefault()

    const headerH = $('.main-header').height()
    const sectionOffset = $('#top-section').offset().top

    animateScrollTo(sectionOffset - headerH)
  })

  // tslint:disable-next-line: only-arrow-functions
  $('a[href="#contact"]').click(function (e: Event) {
    e.preventDefault()
    window.keepScroll = false
    location.hash = 'contact-dragonfly'
  })
}

export default TopSection
