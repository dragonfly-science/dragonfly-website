import { isNull } from 'lodash-es'
import ScrollMagic from 'scrollmagic'

const StickySidebar = () => {
    const sidebar = $('#sticky-sidebar')
    const body = $('#body-content')
    const header = $('#main-header')

    if (isNull(sidebar) || isNull(body)) {
        return
    }

    const controller = new ScrollMagic.Controller()
    const mt = {
        body: parseInt(body.css('margin-top'), 10),
        header: parseInt(header.css('margin-top'), 10),
    }
    const offset = 0 - (mt.body + mt.header)
    const side = {
        h: sidebar.height(),
        mt: parseInt(sidebar.css('margin-top'), 10),
    }
    const duration = body.height() - side.mt - side.h

    console.log(offset, duration)

    const scene = new ScrollMagic.Scene(
                    {
                        triggerElement: '#body-content',
                        triggerHook: 'onLeave',
                        offset,
                        duration,
                    })
                    .setPin('#sticky-sidebar')
                    .addTo(controller)
}

export default StickySidebar
