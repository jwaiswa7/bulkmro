// Attach popper.js Bootstrap tooltips to all tooltip triggers; including dynamically created elements
const alertsAutohide = () => {
    window.setTimeout(function() {
        $('.alert').each(function() {
            let dismiss = $(this).data('dismiss');
            if (dismiss === false) return;

            $(this).fadeTo(500, 0).slideUp(500, function(){
                $(this).alert('close')
            });
        });

    }, 4000);
};

export default alertsAutohide