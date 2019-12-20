import { acorn, MouseEventHandler } from 'way-of-life'
import Engine from './engine'
import Renderer from './renderer'
import $ from 'zepto'

const defaultOptions = {
    canvasSelector: '#gameoflife',
    desiredFPS: parseInt($('.animation-controls__input').val()),
    pixelsPerCell: 28,
    fillStyle: '#43A1C9',
}

const options = defaultOptions
options.desiredFPS = parseInt(options.desiredFPS, 10)
options.pixelsperCell = parseInt(options.pixelsperCell, 10)
const gameOfLife = () => {
    const canvas = document.querySelector(options.canvasSelector)

    if (canvas === null) {
        return
    }

    const width = ~~(canvas.clientWidth / (options.pixelsPerCell))
    const height = ~~(canvas.clientHeight / (options.pixelsPerCell))

    const jsEngine = new Engine(width, height)
    const engine  = jsEngine
    window.engine = engine

    const renderer = new Renderer(canvas, engine, {
        desiredFPS: options.desiredFPS,
        pixelsPerCell: options.pixelsPerCell,
        strokeStyle: options.strokeStyle,
        fillStyle: options.fillStyle
    })

    // mouse events
    new MouseEventHandler(canvas, engine, renderer)

    const initialize = () => {
        if (engine.module.calledRun !== true) {
            window.setTimeout(checkFlag.bind(this), 100)
        } else {
            jsEngine.init()
            acorn(jsEngine, ~~(height / 2), ~~(width / 2))
            acorn(jsEngine, ~~(height / 2) + options.pixelsPerCell, ~~(width / 2))
            renderer.start()
        }
    }
    initialize()

    // Set up controls to alter speed
    $('.animation-controls__header button').on('click', function(e) {
        $('.animation-controls').toggleClass('open')
    })

    $('.animation-controls__input').on('change keyup', function(e) {
        let val = parseInt($(this).val())

        if (val < 0) {
            val = 0
        }

        renderer.play = false
        renderer.desiredFPS = val
        renderer.play = true
    })

    let mouseTimeout = null;

    const changeValue = (el) => {
        let val = parseInt($('.animation-controls__input').val()) + ($(el).is('.up') ? 1 : -1 )
        const matches = $('.animation-controls__input').val().match(/fps$/)

        if (val < 0) {
            val = 0
        }

        renderer.play = false
        renderer.desiredFPS = val
        renderer.play = true

        val += matches === null ? '' : 'fps'

        $('.animation-controls__input').val(val)
    }

    $('.animation-controls__control button').on('click', function() {
        changeValue(this)
    })

    $('.animation-controls__control button').on('mousedown', function(e) {
        const self = this

        mouseTimeout = setInterval(function() {
            changeValue(self)
        }, 100)
    })

    $('.animation-controls__control button').on('mouseup', function() {
        clearInterval(mouseTimeout)
    })
}

export default gameOfLife
