import { Engine, acorn, Renderer, MouseEventHandler } from 'way-of-life'

const defaultOptions = {
    canvasSelector: '#gameoflife',
    desiredFPS: 9,
    pixelsPerCell: 28,
    strokeStyle: 'rgba(86, 86, 89, 0)',
    fillStyle: 'rgba(86, 86, 89, 0.4)',
    showText: false,
    useWasm: false,
}

const options = defaultOptions
options.desiredFPS = parseInt(options.desiredFPS, 10)
options.pixelsperCell = parseInt(options.pixelsperCell, 10)

const gameOfLife = () => {
    const canvas = document.querySelector(options.canvasSelector)

    const width = ~~(canvas.clientWidth / (options.pixelsPerCell - 2))
    const height = ~~(canvas.clientHeight / (options.pixelsPerCell - 2))

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
    const events = new MouseEventHandler(canvas, engine, renderer)

    const checkFlag = () => {
        if (engine.module.calledRun !== true) {
            window.setTimeout(checkFlag.bind(this), 100)
        } else {

            jsEngine.init()
            acorn(jsEngine, Math.ceil(Math.random() * ~~(height / 2)), Math.ceil(Math.random() * ~~(width / 2)))
            // start
            renderer.start()
        }
    }
    checkFlag()
}

window.onload = gameOfLife
