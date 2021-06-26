import lozad from 'lozad'
import ScrollMagic from 'scrollmagic'

const MAX_WIDTH = 1024
const MAX_DURATION = 300

const getDuration = (body: any, sidebar: any) => () => {
  const marginTop = $(sidebar).css('margin-top')

  const duration = Math.abs(
    body.height() -
      $(sidebar).height() -
      parseInt(marginTop === 'auto' ? 0 : marginTop, 10)
  )

  return duration
}

const enableScene =
  (controller: any, scenes: any[], pinnedElement: any, triggerElement: any) =>
  () => {
    if (window.innerWidth < MAX_WIDTH) {
      for (let scene of scenes) {
        if (scene.scene !== null) {
          scene.scene.destroy(true)
          scene.scene = null
        }
      }
      scenes = []

      if (controller !== null) {
        controller.destroy(true)
        controller = null
      }

      return
    }

    if (controller && scenes.length !== 0) {
      for (let scene of scenes) {
        scene.scene.enabled($(scene.sidebar).css('display') !== 'none')
        // console.log(
        //   $(scene.sidebar),
        //   $(scene.sidebar).css('display') !== 'none'
        // )
        scene.scene.refresh()
        // scene.scene.update(true)
      }

      controller.update(true)

      window.scroll()

      return
    }

    const sidebars = $(pinnedElement)
    const body = $(triggerElement)
    const header = $('#main-header')
    const container = $('.sticky-container')

    controller = new ScrollMagic.Controller()

    sidebars.forEach((sidebar: any) => {
      scenes.push({
        sidebar,
        scene: new ScrollMagic.Scene({
          triggerElement,
          triggerHook: 'onLeave',
          offset:
            0 - header.height() - parseInt(container.css('padding-top'), 10),
          duration: getDuration(body, sidebar),
        })
          .setPin(sidebar)
          .addTo(controller),
      })
    })
  }

const intializeStickySidebar = (
  triggerElement: string,
  pinnedElement: string
): void => {
  const sidebar = $(pinnedElement)
  const body = $(triggerElement)

  if (sidebar.length === 0 || body.length === 0) {
    return
  }

  let controller: any = null
  let scenes: any[] = []
  const sticky = enableScene(controller, scenes, pinnedElement, triggerElement)

  window.addEventListener('resize', sticky)

  sticky()
}

const initTimeout = (triggerElement: string, pinnedElement: string): void => {
  // setTimeout(intializeStickySidebar, 500, triggerElement, pinnedElement)
  intializeStickySidebar(triggerElement, pinnedElement)
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
