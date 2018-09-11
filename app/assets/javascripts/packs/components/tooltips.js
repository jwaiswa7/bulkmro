// Attach popper.js Bootstrap tooltips to all tooltip triggers; including dynamically created elements
const tooltips = () => {
    $('body').tooltip({
        selector: '[data-toggle="tooltip"]'
    });
};

export default tooltips