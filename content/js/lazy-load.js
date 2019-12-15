import lozad from 'lozad'

const LazyLoad = () => {
    const observer = lozad();
    observer.observe();

    // Lazy-load images in body copy.
    const images = document.querySelectorAll('.body-content img');
    const bodyObserver = lozad(images);
    bodyObserver.observe();
}

export default LazyLoad
