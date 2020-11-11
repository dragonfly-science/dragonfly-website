'use strict'

interface EngineModule {
  calledRun: boolean
}

class Engine {
  public wasm: boolean
  public width: number
  public height: number
  public module: EngineModule

  public _width: number
  public _height: number
  public _current: Uint8Array
  public _next: Uint8Array

  constructor(width: number, height: number) {
    this.wasm = false
    this.width = width
    this._width = width + 2
    this.height = height
    this._height = height + 2
    this.module = { calledRun: true }
  }

  public init(): void {
    const buffer = new ArrayBuffer(this._width * this._height)
    this._current = new Uint8Array(buffer)
    const nextBuffer = new ArrayBuffer(this._width * this._height)
    this._next = new Uint8Array(nextBuffer)
    this.module = { calledRun: true }
  }

  public reset(width: number, height: number): void {
    this.width = width
    this._width = width + 2
    this.height = height
    this._height = height + 2

    let buffer = new ArrayBuffer(this._width * this._height)
    let _c = new Uint8Array(buffer)
    for (let i = 0; i < this._current.length; i++) {
      _c[i] = this._current[i]
    }

    this._current = _c

    buffer = new ArrayBuffer(this._width * this._height)
    _c = new Uint8Array(buffer)
    for (let i = 0; i < this._next.length; i++) {
      _c[i] = this._next[i]
    }

    this._next = _c
  }

  public index(i: number, j: number): number {
    return i * this._width + j
  }

  public cell(i: number, j: number): number {
    return this._current[this.index(i, j)]
  }

  public cellSafe(i: number, j: number): number {
    return this._current[(i + 1) * this._width + j + 1]
  }

  public next(i: number, j: number): number {
    return this._next[this.index(i, j)]
  }

  public loopCurrentState(): void {
    for (let j = 1; j < this._width + 1; j++) {
      this._current[this.index(0, j)] = this._current[
        this.index(this._height - 2, j)
      ]
      this._current[this.index(this._height - 1, j)] = this._current[
        this.index(1, j)
      ]
    }

    for (let i = 1; i < this._height + 1; i++) {
      this._current[this.index(i, 0)] = this._current[
        this.index(i, this._width - 2)
      ]
      this._current[this.index(i, this._width - 1)] = this._current[
        this.index(i, 1)
      ]
    }

    this._current[this.index(0, 0)] = this._current[
      this.index(this._height - 2, this._width - 2)
    ]
    this._current[this.index(0, this._width - 1)] = this._current[
      this.index(this._height - 2, 1)
    ]
    this._current[this.index(this._height - 1, 0)] = this._current[
      this.index(1, this._width - 2)
    ]
    this._current[
      this.index(this._height - 1, this._width - 1)
    ] = this._current[this.index(1, 1)]
  }

  public computeNextState(): void {
    let neighbors: number
    let iM1: number
    let iP1: number
    let i_: number
    let jM1: number
    let jP1: number

    this.loopCurrentState()

    for (let i = 1; i < this._height - 1; i++) {
      iM1 = (i - 1) * this._width
      iP1 = (i + 1) * this._width
      i_ = i * this._width

      for (let j = 1; j < this._width - 1; j++) {
        jM1 = j - 1
        jP1 = j + 1
        neighbors = this._current[iM1 + jM1]
        neighbors += this._current[iM1 + j]
        neighbors += this._current[iM1 + jP1]
        neighbors += this._current[i_ + jM1]
        neighbors += this._current[i_ + jP1]
        neighbors += this._current[iP1 + jM1]
        neighbors += this._current[iP1 + j]
        neighbors += this._current[iP1 + jP1]

        if (neighbors === 3) {
          this._next[i_ + j] = 1
        } else if (neighbors === 2) {
          this._next[i_ + j] = this._current[i_ + j]
        } else {
          this._next[i_ + j] = 0
        }
      }
    }

    this._current.set(this._next)
  }

  public set(i: number, j: number, value = 1): void {
    this._current[this.index(i, j)] = value
  }

  public setNext(i: number, j: number, value = 1): void {
    this._next[this.index(i, j)] = value
  }
}

export default Engine
