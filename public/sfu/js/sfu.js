/*
    sfu.js
    SFU-specific client-side modifications for Canvas

    SFU require.js modules are located in $CANVAS_ROOT/public/javascripts/sfu-modules

 */


(function($) {

    var utils = {

        onPage: function(regex, fn) {
          if (location.pathname.match(regex)) fn();
        },

        hasAnyRole: function(/*roles, cb*/) {
          var roles = [].slice.call(arguments, 0);
          var cb = roles.pop();
          for (var i = 0; i < arguments.length; i++) {
            if (ENV.current_user_roles.indexOf(arguments[i]) !== -1) {
              return cb(true);
            }
          }
          return cb(false);
        },

        isUser: function(id, cb) {
          cb(ENV.current_user_id == id);
        },

        onElementRendered: function(selector, cb, _attempts) {
          var el = $(selector);
          _attempts = ++_attempts || 1;
          if (el.length) return cb(el);
          if (_attempts == 60) return;
          setTimeout(function() {
            utils.onElementRendered(selector, cb, _attempts);
          }, 250);
        }

    }

    if (!ENV.use_new_styles) {
      // header rainbow
      $('#header').append('<div id="header-rainbow">');

      // help links
      var helpHtml = [
          '<li>',
          '<select class="sfu_help_links">',
          '<option value="">Help</option>',
          '<option value="http://www.sfu.ca/canvas/students.html">Help for Students</option>',
          '<option value="http://www.sfu.ca/canvas/instructors.html">Help for Instructors</option>',
          '<option value="http://www.sfu.ca/techforum">Q&A Forum</option>',
          '</li>'
      ].join('');
      $('#topbar .logout').before(helpHtml);
      $('#topbar .sfu_help_links').on('change', function(ev) {
          if (this.value) {
              window.location = this.value;
          }
      });

      // handle no-user case
      if ($('#header').hasClass('no-user')) {
          // add in a dummy #menu div
          $('#header-inner').append('<div id="menu" style="height:41px"></div>');
          // remove the register link
          $('#header.no-user a[href="/register"]').parent().remove()
      }

      // add Canvas Spaces to nav
      $(document).ready(function() {
        if (!ENV.CANVAS_SPACES_ENABLED) { return; }
        $('#menu').append('<li class="menu-item" id="canvas_spaces_menu_item"><a href="/canvas_spaces" class="menu-item-no-drop">Canvas Spaces</a></li>')
      });

      // Fix for the new conversations page - toolbar renders underneath the rainbow bar
      utils.onPage(/conversations/, function() {
          // are we on the new conversations page?
          if (ENV.CONVERSATIONS && (ENV.CONVERSATIONS.ATTACHMENTS_FOLDER_ID && !ENV.hasOwnProperty('CONTEXT_ACTION_SOURCE'))) {
              jQuery('div#main').css('top', '92px');
          }
      });
    }

    // sfu logo in footer
    $('footer').html('<a href="http://www.sfu.ca/canvas"><img alt="SFU Canvas" src="/sfu/images/sfu-logo.png" width="250" height="38"></a>').show();

    // hijack Start New Course button (CANVAS-192)
    // first, cache the original event handler and disable it
    function hijackStartNewCourseButton() {
        if (!jQuery._data(document, "events")) {
            // bit of a hack for IE which seems to randomly not have the events
            // loaded by the time this script loads
            window.setTimeout(hijackStartNewCourseButton, 100);
        } else {
            var eventlist = jQuery._data( document, "events" ).click,
                targetSelector = '.element_toggler[aria-controls]',
                origHandler, e;
            // cache the handler
            for (var i = 0; i < eventlist.length; i++) {
                e = eventlist[i];
                if (e.selector === targetSelector) {
                    origHandler = e.handler;
                }
            }
            if (origHandler) {
                // remove the handler, and add our own
                $(document).off('click change', targetSelector).on('click change', targetSelector, function(event) {
                    if (this.id === 'start_new_course') {
                        event.stopImmediatePropagation();
                        window.location = '/sfu/course/new';
                    } else {
                        origHandler.call(this, event);
                    }
                });
            }
        }
    }
    $(document).ready(function() {
        hijackStartNewCourseButton();
    });

    // END CANVAS-192

    /*  Add copyright compliance notice to the publish course button
        When a course page loads, check to see if the course is unpublished.
        If so, first immediately disable the publish button to allow time for the bundle to be required async.
        Then load the CANVAS_ROOT/public/javascripts/sfu-modules/copyright_notice_modal_dialog bundle
        This bundle handles attaching a click handler to the submit button (and re-enabling it).
        The click handler renders the SFUCopyrightComplianceNoticeModalDialog react component.

        If the course is published, nothing happens.
    */
    utils.onPage(/^\/courses\/\d+$/, function() {
        var $publishButton = $('.btn-publish')
        if ($publishButton.length) {
            $publishButton.attr('disabled', true);
            require(['sfu-modules/copyright_notice_modal_dialog'], function(module) {
                module.attachClickHandlerTo(location.pathname.replace('/courses/', 'edit_course_'));
            });
        }
    });

    /*  Add PIA notice to Google Docs section on /courses/DDDDD/collaborations
        When the collaboration page loads, load the google_docs_pia_notice bundle
        In the bundle, check the current user's role within the current course and
        display the appropriate message.
    */
    utils.onPage(/^\/courses\/\d+\/collaborations\/?$/, function () {
        require(['sfu-modules/google_docs_pia_notice'], function(module) {
            module.showGoogleDocsWarning();
        });
    });

    utils.onPage(/^\/profile\/settings\/?$/, function () {
        $(document).ready(function () {
            var $fieldsToLock = $('.full_name.display_data, .sortable_name.display_data');
            var $helpText = $('.short_name').siblings('span.edit_or_show_data');

            // CANVAS-253 Temporarily make full/sortable names read-only
            $fieldsToLock.removeClass('display_data').addClass('edit_or_show_data');
            $fieldsToLock.siblings('input').remove();

            // CANVAS-254 Add verbiage about Display Name
            $helpText.append('<br />Changing this will only affect your display name within Canvas, ' +
                'and not in other systems (e.g. <a href="https://go.sfu.ca" target="_blank">goSFU</a>, ' +
                '<a href="https://myinfo.sfu.ca" target="_blank">myInfo</a>, etc.)');

            // CANVAS-259 Hide email subscription checkbox
            $('#update_profile_form').find('label[for="user_subscribe_to_emails"]').parents('tr').hide();
        });
    });

    // CANVAS-259 Hide email subscription checkbox
    utils.onPage(/^\/register\/\w+/, function () {
        $(document).ready(function () {
            $('#registration_confirmation_form').find('label[for="user_subscribe_to_emails"]').parents('.control-group').hide();
        });
    });
    // END CANVAS-259

    // Setup Backbone event handler that will be called when all the content DOM elements
    // have been rendered. This will activate the accordion and tab components on the page.
    function setupAccordionAndTabActivation() {
        $.subscribe('userContent/change', function () {
            $("div.accordion").accordion({header: "h3"});
            $(".sfu-tabs").tabs();
        });
    }

    // On course and wiki pages, activate accordion and tab components, if they exist.
    utils.onPage(/^\/(courses|groups)\/\d+\/pages\/[A-Za-z0-9_\-+~<>]+$/, setupAccordionAndTabActivation);

    // A page designated as a front page has a different url.
    utils.onPage(/^\/(courses|groups)\/\d+\/wiki$/, setupAccordionAndTabActivation);

})(jQuery);

// google analytics
if (window.location.hostname && 'canvas.sfu.ca' === window.location.hostname) {
    var _gaq = _gaq || [];
    _gaq.push(['_setAccount', 'UA-36473171-1']);
    _gaq.push(['_trackPageview']);

    (function() {
        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        ga.src = ('https:' === document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();
}
