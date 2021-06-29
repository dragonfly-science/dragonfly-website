import smoothscroll from 'smoothscroll-polyfill'

import Carousel from '~root/carousel'
import Filtering from '~root/filtering'
import Footer from '~root/footer'
import ImageCaptions from '~root/image-caption'
import LazyLoad from '~root/lazy-load'
import MobileMenu from '~root/mobile-menu'
import OnScreen from '~root/on-screen'
import Parallaxing from '~root/parallax'
import StickySidebar from '~root/sticky-sidebar'
import TopSection from '~root/top-section'
import Slideshow from '~root/slideshow'

Zepto(() => {
  Filtering()
  MobileMenu()
  TopSection()
  LazyLoad()
  Parallaxing()
  ImageCaptions()
  Footer()
  StickySidebar('.sticky-container__body', '.sticky-container__element')
  Carousel('carousel-images')
  const swiper = Slideshow(
    '.slideshow-swiper',
    '.swiper-button-next',
    '.swiper-button-prev'
  )
  OnScreen(swiper)
})
