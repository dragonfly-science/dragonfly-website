import smoothscroll from 'smoothscroll-polyfill'

import Carousel from '~root/carousel'
import Columns from '~root/_2column-grid'
import Filtering from '~root/filtering'
import Footer from '~root/footer'
import ImageCaptions from '~root/image-caption'
import LazyLoad from '~root/lazy-load'
import MobileMenu from '~root/mobile-menu'
import Parallaxing from '~root/parallax'
import StickySidebar from '~root/sticky-sidebar'
import TopSection from '~root/top-section'
import Slideshow from '~root/slideshow'

Zepto(() => {
  Columns()
  Filtering()
  MobileMenu()
  TopSection()
  LazyLoad()
  Parallaxing()
  ImageCaptions()
  Footer()
  StickySidebar('.sticky-container__body', '.sticky-container__element')
  Carousel('carousel-images')
  Slideshow('.slideshow-swiper', '.swiper-button-next', '.swiper-button-prev')
})
