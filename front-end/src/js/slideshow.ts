import Swiper from 'swiper/bundle'
// import Swiper styles
import 'swiper/swiper-bundle.css'

const Slideshow = (target: string, next: string, prev: string): void => {
  const [targetEl, nextEl, prevEl] = [
    document.querySelector(target),
    document.querySelector(next),
    document.querySelector(prev),
  ]

  if (targetEl == null || nextEl == null || prevEl == null) {
    return
  }

  var swiper = new Swiper(target, {
    slidesPerView: 1,
    loop: true,
    pagination: false,
    navigation: {
      nextEl: next,
      prevEl: prev,
    },
    autoplay: {
      delay: 5000,
      disableOnInteraction: false,
    },
  })
}

export default Slideshow
