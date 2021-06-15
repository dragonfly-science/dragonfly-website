import lozad from 'lozad'
import ScrollMagic from 'scrollmagic'

const intializeStickySidebar = (
  triggerElement: string,
  pinnedElement: string
): void => {
  const sidebar = $(pinnedElement)
  const body = $(triggerElement)
  const header = $('#main-header')
  const container = $('.sticky-container')

  if (sidebar.length === 0 || body.length === 0) {
    return
  }

  const controller = new ScrollMagic.Controller()
  const duration =
    body.height() - sidebar.height() - parseInt(sidebar.css('margin-top'), 10)

  new ScrollMagic.Scene({
    triggerElement,
    triggerHook: 'onLeave',
    offset: 0 - header.height() - parseInt(container.css('padding-top'), 10),
    duration: Math.abs(duration ?? 300),
  })
    .setPin(pinnedElement)
    .addTo(controller)
}

const initTimeout = (triggerElement: string, pinnedElement: string): void => {
  setTimeout(intializeStickySidebar, 500, triggerElement, pinnedElement)
}

const StickySidebar = (triggerElement: string, pinnedElement: string): void => {
  const imgTarget = '.sticky-lozad'

  if ($(imgTarget).length === 0) {
    initTimeout(triggerElement, pinnedElement)
    return
  }

  const observer = lozad(imgTarget, {
    rootMargin: '1000px 0px',
    threshold: 0.5,
    loaded(el) {
      el.classList.add('loaded', 'lozad')
      initTimeout(triggerElement, pinnedElement)
    },
  })

  observer.observe()
}

export default StickySidebar
