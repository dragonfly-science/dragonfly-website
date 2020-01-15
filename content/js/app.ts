import smoothscroll from 'smoothscroll-polyfill'

import Columns from './_2column-grid'
import LazyLoad from './lazy-load'
import MobileMenu from './mobile-menu'
import Parallaxing from './parallax'
import Publications from './publications'
import TopSection from './top-section'

import GameOfLife from './game-of-life/game-of-life'

smoothscroll.polyfill()

Zepto(($: ZeptoStatic) => {
    Columns()
    Publications()
    MobileMenu()
    TopSection()
    LazyLoad()
    Parallaxing()
    GameOfLife()
})
