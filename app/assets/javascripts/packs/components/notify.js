// Attach popper.js Bootstrap tooltips to all tooltip triggers; including dynamically created elements
const notify = () => {
    $.notifyDefaults({
        type: 'warning',
        delay: 2500,
        allow_dismiss: true,
        animate: {
            // exit: 'animated fadeOutUp'
        },
        placement: {
          from: 'bottom',
          align: 'left',
        },
        offset: 0,
        position: 'fixed',

        onShow: function() {
            this.css({'width': '100%', bottom: 0});
        },
    });
};

export default notify