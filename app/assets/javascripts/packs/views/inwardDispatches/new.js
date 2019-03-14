import disableBackdateOption from './../common/disableBackdateOption'

const newAction = () => {
    $('.delete_row').on('click', function (event) {
        $(event.target).closest('.simple-row').find('input[type="text"]').remove();
    })

    if ($('#inward_dispatch_inward_dispatch_logistics_partner').val() == "Others") {
        $('.inward_dispatch_inward_dispatch_other_logistics_partner').show();
    }else{
        $('.inward_dispatch_inward_dispatch_other_logistics_partner').hide();
    }

    disableBackdateOption( $('.expected-dispatch-date'));
    disableBackdateOption( $('.expected-delivery-date'));
    disableBackdateOption( $('.actual-delivery-date'));

    $('#inward_dispatch_inward_dispatch_logistics_partner').on('change', function (event) {
        if (event.target.value == "Others") {
            $('.inward_dispatch_inward_dispatch_other_logistics_partner').show();
        }else{
            $('.inward_dispatch_inward_dispatch_other_logistics_partner').hide();
        }
    })

};

export default newAction