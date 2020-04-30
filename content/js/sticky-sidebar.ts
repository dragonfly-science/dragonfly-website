import { isNull } from 'lodash-es'
import lozad from 'lozad'
import ScrollMagic from 'scrollmagic'

const intializeStickySidebar = (triggerElement: string, pinnedElement: string): void => {
    const sidebar = $(pinnedElement)
    const body = $(triggerElement)
    const header = $('#main-header')

    if (isNull(sidebar) || isNull(body)) {
        return
    }

    const controller = new ScrollMagic.Controller()
    const duration = body.height() - sidebar.height() -
                     parseInt(sidebar.css('margin-top'), 10)

    const scene = new ScrollMagic.Scene(
                    {
                        triggerElement,
                        triggerHook: 'onLeave',
                        offset: 0 - (header.height()),
                        duration,
                    })
                    .setPin(pinnedElement)
                    .addTo(controller)
}

const StickySidebar = (triggerElement: string, pinnedElement: string): void => {
    const imgTarget = '.sticky-lozad'
    if (isNull($(imgTarget))) {
        return
    }

    const observer = lozad(imgTarget, {
        loaded(el) {
            el.classList.add('loaded')
            el.classList.add('lozad')
            setTimeout(intializeStickySidebar, 500, triggerElement, pinnedElement)
        },
    })

    observer.observe()
}

export default StickySidebar
