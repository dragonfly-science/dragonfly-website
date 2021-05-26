import { acorn, MouseEventHandler } from 'way-of-life'
import Engine from '~game-of-life/engine'
import Renderer, { RendererOptions } from '~game-of-life/renderer'

interface GameofLifeWindow extends Window {
  engine: Engine
}

declare let window: GameofLifeWindow

const gameOfLife = (): void => {
  const options: RendererOptions = {
    canvasSelector: '#gameoflife',
    desiredFPS: 3,
    pixelsPerCell: 32,
    fillStyle: 'rgba(67, 161, 201, 0.7)',
  }
  const canvas: HTMLCanvasElement = document.querySelector(
    options.canvasSelector
  )

  if (canvas === null) {
    return
  }

  const width = ~~(canvas.clientWidth / options.pixelsPerCell)
  const height = ~~(canvas.clientHeight / options.pixelsPerCell)

  const engine = new Engine(width, height)
  window.engine = engine

  const renderer = new Renderer(canvas, engine, {
    desiredFPS: options.desiredFPS,
    pixelsPerCell: options.pixelsPerCell,
    strokeStyle: options.strokeStyle,
    fillStyle: options.fillStyle,
  })

  // mouse events
  // tslint:disable-next-line: no-unused-expression
  new MouseEventHandler(canvas, engine, renderer)

  const initialize = (): void => {
    if (engine.module.calledRun !== true) {
      window.setTimeout(initialize, 100)
    } else {
      engine.init()
      acorn(engine, ~~(height / 2), ~~(width / 2))
      acorn(engine, ~~(height / 2) + options.pixelsPerCell, ~~(width / 2))
      renderer.start()
    }
  }
  initialize()

  // Set up controls to alter speed
  $('.animation-controls__header button').on('click', () => {
    $('.animation-controls').toggleClass('open')
  })

  $('.animation-controls__input').on(
    'change keyup',
    function (this: HTMLElement) {
      let val = parseInt($(this).val(), 10)

      if (val < 0) {
        val = 0
      }

      renderer.play = false
      renderer.desiredFPS = val
      renderer.play = true
    }
  )

  // $('#pauseButton').on('click', () => {
  //   renderer.togglePlay()
  // })

  // $('#saveButton').on('click', () => {
  //   renderer.save()
  // })

  let mouseTimeout: NodeJS.Timeout = null

  const changeValue = (el: HTMLElement): void => {
    let val: number =
      parseInt($('.animation-controls__input').val(), 10) +
      ($(el).is('.up') ? 1 : -1)
    const matches = $('.animation-controls__input').val().match(/fps$/)

    if (val < 0) {
      val = 0
    }

    renderer.play = false
    renderer.desiredFPS = val
    renderer.play = true

    $('.animation-controls__input').val(val + (matches === null ? '' : 'fps'))
  }

  $('.animation-controls__control button').on(
    'click',
    function (this: HTMLElement) {
      changeValue(this)
    }
  )

  $('.animation-controls__control button').on(
    'mousedown',
    function (this: HTMLElement) {
      mouseTimeout = setInterval(() => {
        changeValue(this)
      }, 100)
    }
  )

  $('.animation-controls__control button').on('mouseup', () => {
    clearInterval(mouseTimeout)
  })
}

export default gameOfLife
