import { createBrowserHistory, History } from 'history'

import List from 'list.js'
import { filter, forEach, indexOf, intersection, uniq } from 'lodash-es'
import pluralize from 'pluralize'
import QS from 'query-string'

interface QSParams {
  search?: string
  tags?: string
}

interface PublicationTags {
  [index: string]: string
  author: string
  subject: string
  'publication-type': string
}

interface PublicationTile {
  [index: string]: string
}

interface VisibleItem {
  elm?: HTMLElement
  values?: () => PublicationTags
}

/**
 * Update the URL with query string params for tags & search (if available)
 * @param history History object
 */
const updateURL = (history: History, intialized = true): void => {
  const val = $('.filtering__search__input').val()
  const qs: QSParams = {}

  if (!intialized) {
    return
  }

  if (val !== '') {
    qs.search = val
  }

  const tags: string[] = []
  $('.tag-list__tag--active').each((index, item) => {
    if (
      typeof $(item).data('tag') !== 'undefined' &&
      $(item).data('tag') !== ''
    ) {
      tags.push($(item).data('tag').trim())
    }

    return true
  })

  if (tags.length > 0) {
    qs.tags = tags.join(',')
  }

  const stringified = QS.stringify(qs, { encode: false })

  history.push(`${location.pathname}?${stringified}`)
}

/**
 * Extract any QS vars & update the appropriate UI elements
 */
const decodeURL = (): void => {
  const parsed: QS.ParsedQuery = QS.parse(location.search)

  if (typeof parsed.search !== 'undefined') {
    $('.filtering__search__input').val(parsed.search)
  }

  if (parsed.tags !== null) {
    // Disable tags that aren't visible.
    $(`.tag-list__tag`).removeClass('tag-list__tag--active')
    let t: string[] = []

    if (parsed !== undefined && parsed.tags !== undefined) {
      t = (parsed.tags as string).split(',')
    }
    forEach(t, (el: string) => {
      $(`.tag-list__tag[data-tag="${el}"]`)
        .addClass('tag-list__tag--active')
        .removeClass('tag-list__tag--disabled')
    })
  }
}

const Publications = (): void => {
  if ($('#filter-list').length === 0) {
    return
  }

  const history = createBrowserHistory()
  const options = {
    valueNames: ['tile__title', 'tile__citation', 'tagslugs'],
    searchClass: 'filtering__search__input',
  }

  let publicationList: List = null

  const updateList = (): void => {
    const foundTags: PublicationTags = {
      author: '',
      subject: '',
      'publication-type': '',
    }

    forEach(['author', 'subject', 'publication-type'], (element: string) => {
      let current = ''
      $(`.tag-list__tag--${element}.tag-list__tag--active[data-tag]`).each(
        (index, item) => {
          current += ` ${$(item).attr('data-tag').trim()}`
          return true
        }
      )

      foundTags[element] = current.trim()
    })

    const authors =
      foundTags['author'].length > 0 ? foundTags['author'].split(' ') : []
    const subjects =
      foundTags['subject'].length > 0 ? foundTags['subject'].split(' ') : []
    const publications =
      foundTags['publication-type'].length > 0
        ? foundTags['publication-type'].split(' ')
        : []

    publicationList.filter((item) => {
      const values: PublicationTile = item.values() as PublicationTile
      const itemtags = filter(
        values['tagslugs'].trim().split(' '),
        (t) => !(t === '')
      )

      const a =
        authors.length > 0
          ? intersection(authors, itemtags).length === authors.length
          : true
      const b =
        subjects.length > 0
          ? intersection(subjects, itemtags).length === subjects.length
          : true
      const c =
        publications.length > 0
          ? intersection(publications, itemtags).length === publications.length
          : true

      return a && b && c
    })
  }

  decodeURL()

  publicationList = new List('filter-list', options)
  let intialized = false
  const searchVal = $('.filtering__search__input').val()
  const contentType = $('#filter-list').data('type')

  if (searchVal !== '') {
    publicationList.search(searchVal)
  }

  publicationList.on('updated', () => {
    let n = 0
    let t = ''

    // Filter out any non-publication tiles (e.g. years)
    forEach(publicationList.visibleItems, (el) => {
      const e = el as VisibleItem

      if ($(e.elm).is('.list-tile')) {
        n++
      }
    })

    updateURL(history, intialized)
    intialized = true

    switch (n) {
      case 0:
        t = `Oops! There are no matching ${pluralize(contentType, 2)}`
        break
      case 1:
        t = `One matching ${contentType}`
        break
      default:
        t = `${n} matching ${pluralize(contentType, 2)}`
        break
    }

    $('#filter-count').text(t)

    // get tags from visible list items.
    let visibleTags: string[] = []
    forEach(publicationList.visibleItems as PublicationTile[], (item) => {
      const e: VisibleItem = item as VisibleItem
      const values: PublicationTags = e.values()
      visibleTags = visibleTags.concat(values['tagslugs'].trim().split(' '))
    })
    visibleTags = uniq(visibleTags)

    // Diable tags that aren't visible.
    $('.tag-list__tag').each((index: number, item: HTMLElement) => {
      let tag = $(item).data('tag')

      if (typeof tag !== 'undefined') {
        tag = tag.trim()

        if (tag !== '' && indexOf(visibleTags, tag) === -1) {
          $(item)
            .addClass('tag-list__tag--disabled')
            .removeClass('tag-list__tag--active')
        } else {
          $(item).removeClass('tag-list__tag--disabled')
        }
      }

      return true
    })

    // If no tags are active in a list, make the first one active.
    $('.tag-list').each((index: number, item: HTMLElement) => {
      if ($(item).find('.tag-list__tag--active').length === 0) {
        $(item)
          .find('.tag-list__tag:first-child')
          .removeClass('tag-list__tag--disabled')
          .addClass('tag-list__tag--active')
      }

      return true
    })
  })

  updateList()

  // Tag buttons
  $('.tag-list__tag').click(function (this: HTMLElement) {
    $(this).toggleClass('tag-list__tag--active')

    const isPubType = $(this).is('.tag-list__tag--publication-type')

    if (isPubType || (!isPubType && $(this).data('tag') === '')) {
      $(this).siblings('.tag-list__tag').removeClass('tag-list__tag--active')
    }

    if (!isPubType && $(this).data('tag') !== '') {
      $(this).siblings(`[data-tag='']`).removeClass('tag-list__tag--active')
    }

    updateList()
    updateURL(history)
  })

  // Set up filtering.
  $('.filtering__hamburger, .filtering__button').on('click', function (
    this: HTMLElement,
    e
  ) {
    e.preventDefault()

    const filters = $(this).parents('.filtering')

    filters.toggleClass('open')

    $(this).find('span').toggleClass('rotate-0 rotate-45')
  })
}

export default Publications
