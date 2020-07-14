const cloneFooter = (): void => {
  const footer = document.getElementById('main-footer')
  const cloned = footer.cloneNode(true) as HTMLElement
  cloned.setAttribute('id', 'modal-footer')
  cloned.classList.add(...'main-footer--modal'.split(' '))
  document.getElementsByTagName('body')[0].appendChild(cloned)

  const close = cloned.querySelector('.dragonfly-close')

  if (close) {
    close.addEventListener('click', () => {
      const scrollTop = document.body.scrollTop
      location.hash = ''
      window.scrollTo({
        top: scrollTop,
        behavior: 'smooth',
      })
      return false
    })
  }
}

const checkHash = (): void => {
  const hash = location.hash.substr(1)
  const footer = document.getElementById('modal-footer')

  if (hash === 'contact-dragonfly') {
    document.body.classList.add('modal-open')
    footer.classList.add('main-footer--is-open')
  } else {
    document.body.classList.remove('modal-open')
    footer.classList.remove('main-footer--is-open')
  }
}

const Footer = (): void => {
  cloneFooter()

  window.addEventListener('hashchange', checkHash)

  checkHash()
}

export default Footer
