import animateScrollTo from 'animated-scroll-to'

const TopSection = ($: ZeptoStatic) => {
    $('a[href="#top-section"]').click((e) => {
        e.preventDefault()

        const headerH = $('.main-header').height()
        const sectionOffset = $('#top-section').offset().top

        animateScrollTo(sectionOffset - headerH)
    })
}

export default TopSection
