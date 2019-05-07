// GA ping for pageview
const googleAnalytics = () => {
    if (typeof ga === 'function') {
        ga('set', 'location', event.data.url);
        return ga('send', 'pageview');
    }
};

export default googleAnalytics