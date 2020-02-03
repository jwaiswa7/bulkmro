import bindStatusChange from './bindStatusChange'
import cancelStatusConfirmation from './canceStatusConfirmation'
import hideRemoveBtnInRows from "../common/hideRemoveBtnInRows"
import newAction from "./new";


const edit = () => {
    bindStatusChange()
    cancelStatusConfirmation()
    hideRemoveBtnInRows()
    newAction()

    $('[name="ar_invoice_request[e_way]"]').unbind().bind('change', function () {
        if ($(this). prop("checked") == true)
            $('.download-eway').removeClass('d-none')

        else
            $('.download-eway').addClass('d-none')
    })
}



export default edit