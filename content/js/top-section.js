import animateScrollTo from 'animated-scroll-to'

const TopSection = ($) => {
    $('a[href="#top-section"]').click(function(e) {
        e.preventDefault()

        let headerH = $('.main-header').height()
        let sectionOffset = $('#top-section').offset().top

        animateScrollTo(sectionOffset - headerH)
    })
}

export default TopSection
