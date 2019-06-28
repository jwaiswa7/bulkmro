
const index = () => {
    $('body').on('shown.bs.modal', '#myModal', function (e) {
        let invoice_id = $(e.relatedTarget).data('entity-id');
        $('#invoice_id').val(invoice_id);
    });

    // let options = {
    //     "sScrollX": "100%",
    //     "sScrollXInner": "110%",
    //     "bScrollCollapse": true,
    //     "colReorder": true
    // };
    //
    // $(document).ready(function() {
    //     $('datatable').dataTable(options);
    // });
};

export default index