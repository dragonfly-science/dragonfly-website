const video = (): void => {
  const videos = document.getElementsByTagName('video')

  for (const video of videos) {
    console.log(video)
    if (video) {
      ['click', 'touchstart'].forEach((e: string): void => {
        video.addEventListener(e, ((el: HTMLVideoElement) => (): void => {
          if (el.paused) {
            el.play()
          } else {
            el.pause()
          }
        })(video))
      })

    }
  }
}

export default video
