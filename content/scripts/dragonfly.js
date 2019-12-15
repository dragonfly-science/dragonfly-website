+function() {



  function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
  }

  function tagFilter(tags){
    $('.tag').show().each(function(i, elem){
      tags.split(',').forEach(function(t){
        if (!(t === "") & (!$(elem).hasClass('tag-' + t ))){
          $(elem).remove();
          $("[data-tag=" + t + "]").parents(".dropdown").hide()
        }
      });
    });
  }


  var initPublications = function() {
    if ($("#publication-list").length === 0) {
      return;
    }

    // tagFilter(getParameterByName("tag"));

    var options = {
      valueNames: ['publication-tile__title', 'publication-tile__citation', 'tagslugs'],
      searchClass: 'filtering__search__input',
    };
    var publicationList = new List('publication-list', options);

    publicationList.on('updated', function(){
      var n = publicationList.visibleItems.length;
      if (n == 0){
        $('#publication-count').text('Oops! There are no matching publications');
      } else if (n == 1){
        $('#publication-count').text('One matching publication');
      } else {
        $('#publication-count').text(n + ' matching publications');
      }
    });


    var updateList = function() {
      var tags = [];
      var authors = [];
      var subjects = [];
      var publications = [];

      $(".tag-list__tag--author.tag-list__tag--active[data-tag]").each(function () {
        authors.push($(this).attr("data-tag").trim());
      });

      $(".tag-list__tag--subject.tag-list__tag--active[data-tag]").each(function () {
        subjects.push($(this).attr("data-tag").trim());
      });

      $(".tag-list__tag--publication-type.tag-list__tag--active[data-tag]").each(function(){
        publications.push($(this).attr("data-tag").trim());
      });

      authors = _.filter(authors, function(t){return !(t === "");});
      subjects = _.filter(subjects, function (t) { return !(t === ""); });
      publications = _.filter(publications, function (t) { return !(t === ""); });

      publicationList.filter(function(item) {
        var itemtags = _.filter(item.values().tagslugs.trim().split(' '), function(t){return !(t === "");});

        var a = authors.length > 0 ? _.intersection(authors, itemtags).length === authors.length : true;
        var b = subjects.length > 0 ? _.intersection(subjects, itemtags).length == subjects.length : true;
        var c = publications.length > 0 ? _.intersection(publications, itemtags).length === publications.length : true;

        return a && b && c;
      });

      // get tags from visible list items.
      var visibleTags = [];
      _.each(publicationList.visibleItems, function(item) {
        visibleTags = visibleTags.concat(item.values().tagslugs.trim().split(' '));
      });
      visibleTags = _.uniq(visibleTags);

      // Diable tags that aren't visible.
      $(".tag-list__tag[data-tag]").each(function () {
        var tag = $(this).attr("data-tag").trim();

        if (tag !== '' && _.indexOf(visibleTags, tag) === -1) {
          $(this).addClass('tag-list__tag--disabled').removeClass('tag-list__tag--active');
        } else {
          $(this).removeClass('tag-list__tag--disabled');
        }
      });
    }

    updateList();

    // Tag buttons
    $(".tag-list__tag").click(function() {
      $(this).toggleClass('tag-list__tag--active');

      if ($(this).is('.tag-list__tag--publication-type')) {
        $(this).siblings('.tag-list__tag').removeClass('tag-list__tag--active');
      } else {
        if ($(this).data('tag') === '') {
          $(this).siblings('.tag-list__tag').removeClass('tag-list__tag--active');
        } else {
          $(this).siblings('[data-tag=""]').removeClass('tag-list__tag--active');
        }
      }

      updateList();
    });
  }

  $(document).ready(function() {
    var section = 'none';
    var menuToggle = $('.mobile-menu');
    

    $('.mobile-menu').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();

      var wrapper = $('.main-nav');

      wrapper.toggleClass('open');

      if (wrapper.is('.open')) {
        $(this).addClass('dragonfly-close').removeClass('dragonfly-hamburger');
      } else {
        $(this).addClass('dragonfly-hamburger').removeClass('dragonfly-close');
      }
    });

    $('.filtering__hamburger').on('click', function(e) {
      e.preventDefault();

      var filters = $(this).parents('.filtering');

      filters.toggleClass('open');

      if (filters.is('.open')) {
        $(this).addClass('dragonfly-close').removeClass('dragonfly-hamburger');
      } else {
        $(this).addClass('dragonfly-hamburger').removeClass('dragonfly-close');
      }
    });

    $('a[href="#top-section"]').click(function(e) {
      e.preventDefault();

      var headerH = $('.main-header').outerHeight();
      var sectionOffset = $('#top-section').offset().top;

      $('html, body').animate({
        'scrollTop': sectionOffset - headerH
      })
    })



    // $(wrapper).on('click', function(e) {
    //   if(wrapper.is('.open') && menuToggle.is(':visible')) {
    //     wrapper.removeClass('open');
    //   }
    // });


    initPublications();

    $(document).mouseup(function (e){
      $(".dropdown-menu").each(function() {
        if (!$(this).is(e.target)  // if the target of the click isn't the container...
          && $(this).has(e.target).length === 0) { // ... nor a descendant of the container
            $(this).removeClass("show-menu");
          }
      });
    });
  });

}.call(this);
