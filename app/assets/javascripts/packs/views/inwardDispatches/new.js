import disableBackdateOption from './../common/disableBackdateOption'
import massSupplierDeliveryDateUpdate from "./massSupplierDeliveryDateUpdate"

const newAction = () => {
    $('.simple_form').on('click','.delete_row',function (event) {
        event.preventDefault();
        $(this).closest('.inward-dispatch-row').empty();
    })

    disableBackdateOption( $('.expected-dispatch-date'));
    disableBackdateOption( $('.expected-delivery-date'));
    disableBackdateOption( $('.actual-delivery-date'));

    massSupplierDeliveryDateUpdate();
};

export default newAction