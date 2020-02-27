import { jarallax } from 'jarallax'

const Parallaxing = () => {
    jarallax(document.querySelectorAll('.jarallax'), {
        speed: 0,
        imgPosition: '50% 0',
    })
}

export default Parallaxing
