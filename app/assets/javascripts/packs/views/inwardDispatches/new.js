import disableBackdateOption from './../common/disableBackdateOption'
import massSupplierDeliveryDateUpdate from "./massSupplierDeliveryDateUpdate"

const newAction = () => {
    $('.delete_row').on('click', function (event) {
        $(event.target).closest('.simple-row').find('input[type="text"]').remove();
    })

    disableBackdateOption( $('.expected-dispatch-date'));
    disableBackdateOption( $('.expected-delivery-date'));
    disableBackdateOption( $('.actual-delivery-date'));

    massSupplierDeliveryDateUpdate();
};

export default newAction