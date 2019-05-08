import bindStatusChange from './bindStatusChange'

const edit = () => {
    bindStatusChange()
    cancelStatusConfirmation()

    $('[name="ar_invoice_request[e_way]"]').unbind().bind('change', function () {
        if ($(this). prop("checked") == true)
            $('.download-eway').removeClass('d-none')

        else
            $('.download-eway').addClass('d-none')
    })
}

export default edit