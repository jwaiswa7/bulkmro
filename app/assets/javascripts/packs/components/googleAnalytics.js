// GA ping for pageview
const googleAnalytics = () => {
    if (typeof ga === 'function') {
        ga('set', 'location', event.data.url);
        return ga('send', 'pageview');
    }

    $('.global-search').on('click', function(){
        if (typeof ga === 'function') {
            ga('send', 'event', {
                eventCategory: 'search',
                eventAction: 'click',
                eventLabel: 'Global search'
            });
        }

    })
};

export default googleAnalytics