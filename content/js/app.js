import smoothscroll from 'smoothscroll-polyfill'
import Zepto from 'zepto'

import MobileMenu from './mobile-menu'
import Publications from './publications'
import TopSection from './top-section'
import LazyLoad from './lazy-load'

smoothscroll.polyfill()

Zepto(($) => {
    Publications($)
    MobileMenu()
    TopSection($)
    LazyLoad()
})