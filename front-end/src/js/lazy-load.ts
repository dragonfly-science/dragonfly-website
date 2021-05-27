import lozad from 'lozad'

// const getClosest = (elem: Element, selector: string): HTMLElement => {
//   for (; elem && elem !== document; elem = elem.parentNode) {
//     elem.ge
//     // if (elem.class.matches(selector)) {
//     //   return elem
//     // }
//   }
//   return null
// }

const LazyLoad = (): void => {
  const options = {
    rootMargin: '1000px 0px',
    threshold: 0,
    loaded(el: HTMLElement): void {
      setTimeout(() => {
        el.classList.add('loaded')
        const parent = el.closest('.lozad-container')
        if (parent) {
          parent.classList.add('loaded')
        }

      }, 200)
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
