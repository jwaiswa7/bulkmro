import validatePoRequestAddresses from "./validatePoRequestAddresses"
import updateOnContactSelect from "./updateOnContactSelect";
import updateRowTotal from "./updateRowTotal"
import massLeadDateUpdate from "./massLeadDateUpdate"
import openRatingModal from "../common/openRatingModal";
import validateLeadDate from "./validateLeadDate";

const edit = () => {
    openRatingModal()
    let form_original_data = $("form").serializeArray();

    let required_fields = $('form').find("select, textarea, input").filter('[required]:visible');
    $('form').on('change', 'select[name*=status]', function (e) {
        if ($(e.target).val() == "Cancelled") {
            $('.status-cancelled').removeClass('d-none');
            $('.status-cancelled').find('textarea').attr("required", true);
            required_fields.each(function (i, requiredField) {
                $(requiredField).removeAttr('required');
                let described_by = $(requiredField).data('parsley-id');
                $('div#parsley-id-' + described_by).text('');
            });
        } else if ($(e.target).val() == "Supplier PO Request Rejected") {
            $('.status-rejected').removeClass('d-none');
            $('.status-rejected').find('select').attr("required", true);
        }
        if ($(e.target).val() != "Cancelled") {
            $('.status-cancelled').addClass('d-none');
            $('.status-cancelled').find('textarea').val('').attr("required", false);
            required_fields.each(function (i, requiredField) {
                $(requiredField).attr('required', true);
            });
        }
        if ($(e.target).val() != "Supplier PO Request Rejected") {
            $('.status-rejected').addClass('d-none');
            $('.status-rejected').find('select').val('').attr("required", false);
        }
    });
    $('form').on('change', 'select[name*=stock_status]', function (e) {
        if ($(e.target).val() == "Stock Rejected") {
            $('.status-rejected').removeClass('d-none');
            $('.status-rejected').find('select').attr("required", true);
        }
        if ($(e.target).val() != "Stock Rejected") {
            $('.status-rejected').addClass('d-none');
            $('.status-rejected').find('select').val('').attr("required", false);
        }
    });

    $('form').on('change', 'select[name*=rejection_reason]', function (e) {
        if ($(e.target).val() == "Others") {
            $('.other-rejection-reason').removeClass('d-none');
            $('.other-rejection-reason').find('textarea').attr("required", true);
        } else {
            $('.other-rejection-reason').addClass('d-none');
            $('.other-rejection-reason').find('textarea').val('').attr("required", false);
        }
    });

    window.Parsley.on('field:error', function () {
        // This global callback will be called for any field
        //  that fails validation.
        console.log('Validation failed for: ',
            this.$element.attr('name'));
    });
    $('select[name*=status]').trigger('change');
    $('select[name*=stock_status]').trigger('change');

    validatePoRequestAddresses();
    updateRowTotal();
    updateOnContactSelect();
    validateLeadDate();
    massLeadDateUpdate();

    $('form').on('click', '.add-review', function (e) {
        $('.rating-modal a').click();
    })

    $('.confirm-cancel').click(function (event) {
        if (changed_status[0]['value'] == 'Cancelled') {
            if (!confirm('Do you want to cancel the Po Request?')) {
                event.preventDefault();
            } else {
                if (!confirm('Do you want to reject the Po Request?')) {
                    event.preventDefault();
                }
            }
        }
    });

    $('.submit-form').unbind().bind('click', function (event) {
        let form_changed_data = $("form").serializeArray();
        let changed_status = form_changed_data.filter(x => x.name === "po_request[status]");
        let original_status = form_original_data.filter(x => x.name === "po_request[status]");
        if (changed_status) {
            let is_cancel_status = changed_status[0]['value'].toLowerCase().indexOf('cancel') != -1 || changed_status[0]['value'].toLowerCase().indexOf('reject') != -1
            if (is_cancel_status && original_status && (changed_status[0]['value'] != original_status[0]['value'])) {
                if (changed_status[0]['value'] == 'Cancelled') {
                    if (!confirm('Do you want to cancel the Po Request?')) {
                        event.preventDefault();
                    }
                } else if ((changed_status[0]['value'] == 'Supplier PO Request Rejected')) {
                    if (!confirm('Do you want to reject the Po Request?')) {
                        event.preventDefault();
                    }
                }
            }
        }
    });
};

export default edit