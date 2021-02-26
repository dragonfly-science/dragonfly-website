/**
 * Positions all 2 column grid items in a grid layout to line the contents
 * inside the container of the main logo.
 */

export default (): void => {
  $(window)
    .on('resize orientationchange', () => {
      const adverts = $('.collection-grid--2cell .no-gutter-cell')
      // const header = $('.main-header > .container')

      adverts.forEach((value: HTMLElement) => {
        // const p: number = ($(value).parent().width() - header.width()) / 2

        value.style.transition = 'none'

        // if ($(window).width() > 1024) {
        //     value.style.paddingLeft = i % 2 === 0 ? `${p}px` : `${defaulP}px`
        //     value.style.paddingRight = i % 2 === 1 ? `${p}px` : `${defaulP}px`
        // } else {
        //     value.style.paddingLeft = `${p}px`
        //     value.style.paddingRight = `${p}px`
        // }
      })
    })
    .resize()
}
