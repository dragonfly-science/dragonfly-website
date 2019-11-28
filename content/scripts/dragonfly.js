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

    tagFilter(getParameterByName("tag"));

    var options = {
      valueNames: ['citation', 'tagslugs']
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
      $(".dropdown-button[data-tag]").each(function(){
        tags.push($(this).attr("data-tag").trim());
      });
      tags = _.filter(tags, function(t){return !(t === "");});
      publicationList.filter(function(item) {
        var itemtags = _.filter(item.values().tagslugs.split(' '), function(t){return !(t === "");});
        if (tags.length > 0){
          return (_.difference(tags, itemtags).length === 0);
        } else {
          return true;
        }
      });
    }

    updateList();

    //Publication dropdown menus
    $(".dropdown-button").click(function() {
      var $button, $menu;
      $button = $(this);
      $menu = $button.siblings(".dropdown-menu");
      $menu.toggleClass("show-menu");
      $menu.children("li").click(function() {
        $menu.removeClass("show-menu");
        $button.html($(this).html());
        if ($(this)[0].hasAttribute("data-tag")) {
          $button.attr("data-tag", $(this)[0].getAttribute("data-tag"));
          updateList();
        }
      });
    });
  }

  $(document).ready(function() {
    var section = 'none';
    var menuToggle = $('.mobile-menu');
    var wrapper = $('.main-nav');

    $(menuToggle).on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();

      wrapper.toggleClass('open');

      if (wrapper.is('.open')) {
        $(this).addClass('dragonfly-close').removeClass('dragonfly-hamburger');
      } else {
        $(this).addClass('dragonfly-hamburger').removeClass('dragonfly-close');
      }
      // if(wrapper.dataset.mode  === 'open') {
      //   wrapper.dataset.mode = 'closed';
      // } else {
      //   wrapper.dataset.mode = 'open';
      // }
    });

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
