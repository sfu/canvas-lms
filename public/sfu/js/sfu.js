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

    // add Canvas Spaces to nav
    $(document).ready(function() {
      if (!ENV.CANVAS_SPACES_ENABLED) { return; }
      var menuitem = '<li class="menu-item ic-app-header__menu-list-item"><a id="global_nav_canvas_spaces_link" href="/canvas_spaces" class="ic-app-header__menu-list-link"><div class="menu-item-icon-container" aria-hidden="true"><svg class="ic-icon-svg ic-icon-svg--canvas-spaces" height="35px" viewBox="0 0 235 249" version="1.1" xmlns="http://www.w3.org/2000/svg"><desc>stars by retinaicon from the Noun Project</desc><path d="M87.221,43.11 C87.221,40.068 85.191,38.037 82.148,38.037 C63.889,38.037 49.18,23.329 49.18,5.073 C49.18,2.027 47.153,0 44.11,0 C41.068,0 39.037,2.027 39.037,5.073 C39.037,23.329 24.329,38.037 6.072,38.037 C3.027,38.037 0.999,40.067 0.999,43.11 C0.999,46.153 3.026,48.18 6.072,48.18 C24.328,48.18 39.037,62.889 39.037,81.148 C39.037,84.19 41.067,86.221 44.11,86.221 C47.153,86.221 49.18,84.191 49.18,81.148 C49.18,62.889 63.889,48.18 82.148,48.18 C85.191,48.181 87.221,46.153 87.221,43.11 L87.221,43.11 Z M44.11,60.862 C40.052,53.254 33.967,47.169 26.359,43.111 C33.967,39.053 40.052,32.968 44.11,25.36 C48.168,32.968 54.254,39.053 61.861,43.111 C54.254,47.168 48.168,53.254 44.11,60.862 L44.11,60.862 Z M153.156,174.978 C134.894,174.978 120.186,160.27 120.186,142.01 C120.186,138.968 118.158,136.938 115.116,136.938 C112.074,136.938 110.043,138.968 110.043,142.01 C110.043,160.27 95.334,174.978 77.078,174.978 C74.032,174.978 72.005,177.005 72.005,180.048 C72.005,183.091 74.032,185.121 77.078,185.121 C95.334,185.121 110.043,199.83 110.043,218.088 C110.043,221.131 112.073,223.158 115.116,223.158 C118.159,223.158 120.186,221.131 120.186,218.088 C120.186,199.83 134.894,185.121 153.156,185.121 C156.196,185.121 158.226,183.091 158.226,180.048 C158.226,177.005 156.196,174.978 153.156,174.978 L153.156,174.978 Z M115.116,197.799 C111.058,190.192 104.973,184.106 97.365,180.048 C104.973,175.99 111.058,169.904 115.116,162.297 C119.174,169.904 125.259,175.99 132.865,180.048 C125.259,184.105 119.174,190.191 115.116,197.799 L115.116,197.799 Z M229.231,215.551 C219.595,215.551 211.48,207.438 211.48,197.799 C211.48,194.757 209.45,192.729 206.41,192.729 C203.364,192.729 201.334,194.757 201.334,197.799 C201.334,207.438 193.219,215.551 183.583,215.551 C180.543,215.551 178.513,217.581 178.513,220.623 C178.513,223.666 180.543,225.693 183.583,225.693 C193.219,225.693 201.334,233.809 201.334,243.445 C201.334,246.49 203.364,248.517 206.41,248.517 C209.45,248.517 211.48,246.49 211.48,243.445 C211.48,233.809 219.595,225.693 229.231,225.693 C232.271,225.693 234.301,223.666 234.301,220.623 C234.302,217.581 232.271,215.551 229.231,215.551 L229.231,215.551 Z M206.41,227.217 C204.38,224.682 202.349,222.144 199.814,220.623 C202.349,218.594 204.884,216.565 206.41,214.03 C208.434,216.565 210.465,219.1 213,220.623 C210.465,222.651 208.435,224.682 206.41,227.217 L206.41,227.217 Z M158.227,86.221 L155.181,86.221 L157.211,84.191 C159.241,82.164 159.241,79.121 157.211,77.09 C155.181,75.063 152.141,75.063 150.111,77.09 L148.08,79.12 L148.08,76.078 C148.08,73.033 146.056,71.005 143.01,71.005 C139.965,71.005 137.94,73.033 137.94,76.078 L137.94,79.12 L135.911,77.09 C133.88,75.063 130.841,75.063 128.809,77.09 C126.78,79.12 126.78,82.163 128.809,84.191 L130.84,86.221 L127.794,86.221 C124.754,86.221 122.724,88.249 122.724,91.291 C122.724,94.333 124.754,96.364 127.794,96.364 L130.84,96.364 L128.809,98.392 C126.78,100.422 126.78,103.465 128.809,105.493 C129.825,106.508 131.344,107.015 132.36,107.015 C133.376,107.015 134.895,106.508 135.911,105.493 L137.94,103.465 L137.94,106.508 C137.94,109.55 139.965,111.581 143.01,111.581 C146.056,111.581 148.08,109.551 148.08,106.508 L148.08,103.465 L150.111,105.493 C151.126,106.508 152.645,107.015 153.661,107.015 C154.676,107.015 156.196,106.508 157.211,105.493 C159.241,103.465 159.241,100.423 157.211,98.392 L155.181,96.364 L158.227,96.364 C161.267,96.364 163.297,94.334 163.297,91.291 C163.297,88.248 161.267,86.221 158.227,86.221 L158.227,86.221 L158.227,86.221 Z M36.502,187.656 L31.429,187.656 L31.429,182.586 C31.429,179.54 29.401,177.513 26.359,177.513 C23.316,177.513 21.286,179.54 21.286,182.586 L21.286,187.656 L16.216,187.656 C13.174,187.656 11.143,189.686 11.143,192.728 C11.143,195.771 13.173,197.798 16.216,197.798 L21.286,197.798 L21.286,202.871 C21.286,205.914 23.316,207.941 26.359,207.941 C29.401,207.941 31.429,205.406 31.429,202.871 L31.429,197.798 L36.502,197.798 C39.544,197.798 41.575,195.771 41.575,192.728 C41.575,189.687 39.545,187.656 36.502,187.656 L36.502,187.656 Z M183.078,25.867 C184.094,26.879 185.613,27.387 186.629,27.387 C187.644,27.387 189.164,26.88 190.179,25.867 L193.729,22.316 L197.28,25.867 C198.296,26.879 199.815,27.387 200.831,27.387 C201.846,27.387 203.365,26.88 204.381,25.867 C206.411,23.837 206.411,20.794 204.381,18.766 L200.831,15.216 L204.381,11.666 C206.411,9.636 206.411,6.593 204.381,4.565 C202.351,2.535 199.311,2.535 197.28,4.565 L193.729,8.115 L190.179,4.565 C188.149,2.535 185.109,2.535 183.078,4.565 C181.048,6.592 181.048,9.635 183.078,11.666 L186.629,15.216 L183.078,18.766 C181.048,20.794 181.048,23.837 183.078,25.867 L183.078,25.867 Z" id="Shape"></path></svg><span class="menu-item__badge" style="display: none">0</span></div><div class="menu-item__text">Canvas Spaces</div></a></li>';
      $(menuitem).insertAfter($('#menu>li').last());
    });

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
