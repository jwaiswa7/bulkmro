// GA ping for pageview
const googleAnalytics = () => {
    if (typeof ga === 'function') {
        ga('set', 'location', event.data.url);
        return ga('send', 'pageview');
    }

    $('#global-search').on('click', function(){
        console.log("test")
        if (typeof ga === 'function') {
            return ga('send', 'event', {
                eventCategory: 'global-search',
                eventAction: 'click-search',
                eventLabel: 'Global search'
            });
        }

    })
};

export default googleAnalytics