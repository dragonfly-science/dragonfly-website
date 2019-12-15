import { createBrowserHistory } from 'history'
import _ from 'underscore'
import List from 'list.js'
import QS from 'query-string'


// export const getParameterByName = (name) => {
//     name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
//     let regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
//     let results = regex.exec(location.search)

//     return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '))
// }

/**
 * Update the URL with query string params for tags & search (if available)
 * @param history History object
 */
const updateURL = (history, intialized = true) => {
    let parsed = QS.parse(location.search)
    let val = $('.filtering__search__input').val()
    let qs = {}

    if (!intialized) {
        return
    }

    if (val !== '') {
        qs.search = val
    }

    let tags = []
    $('.tag-list__tag--active').each(function(index, item) {
        if ($(this).data('tag') !== '') {
            tags.push($(this).data('tag').trim())
        }
    })

    if (tags.length > 0) {
        qs.tags = tags.join(',')
    }

    const stringified = QS.stringify(qs, {encode: false})

    history.push(`${location.pathname}?${stringified}`)
}

/**
 * Extract any QS vars & update the appropriate UI elements
 */
const decodeURL = () => {
    let parsed = QS.parse(location.search)

    if (typeof parsed.search !== 'undefined') {
        $('.filtering__search__input').val(parsed.search)
    }

    if (typeof parsed.tags !== 'undefined') {
        // Disable tags that aren't visible.
        $(`.tag-list__tag`).removeClass('tag-list__tag--active')
        _.each(parsed.tags.split(','), function(el) {
            $(`.tag-list__tag[data-tag="${el}"]`)
                .addClass('tag-list__tag--active')
                .removeClass('tag-list__tag--disabled')
        })
    }
}


const Publications = ($) => {
    if ($('#publication-list').length === 0) {
        return
    }

    let history = createBrowserHistory()
    let options = {
        valueNames: ['publication-tile__title', 
                     'publication-tile__citation',
                     'tagslugs'],
        searchClass: 'filtering__search__input',
    }
    let publicationList = null

    const updateList = () => {
        let foundTags = {
            'author': true,
            'subject': true,
            'publication-type': true,
        }

        _.each(['author', 'subject', 'publication-type'], function(element) {
            let current = []
            $(`.tag-list__tag--${element}.tag-list__tag--active[data-tag]`).each(function() {
                current.push($(this).attr('data-tag').trim())
            });

            current = _.filter(current, (t) => (!(t === '')))
            foundTags[element] = current
        })

        const authors = foundTags['author']
        const subjects = foundTags['subject']
        const publications = foundTags['publication-type']

        publicationList.filter((item) => {
            const itemtags = _.filter(item.values().tagslugs.trim().split(' '), (t) => (!(t === '')))

            const a = authors.length > 0 ? _.intersection(authors, itemtags).length === authors.length : true;
            const b = subjects.length > 0 ? _.intersection(subjects, itemtags).length == subjects.length : true;
            const c = publications.length > 0 ? _.intersection(publications, itemtags).length === publications.length : true;

            return a && b && c;
        })
    }

    decodeURL()

    publicationList = new List('publication-list', options)
    let intialized = false
    let searchVal = $('.filtering__search__input').val()

    if (searchVal !== '') {
        publicationList.search(searchVal)
    }

    publicationList.on('updated', () => {
        let n = 0 //publicationList.visibleItems.length
        let t = ''

        // Filter out any non-publication tiles (e.g. years)
        _.each(publicationList.visibleItems, function(el, index) {
            if ($(el.elm).is('.list-tile')) {
                n++
            }
        })
        
        updateURL(history, intialized)
        intialized = true

        switch (n) {
            case 0:
                t = 'Oops! There are no matching publications'
                break
            case 1:
                t = 'One matching publication'
                break
            default:
                t =`${n} matching publications`
                break
        }

        $('#publication-count').text(t)

        // get tags from visible list items.
        let visibleTags = [];
        _.each(publicationList.visibleItems, function(item) {
            visibleTags = visibleTags.concat(item.values().tagslugs.trim().split(' '))
        })
        visibleTags = _.uniq(visibleTags)

        // Diable tags that aren't visible.
        $('.tag-list__tag').each(function(index, item) {
            let tag = $(this).data('tag')

            if (typeof tag !== 'undefined') {
                tag = tag.trim()

                if (tag !== '' && _.indexOf(visibleTags, tag) === -1) {
                    $(this).addClass('tag-list__tag--disabled').removeClass('tag-list__tag--active')
                } else {
                    $(this).removeClass('tag-list__tag--disabled')
                }
            }
        })
    });

    updateList()

    // Tag buttons
    $('.tag-list__tag').click(function() {
        $(this).toggleClass('tag-list__tag--active')

        let isPubType = $(this).is('.tag-list__tag--publication-type')
        let isActive = $(this).hasClass('tag-list__tag--active')

        if (isPubType || (!isPubType && $(this).data('tag') === '')) {
            $(this).siblings('.tag-list__tag').removeClass('tag-list__tag--active')
        }

        if (!isPubType && $(this).data('tag') !== '') {
            $(this).siblings(`[data-tag='']`).removeClass('tag-list__tag--active')
        }

        updateList()
        updateURL(history)
    });

    // Set up filtering.
    $('.filtering__hamburger').on('click', function(e) {
        e.preventDefault();
  
        let filters = $(this).parents('.filtering')
  
        filters.toggleClass('open')
  
        if (filters.is('.open')) {
            $(this).addClass('dragonfly-close')
                .removeClass('dragonfly-hamburger')
        } else {
            $(this).addClass('dragonfly-hamburger')
                .removeClass('dragonfly-close')
        }
    })
}

export default Publications
