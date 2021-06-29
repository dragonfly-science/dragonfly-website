interface DrawProps {
  context: CanvasRenderingContext2D
  canvas: HTMLCanvasElement
  pixelsPerCell: number
}

enum Direction {
  X,
  Y,
}

type LineProps = {
  index: number
  direction: Direction
  x: number
  y: number
} & DrawProps

const drawLine = ({
  index,
  canvas,
  context,
  direction,
  pixelsPerCell,
  x,
  y,
}: LineProps): void => {
  let start = 0
  let end = 0
  let moveA: number[] = []
  let moveB: number[] = []
  let lineA: number[] = []
  let lineB: number[] = []

  if (direction === Direction.X) {
    start = Math.ceil(x + index * pixelsPerCell)
    end = Math.floor(x - index * pixelsPerCell)

    moveA = [start, 0]
    lineA = [start, canvas.height]
    moveB = [end, 0]
    lineB = [end, canvas.height]
  } else {
    start = Math.ceil(y + index * pixelsPerCell)
    end = Math.floor(y - index * pixelsPerCell)

    moveA = [0, start]
    lineA = [canvas.width, start]
    moveB = [0, end]
    lineB = [canvas.width, end]
  }

  context.beginPath()
  context.lineWidth = 1
  context.lineCap = 'butt'
  context.strokeStyle =
    index % 2 === 1 ? 'rgba(67, 161, 201, 0.9)' : 'rgba(67, 161, 201, 0.4)'
  context.moveTo(moveA[0] + 0.5, moveA[1] + 0.5)
  context.lineTo(lineA[0] + 0.5, lineA[1] + 0.5)

  if (start !== end) {
    context.moveTo(moveB[0] + 0.5, moveB[1] + 0.5)
    context.lineTo(lineB[0] + 0.5, lineB[1] + 0.5)
  }
  context.stroke()
}

const drawGrid = ({ canvas, pixelsPerCell, context }: DrawProps): void => {
  const x = canvas.width / 2 - ((canvas.width / 2) % pixelsPerCell)
  const y = canvas.height / 2 - ((canvas.height / 2) % pixelsPerCell)
  const w = canvas.width / pixelsPerCell
  const h = canvas.height / pixelsPerCell

  for (let i = 0; i < w; i++) {
    drawLine({
      index: i,
      canvas,
      context,
      direction: Direction.X,
      pixelsPerCell,
      x,
      y,
    })
  }

  for (let i = 0; i < h; i++) {
    drawLine({
      index: i,
      canvas,
      context,
      direction: Direction.Y,
      pixelsPerCell,
      x,
      y,
    })
  }
}

export { drawGrid }
