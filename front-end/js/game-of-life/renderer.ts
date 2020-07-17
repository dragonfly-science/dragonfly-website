import Engine from './engine'

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
    this.canvas.width = this.engine.width * this.pixelsPerCell
    this.canvas.height = this.engine.height * this.pixelsPerCell

    this.context.translate(0.5, 0.5)

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

    this.canvas.width = this.engine.width * this.pixelsPerCell
    this.canvas.height = this.engine.height * this.pixelsPerCell
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
    const x =
      this.canvas.width / 2 - ((this.canvas.width / 2) % this.pixelsPerCell)
    const y =
      this.canvas.height / 2 - ((this.canvas.height / 2) % this.pixelsPerCell)
    const w = this.canvas.width / this.pixelsPerCell
    const h = this.canvas.height / this.pixelsPerCell

    for (let i = 0; i < w; i++) {
      const newX = Math.ceil(x + i * this.pixelsPerCell)
      const newX1 = Math.floor(x - i * this.pixelsPerCell)

      this.context.beginPath()
      this.context.strokeStyle =
        i % 2 === 1 ? 'rgba(67, 161, 201, 0.9)' : 'rgba(67, 161, 201, 0.4)'
      this.context.moveTo(newX, 0)
      this.context.lineTo(newX, this.canvas.height)

      if (newX !== newX1) {
        this.context.moveTo(newX1, 0)
        this.context.lineTo(newX1, this.canvas.height)
      }
      this.context.stroke()
    }

    for (let i = 0; i < h; i++) {
      const newY = Math.ceil(y + i * this.pixelsPerCell)
      const newY1 = Math.floor(y - i * this.pixelsPerCell)

      this.context.beginPath()
      this.context.strokeStyle =
        i % 2 === 1 ? 'rgba(67, 161, 201, 0.9)' : 'rgba(67, 161, 201, 0.4)'
      this.context.moveTo(0, newY)
      this.context.lineTo(this.canvas.width, newY)

      if (newY !== newY1) {
        this.context.moveTo(0, newY1)
        this.context.lineTo(this.canvas.width, newY1)
      }
      this.context.stroke()
    }
  }

  public start(): void {
    this.engine.computeNextState()
    this.play = true
    window.requestAnimationFrame(this.draw.bind(this))
  }

  public stop(): void {
    this.play = false
  }
}

export { Renderer as default }
