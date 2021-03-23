import smoothscroll from 'smoothscroll-polyfill'

import Columns from '~root/_2column-grid'
import Filtering from '~root/filtering'
import Footer from '~root/footer'
import GameOfLife from '~root/game-of-life/game-of-life'
import ImageCaptions from '~root/image-caption'
import LazyLoad from '~root/lazy-load'
import MobileMenu from '~root/mobile-menu'
import Parallaxing from '~root/parallax'
import StickySidebar from '~root/sticky-sidebar'
import TopSection from '~root/top-section'

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
  setTimeout(() => GameOfLife(), 1000)
})
