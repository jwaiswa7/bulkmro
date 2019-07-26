import onStatusChange from './bindStatusChange'
import cancelStatusConfirmation from './canceStatusConfirmation'
import hideRemoveBtnInRows from "../common/hideRemoveBtnInRows"


const newAction = () => {
    $('.simple_form').on('click','.delete_row',function (event) {
        event.preventDefault($(this).closest('.nested_ar_invoice_request_rows'));
        $(this).closest('.nested_ar_invoice_request_rows').empty();
    })
    onStatusChange()
    cancelStatusConfirmation()
    hideRemoveBtnInRows()
};


export default newAction