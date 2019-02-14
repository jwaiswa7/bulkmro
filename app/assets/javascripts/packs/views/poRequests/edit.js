import bindRatingModalTabClick from "../common/bindRatingModalTabClick"
import updateRatingForm from "../common/updateRatingForm"
import validatePoRequestAddresses from "./validatePoRequestAddresses"
import updateOnContactSelect from "./updateOnContactSelect";
import updateRowTotal from "./updateRowTotal"


const edit = () => {

    bindRatingModalTabClick();
    $('.rating-modal a').click();
    updateRatingForm();

    $('form').on('change', 'select[name*=status]', function (e) {
        if ($(e.target).val() == "Cancelled") {
            $('.status-cancelled').removeClass('d-none');
            $('.status-cancelled').find('textarea').attr("required", true);
        } else if ($(e.target).val() == "Rejected") {
            $('.status-rejected').removeClass('d-none');
            $('.status-rejected').find('select').attr("required", true);
        }
        if ($(e.target).val() != "Cancelled") {
            $('.status-cancelled').addClass('d-none');
            $('.status-cancelled').find('textarea').val('').attr("required", false);
        }
        if ($(e.target).val() != "Rejected") {
            $('.status-rejected').addClass('d-none');
            $('.status-rejected').find('select').val('').attr("required", false);
        }
    });
    window.Parsley.on('field:error', function () {
        // This global callback will be called for any field
        //  that fails validation.
        console.log('Validation failed for: ',
            this.$element.attr('name'));
    });
    $('select[name*=status]').trigger('change');
    validatePoRequestAddresses();
    updateRowTotal();
    updateOnContactSelect();

};

export default edit