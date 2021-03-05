import { jarallax } from 'jarallax'

const Parallaxing = (): void => {
  jarallax(document.querySelectorAll('.jarallax'), {
    speed: 0,
    imgPosition: '50% 0',
  })
}

export default Parallaxing
