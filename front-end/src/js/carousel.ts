import fetch from 'cross-fetch'

const reOrderFrames = (first: HTMLDivElement, second: HTMLDivElement) => (url: string, top: 'first' | 'second') => {
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

const Carousel = async (targetId: string): Promise<void> => {
  const carousel = document.getElementById(targetId)

  if (!carousel) {
    return
  }

  const { bannerCount, backgroundImage, bannerFolder, bannerPattern } = carousel.dataset

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

  // load first
  await fetch(urls[0])

  const displayFrames = reOrderFrames(first, second)

  // reOrderFrames(first, urls, second)
  displayFrames(urls[0], 'first')


  // // load remainder
  const res = await Promise.all(urls.slice(1).map(u=>fetch(u))).then(responses =>
    Promise.all(responses.map(res => res.status))
  )

  const loaded = res.every((i: number) => i === 200)

  let current = 0

  // // convert to request animation frame.
  setInterval(() => {
    const index = ++current
    const mod = index % urls.length

    if (mod % 2 === 1) {
      displayFrames(urls[mod], 'first')
      // first.style.backgroundImage = `url(${urls[mod]})`
      // first.classList.replace('opacity-0', 'opacity-100')
      // first.classList.replace('z-0', 'z-1')
      // second.classList.replace('opacity-100', 'opacity-0')
      // second.classList.replace('z-1', 'z-0')
    } else {
      displayFrames(urls[mod], 'second')
      // second.style.backgroundImage = `url(${urls[mod]})`
      // second.classList.replace('opacity-0', 'opacity-100')
      // second.classList.replace('z-0', 'z-1')
      // first.classList.replace('opacity-100', 'opacity-0')
      // first.classList.replace('z-1', 'z-0')
    }
  }, 4000)

}

export default Carousel

