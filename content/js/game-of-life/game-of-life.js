import { acorn, MouseEventHandler } from 'way-of-life'
import Engine from './engine'
import Renderer from './renderer'

const defaultOptions = {
    canvasSelector: '#gameoflife',
    desiredFPS: 7,
    pixelsPerCell: 28,
    fillStyle: 'rgba(171, 167, 159, 0.8)',
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

    const checkFlag = () => {
        if (engine.module.calledRun !== true) {
            window.setTimeout(checkFlag.bind(this), 100)
        } else {

            jsEngine.init()
            acorn(jsEngine, ~~(height / 2), ~~(width / 2))
            renderer.start()
        }
    }
    checkFlag()
}

// class GameOfLife {
//     constructor() {

//     }
// }

export default gameOfLife
