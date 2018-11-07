// NOW TIMER
// -----------------------------------

(function(window, document, $, undefined) {
    'use strict';

    $(initNowTimer);

    function initNowTimer() {

        $('[data-now]').each(function() {
            var element = $(this),
                format = element.data('format');

            function updateTime() {
                var dt = moment(new Date()).format(format);
                element.text(dt);
            }

            updateTime();
            setInterval(updateTime, 1000);

        });
    }

})(window, document, window.jQuery);