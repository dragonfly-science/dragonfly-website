import lozad from 'lozad'

const LazyLoad = () => {
    const options = {
        rootMargin: '1000px 0px',
        threshold: 0,
        loaded(el: HTMLElement) {
            el.classList.add('loaded')

            // remove transition delay on the item so that
            // mouse interactions work as expected.
            setTimeout(() => {
                el.style.transitionDelay = '0ms'

                // If this is a header, transition the text colour to white.
                const parent = el.parentElement

                if (parent.classList.contains('page-header--image-bg')) {
                    parent.classList.add('page-header--white')
                }
            }, 600)
        },
    }
    const observer = lozad('.lozad', options)
    observer.observe()

    // Lazy-load images in body copy.
    const images = document.querySelectorAll('.body-content img')
    const bodyObserver = lozad(images, options)
    bodyObserver.observe()
}

export default LazyLoad
