import * as d3 from 'd3'
import { saveAs } from 'file-saver'

import Engine from '~game-of-life/engine'
import { drawGrid } from '~game-of-life/grid'

export interface RendererOptions {
  canvasSelector?: string
  desiredFPS?: number
  fillStyle?: string
  fpsNode?: boolean
  pixelsPerCell?: number
  strokeStyle?: string
}

class Renderer {
  public canvas: HTMLCanvasElement
  public context: CanvasRenderingContext2D
  public pixelsPerCell: number
  public engine: Engine
  public desiredFPS: number
  public fpsNode: boolean
  public fillStyle: string

  // renderer variables
  public play: boolean
  public fpsTime: number
  public engineTime: number
  public fps: number
  public frameNumber: number

  constructor(
    canvas: HTMLCanvasElement,
    engine: Engine,
    options: RendererOptions = {}
  ) {
    this.canvas = canvas
    this.context = canvas.getContext('2d')
    this.engine = engine

    // options
    this.pixelsPerCell = options.pixelsPerCell || 5
    this.desiredFPS = options.desiredFPS || 30
    this.fpsNode = options.fpsNode || false
    this.fillStyle = options.fillStyle || 'rgba(222,122,39,0.5)'

    // renderer variables
    this.play = false
    this.fpsTime = 0
    this.engineTime = 0
    this.fps = 0
    this.frameNumber = 0

    // setup canvas with correct size
    this.canvas.width = this.canvas.clientWidth
    this.canvas.height = this.canvas.clientHeight

    // this.context.translate(0.5, 0.5)

    window.addEventListener('orientationchange', this.resize.bind(this))
    window.addEventListener('resize', this.resize.bind(this))
  }

  public togglePlay(): void {
    this.play = !this.play
  }

  public resize(): void {
    this.play = false

    const width = ~~(this.canvas.clientWidth / this.pixelsPerCell)
    const height = ~~(this.canvas.clientHeight / this.pixelsPerCell)

    this.engine.reset(width, height)

    this.canvas.width = this.canvas.clientWidth
    this.canvas.height = this.canvas.clientHeight
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height)
    this.play = true
  }

  public draw(timeStamp: number): void {
    window.requestAnimationFrame(this.draw.bind(this))

    // display engine state on each frame
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height)

    this.drawGrid()

    const shouldFillRect = this.pixelsPerCell > 1
    for (let i = 0; i < this.engine.height; i++) {
      for (let j = 0; j < this.engine.width; j++) {
        if (this.engine.cellSafe(i, j)) {
          const jPx = this.pixelsPerCell * j
          const iPx = this.pixelsPerCell * i

          this.context.beginPath()

          this.context.fillStyle = this.fillStyle
          this.context.lineWidth = 0

          this.context.strokeRect(
            jPx,
            iPx,
            this.pixelsPerCell,
            this.pixelsPerCell
          )
          if (shouldFillRect) {
            this.context.fillRect(
              jPx,
              iPx,
              this.pixelsPerCell,
              this.pixelsPerCell
            )
          }
        }
      }
    }

    // compute engine next step with appropriate frequency
    const engineElapsed = timeStamp - this.engineTime
    if (engineElapsed > 1000 / this.desiredFPS && this.play) {
      this.engine.computeNextState()
      this.frameNumber += 1
      this.engineTime = timeStamp - (engineElapsed % (1000 / this.desiredFPS))
    }
  }

  public drawGrid(): void {
    drawGrid({
      canvas: this.canvas,
      context: this.context,
      pixelsPerCell: this.pixelsPerCell,
    })
  }

  public start(): void {
    this.engine.computeNextState()
    this.play = true
    window.requestAnimationFrame(this.draw.bind(this))
  }

  public stop(): void {
    this.play = false
  }

  public save(): void {
    const isPlaying = this.play

    this.stop()

    const { height, width } = this.canvas

    const existing = document.querySelector('#blob > svg')

    if (existing) {
      existing.remove()
    }

    const svg = d3
      .select('#blob')
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .attr('viewBox', `0 0 ${width} ${height}`)
      .attr('class', 'hidden')

    svg
      .append('rect')
      .attr('width', width)
      .attr('height', height)
      .attr('x', 0)
      .attr('y', 0)
      .attr('fill', 'none')
      .attr('stroke', 'none')
      .attr('id', 'group')

    const shouldFillRect = this.pixelsPerCell > 1
    for (let i = 0; i < this.engine.height; i++) {
      for (let j = 0; j < this.engine.width; j++) {
        if (this.engine.cellSafe(i, j)) {
          const jPx = this.pixelsPerCell * j
          const iPx = this.pixelsPerCell * i

          svg
            .append('rect')
            .attr('x', jPx)
            .attr('y', iPx)
            .attr('width', this.pixelsPerCell)
            .attr('height', this.pixelsPerCell)
            .attr('strokeWidth', 1)
            .attr('stroke', shouldFillRect ? this.fillStyle : 'transparent')
            .attr('fill', shouldFillRect ? this.fillStyle : 'transparent')
        }
      }
    }

    const blob = new Blob([svg.node().outerHTML], { type: 'image/svg+xml' })
    saveAs(blob, 'game-of-life.svg')

    if (isPlaying) {
      this.togglePlay()
    }
  }
}

export { Renderer as default }
