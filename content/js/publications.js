// import $ from 'zepto'
import _ from 'underscore'
import List from 'list.js'

export const getParameterByName = (name) => {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    let regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
    let results = regex.exec(location.search)

    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "))
}

// export const tagFilter = (tags) => {
//     $('.tag').show().each(function(i, elem){
//         tags.split(',').forEach(function(t){
//             if (!(t === "") & (!$(elem).hasClass(`tag-${t}`))){
//                 $(elem).remove();
//                 $("[data-tag=" + t + "]").parents(".dropdown").hide()
//             }
//         })
//     })
// }

// function getParameterByName(name) {
//     name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
//     var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
//         results = regex.exec(location.search);
//     return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
// }

// function tagFilter(tags){
//     $('.tag').show().each(function(i, elem){
//         tags.split(',').forEach(function(t){
//         if (!(t === "") & (!$(elem).hasClass('tag-' + t ))){
//             $(elem).remove();
//             $("[data-tag=" + t + "]").parents(".dropdown").hide()
//         }
//         });
//     });
// }


const Publications = ($) => {
    if ($("#publication-list").length === 0) {
        return
    }

    let options = {
        valueNames: ['publication-tile__title', 
                     'publication-tile__citation',
                     'tagslugs'],
        searchClass: 'filtering__search__input',
    }
    let publicationList = new List('publication-list', options)

    publicationList.on('updated', () => {
        let n = publicationList.visibleItems.length
        let t = ''

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
    });


    const updateList = () => {
        let foundTags = {
            'author': true,
            'subject': true,
            'publication-type': true,
        }

        _.each(['author', 'subject', 'publication-type'], function(element) {
            let current = []
            $(`.tag-list__tag--${element}.tag-list__tag--active[data-tag]`).each(function() {
                console.log('tag', `.tag-list__tag--${element}.tag-list__tag--active[data-tag]`, $(this).attr("data-tag"))
                current.push($(this).attr("data-tag").trim())
            });

            current = _.filter(current, (t) => (!(t === "")))
            foundTags[element] = current
        })

        const authors = foundTags['author']
        const subjects = foundTags['subject']
        const publications = foundTags['publication-type']

        publicationList.filter((item) => {
            const itemtags = _.filter(item.values().tagslugs.trim().split(' '), (t) => (!(t === "")))

            const a = authors.length > 0 ? _.intersection(authors, itemtags).length === authors.length : true;
            const b = subjects.length > 0 ? _.intersection(subjects, itemtags).length == subjects.length : true;
            const c = publications.length > 0 ? _.intersection(publications, itemtags).length === publications.length : true;

            return a && b && c;
        })

        // get tags from visible list items.
        let visibleTags = [];
        _.each(publicationList.visibleItems, function(item) {
            visibleTags = visibleTags.concat(item.values().tagslugs.trim().split(' '))
        })
        visibleTags = _.uniq(visibleTags)

        // Diable tags that aren't visible.
        $(".tag-list__tag").each(function(index, item) {
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
    }

    updateList()

    // Tag buttons
    $(".tag-list__tag").click(function() {
        $(this).toggleClass('tag-list__tag--active')

        let isPubType = $(this).is('.tag-list__tag--publication-type')

        if (isPubType || (!isPubType && $(this).data('tag') === '')) {
            $(this).siblings('.tag-list__tag').removeClass('tag-list__tag--active')
        }

        if (!isPubType && $(this).data('tag') !== '') {
            $(this).siblings('[data-tag=""]').removeClass('tag-list__tag--active')
        }

        updateList();
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
