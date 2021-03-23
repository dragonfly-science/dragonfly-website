const ImageCaptions = (): void => {
  const captions = $('.image-caption')

  captions.forEach((caption) => {
    const cite = $(caption).find('cite')
    const citation = cite.first().html().trim()

    if (citation !== '') {
      cite.first().html(`image credit: ${citation}`)
    }
  })
}

export default ImageCaptions
