import lozad from 'lozad'

const LazyLoad = () => {
    const observer = lozad({
        rootMargin: '300px 0px', // syntax similar to that of CSS Margin
        threshold: 0.1 // ratio of element convergence
    });
    observer.observe();

    // Lazy-load images in body copy.
    const images = document.querySelectorAll('.body-content img');
    const bodyObserver = lozad(images, {
        rootMargin: '300px 0px', // syntax similar to that of CSS Margin
        threshold: 0.1 // ratio of element convergence
    });
    bodyObserver.observe();
}

export default LazyLoad
