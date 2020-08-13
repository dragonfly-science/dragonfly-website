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
  let start: number = 0
  let end: number = 0
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
  context.strokeStyle =
    index % 2 === 1 ? 'rgba(67, 161, 201, 0.9)' : 'rgba(67, 161, 201, 0.4)'
  context.moveTo(moveA[0], moveA[1])
  context.lineTo(lineA[0], lineA[1])

  if (start !== end) {
    context.moveTo(moveB[0], moveB[1])
    context.lineTo(lineB[0], lineB[1])
  }
  context.stroke()
}

const drawGrid = ({ canvas, pixelsPerCell, context }: DrawProps): void => {
  const x = canvas.width / 2 - ((canvas.width / 2) % pixelsPerCell)
  const y = canvas.height / 2 - ((canvas.height / 2) % pixelsPerCell)
  const w = canvas.width / pixelsPerCell
  const h = canvas.height / pixelsPerCell

  for (let i = 0; i < w; i++) {
    // const newX = Math.ceil(x + i * pixelsPerCell)
    // const newX1 = Math.floor(x - i * pixelsPerCell)

    // context.beginPath()
    // context.strokeStyle =
    //   i % 2 === 1 ? 'rgba(67, 161, 201, 0.9)' : 'rgba(67, 161, 201, 0.4)'
    // context.moveTo(newX, 0)
    // context.lineTo(newX, canvas.height)

    // if (newX !== newX1) {
    //   context.moveTo(newX1, 0)
    //   context.lineTo(newX1, canvas.height)
    // }
    // context.stroke()
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
    // const newY = Math.ceil(y + i * pixelsPerCell)
    // const newY1 = Math.floor(y - i * pixelsPerCell)

    // context.beginPath()
    // context.strokeStyle =
    //   i % 2 === 1 ? 'rgba(67, 161, 201, 0.9)' : 'rgba(67, 161, 201, 0.4)'
    // context.moveTo(0, newY)
    // context.lineTo(canvas.width, newY)

    // if (newY !== newY1) {
    //   context.moveTo(0, newY1)
    //   context.lineTo(canvas.width, newY1)
    // }
    // context.stroke()
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
