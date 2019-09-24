import updateSummaryBox from "../common/updateSummaryBox";
import updateLogisticsOwner from "./updateLogisticsOwner"

const materialReadinessQueue = () => {
    bindSummaryBox(".summary_box");
    updateSummaryBox();
    // aggregateSummaryBox();
    updateLogisticsOwner();
};

let bindSummaryBox = (classname) => {
    $(classname).on('click', function (e) {
        // let value = $(this).data('value'); .toLowerCase()
        var keyup_event = $.Event("keyup");
        let value = $(this).find('p')[0].innerText;
        let inputField = $('.filter-list-input');

        inputField.val(value).trigger(keyup_event);
        e.preventDefault();
        return false;
    });
};

var stickyEl = document.querySelector('.bmro-datatable-style')
var stickyPosition = stickyEl.getBoundingClientRect().top;
var offset = -20
window.addEventListener('scroll', function() {
    if (window.pageYOffset >= stickyPosition + offset) {
        // stickyEl.style.position = 'fixed';
        // stickyEl.style.top = '0px';
        stickyEl.addClass('bmro-datatable-style-position');
    } else {
        // stickyEl.style.position = 'static';
        // stickyEl.style.top = '';
        yourNavigation.removeClass('bmro-datatable-style-position');
    }
});


let aggregateSummaryBox = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $('.overall-status-count').html(new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusCount));
        $('.overall-status-value').html("&#8377;" + new Intl.NumberFormat('en-IN').format(json.recordsOverallStatusValue));
    });
};

export default materialReadinessQueue