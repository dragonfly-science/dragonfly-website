import smoothscroll from 'smoothscroll-polyfill'

import Columns from './_2column-grid'
import Buttons from './button-link'
import Filtering from './filtering'
import LazyLoad from './lazy-load'
import MobileMenu from './mobile-menu'
import Parallaxing from './parallax'
import TopSection from './top-section'

import GameOfLife from './game-of-life/game-of-life'

smoothscroll.polyfill()

Zepto(($: ZeptoStatic) => {
    // Buttons()
    Columns()
    Filtering()
    MobileMenu()
    TopSection()
    LazyLoad()
    Parallaxing()
    GameOfLife()

    $('.button-link').on('click', function(this: HTMLElement, e: Event) {
        e.stopPropagation()

        console.log($(this).data('href'))
        location.href = $(this).data('href')
    })
})
