/**
 * Positions all 2 column grid items in a grid layout to line the contents
 * inside the container of the main logo.
 */

export default (): void => {
  $(window)
    .on('resize orientationchange', () => {
      const adverts = $('.collection-grid--2cell .no-gutter-cell')

      adverts.forEach((value: HTMLElement) => {
        value.style.transition = 'none'
      })
    })
    .resize()
}
