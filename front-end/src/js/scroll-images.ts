const scrollable = (): void => {
  $('.scrollable').each((i, item) => {
    if ($(window).width() <= 1024) {
      $(item).attr('style', '')
      $(item).find('img').attr('style', '')
      return true
    }

    const scrollT = $('html, body').scrollTop()
    const winH = $(window).height()
    const offset = $(item).offset()
    const diff =
      offset.top + $(item).parent().height() / 2 - (scrollT + winH / 2)
    const max = Math.max(
      $(item).siblings('.numbered-section__content').height(),
      $(item).find('img').height() + 128
    )

    if (diff >= 0) {
      $(item).css({
        height: max,
        position: 'relative',
      })
      $(item).find('img').css({
        position: 'absolute',
        marginTop: diff,
      })
    }

    return true
  })
}

export default (): void => {
  window.addEventListener('scroll', scrollable, { passive: true })
  window.addEventListener('resize', scrollable)
  scrollable()
}
