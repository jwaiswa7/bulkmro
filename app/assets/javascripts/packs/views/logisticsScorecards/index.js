
const index = () => {
    $('body').on('shown.bs.modal', '#myModal', function (e) {
        let invoice_id = $(e.relatedTarget).data('entity-id');
        $('#invoice_id').val(invoice_id);
    });
};

export default index