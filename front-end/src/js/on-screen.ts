import OnScreen from 'onscreen'
import Swiper from 'swiper/bundle'

const viewportActivation = (swiper?: Swiper): void => {
  const [ video, testimonials ] = [
    document.getElementsByClassName('video'),
    document.getElementsByClassName('testimonials')
  ]

  const os = new OnScreen({
    tolerance: 200,
    debounce: 100,
    container: window
  })

  setupVideo(video, os, '.video')
  setupTestimonials(testimonials, os, '.testimonials', swiper)
}

const setupVideo = (elements: HTMLCollection, os: any, selector: string): void => {
  if (elements.length !== 0) {
    os.on('enter', selector, (element: HTMLVideoElement) => {
      element.play()
    })

    os.on('leave', selector, (element: HTMLVideoElement) => {
      element.pause()
    })
  }
}

const setupTestimonials = (elements: HTMLCollection, os: any, selector: string, swiper?: Swiper): void => {
  if (elements.length !== 0) {
    os.on('enter', selector, (element: HTMLVideoElement) => {
      swiper.enable()
    })

    os.on('leave', selector, (element: HTMLVideoElement) => {
      swiper.disable()
    })
  }
}

export default viewportActivation
