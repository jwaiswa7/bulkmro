// Attach popper.js Bootstrap tooltips to all tooltip triggers; including dynamically created elements
const alertsAutohide = () => {
    window.setTimeout(function() {
        $(".alert").fadeTo(500, 0).slideUp(500, function(){
            $(this).alert('close')
        });

    }, 4000);
};

export default alertsAutohide