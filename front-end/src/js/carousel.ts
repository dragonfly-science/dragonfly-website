import fetch from 'cross-fetch'

const Carousel = async (targetId: string): Promise<void> => {
  const carousel = document.getElementById(targetId)

  if (!carousel) {
    return
  }

  const { bannerCount, bannerFolder, bannerPattern } = carousel.dataset

  const urls = Array(+bannerCount).fill('').map((_, i: number): string => {
    let s = `${bannerFolder}/`
    s += bannerPattern.replace('${index}', `${i + 1 < 10 ? '0' : ''}${i + 1}`)

    // prefetch all urls
    let link = document.createElement("link");
    link.setAttribute("rel", 'prefetch');
    link.setAttribute("href", s);
    document.head.appendChild(link);

    return s
  })

  const res = await Promise.all(urls.map(u=>fetch(u))).then(responses =>
    Promise.all(responses.map(res => res.status))
  )

  const loaded = res.every((i: number) => i === 200)

  const baseCSS = 'w-full h-full bg-black transition-opacity ease-in-out duration-500 opacity-0 absolute top-0 left-0 bg-cover z-0'

  // if loaded, then start loading in the slideshow.
  const first = document.createElement("div")
  first.className = baseCSS
  const second = document.createElement("div")
  second.className = baseCSS

  carousel.appendChild(first)
  carousel.appendChild(second)

  let current = 0

  // convert to request animation frame.
  setInterval(() => {
    const index = ++current
    const mod = index % urls.length

    if (mod % 2 === 1) {
      first.style.backgroundImage = `url(${urls[mod]})`
      first.classList.replace('opacity-0', 'opacity-100')
      first.classList.replace('z-0', 'z-20')
      second.classList.replace('opacity-100', 'opacity-0')
      second.classList.replace('z-20', 'z-0')
    } else {
      second.style.backgroundImage = `url(${urls[mod]})`
      second.classList.replace('opacity-0', 'opacity-100')
      second.classList.replace('z-0', 'z-20')
      first.classList.replace('opacity-100', 'opacity-0')
      first.classList.replace('z-20', 'z-0')
    }


  }, 5000)

}

export default Carousel
