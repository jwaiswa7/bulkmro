const addSuppliers = () => {
    $('.add_supplier_wrapper').hide();
    toggleCheckboxes();

    $('#add_supplier').click((event) => {
        addProductSuppliers();
    });
};

let toggleCheckboxes = () => {
    $('#add_suppliers').prop("checked", false);

    $('#add_suppliers').change((event) => {
        var $element = $(event.target)
        if ($element.is(':checked')) {
            $('input[type=checkbox][name="suppliers[]"]').each((index, element) => {
                $(element).prop("checked", true);
                showOrHideActions();
            });
        } else {
            $('input[type=checkbox][name="suppliers[]"]').each((index, element) => {
                $(element).prop("checked", false);
                showOrHideActions();
            });
        }
    });

    $('table').on('change', 'input[type=checkbox][name="suppliers[]"]', (event) => {
        showOrHideActions();
    })
}

let addProductSuppliers = () => {
    let suppliers = [];
    $('input[type=checkbox][name="suppliers[]"]:checked').each((index, element) => {
        suppliers.push($(element).val());
    });


    if (suppliers.length > 0 ) {

        var data = JSON.stringify({suppliers: suppliers});
        $.ajax({
            url: Routes.add_suppliers_overseers_inquiries_path(),
            type: "POST",
            data: data,
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function () {
                var dataTable = $('.datatable').dataTable();
                dataTable.api().ajax.reload(null, false);
                $('#add_suppliers').removeAttr('checked');
                $('#add_suppliers').prop("checked", false);
                $.notify({
                    message: 'Suppliers added successfully'
                }, {
                    type: 'success'
                });
            }
        });
    }
};

let showOrHideActions = () => {
    let hide = true;

    if ($('input[type=checkbox][name="suppliers[]"]:checked').length > 0) {
        $('.add_supplier_wrapper').show();
    } else {
        $('.add_supplier_wrapper').hide();
    }

}

export default addSuppliers