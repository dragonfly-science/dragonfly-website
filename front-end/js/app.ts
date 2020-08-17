import smoothscroll from 'smoothscroll-polyfill'

import Columns from './_2column-grid'
import Filtering from './filtering'
import Footer from './footer'
import GameOfLife from './game-of-life/game-of-life'
import ImageCaptions from './image-caption'
import LazyLoad from './lazy-load'
import MobileMenu from './mobile-menu'
import Parallaxing from './parallax'
import StickySidebar from './sticky-sidebar'
import TopSection from './top-section'

import env from 'env-var'

Zepto(() => {
  // console.log('Process', env.get('SHOWCONTROLS').asInt())
  Columns()
  Filtering()
  MobileMenu()
  TopSection()
  LazyLoad()
  Parallaxing()
  ImageCaptions()
  Footer()
  StickySidebar('.sticky-container__body', '.sticky-container__element')

  // setTimeout(() => smoothscroll.polyfill(), 500)

  setTimeout(() => GameOfLife(), 1000)
})
