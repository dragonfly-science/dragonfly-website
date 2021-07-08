import fetch from 'cross-fetch'

const TIMEOUT: number = 4000
const FRAMES_PER_SECOND: number = 250


const reOrderFrames = (first: HTMLDivElement, second: HTMLDivElement) => (url: string, top: 'first' | 'second'): void => {
  const [ next, previous ] = [
    top === 'first' ? first : second,
    top === 'first' ? second : first
  ]

  next.style.backgroundImage = `url(${url})`
  next.classList.replace('opacity-0', 'opacity-85')
  next.classList.replace('z-0', 'z-10')
  previous.classList.replace('opacity-85', 'opacity-0')
  previous.classList.replace('z-10', 'z-0')
}

const loadFrame = (el: HTMLDivElement, url: string): void => {
  el.style.backgroundImage = `url(${url})`
}

const Carousel = async (targetId: string): Promise<void> => {
  const carousel = document.getElementById(targetId)

  if (!carousel) {
    return
  }

  const { bannerCount, bannerFolder, bannerPattern } = carousel.dataset
  let timeoutCompleted = false

  let urls = Array(+bannerCount).fill('').map((_, i: number): string => {
    let s = `${bannerFolder}/`
    s += bannerPattern.replace('${index}', `${i + 1 < 10 ? '0' : ''}${i + 1}`)

    // prefetch all urls
    let link = document.createElement("link");
    link.setAttribute("rel", 'prefetch');
    link.setAttribute("href", s);
    document.head.appendChild(link);

    return s
  })

  // using sort on array doesn't give us a truly random array order. Shuffling instead :(
  const temp: string[] = []

  for (let i = 0; i < urls.length; i++) {
    temp.push( urls.splice( Math.floor(Math.random() * urls.length), 1)[0])
  }
  temp.push(urls[0]);

  urls = temp

  const baseCSS = 'w-full h-full bg-dark-jungle-green transition-opacity ease-in-out duration-500 opacity-0 absolute top-0 left-0 bg-cover bg-center z-0'

  const first = document.createElement("div")
  const second = document.createElement("div")
  first.className = second.className = baseCSS

  carousel.appendChild(first)
  carousel.appendChild(second)

  if (urls.length < 2) {
    return
  }

  // load first & second
  await fetch(urls[0])
  await fetch(urls[1])

  const displayFrames = reOrderFrames(first, second)

  displayFrames(urls[0], 'first')

  setTimeout(() => {
    displayFrames(urls[1], 'second')
    timeoutCompleted = true
  }, TIMEOUT)


  // load remainder
  const res = await Promise.all(urls.slice(2).map(u=>fetch(u))).then(responses =>
    Promise.all(responses.map(res => res.status))
  )

  const loaded = res.every((i: number) => i === 200)

  if (!loaded) {
    return
  }

  let current = 1
  let counter = 0

  const draw = () => {
    if (timeoutCompleted) {
      if (counter++ >= FRAMES_PER_SECOND) {
        counter = 0
        const index = ++current
        const mod = index % urls.length

        if (mod % 2 === 0) {
          displayFrames(urls[mod], 'first')
        } else {
          displayFrames(urls[mod], 'second')
        }
      }
    }

    requestAnimationFrame(draw)
  }

  draw()
}

export default Carousel

