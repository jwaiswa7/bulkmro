const addSuppliers = () => {
    $('.add_supplier_wrapper').hide();

    toggleCheckboxes();

    $('#add_supplier').click((event) => {
        addProductSuppliers();
    });

    // checkProductSuppliers();
    showOrHideDraftRfq();
};

let toggleCheckboxes = () => {
    $('#all_suppliers').prop("checked", false);

    $('#all_suppliers').change((event) => {
        let $element = $(event.target);
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
    let product_ids = [];
    let inquiry_id = $('input[name=inquiry_id]').val();
    product_ids.push($('input[name="product_ids"]').val());
    $('input[type=checkbox][name="suppliers[]"]:checked').each((index, element) => {
        suppliers.push($(element).val());
    });
    if (suppliers.length > 0) {
        let data = { supplier_ids: suppliers, inquiry_product_ids: product_ids };
        $.ajax({
            url: Routes.link_product_suppliers_overseers_inquiry_path(inquiry_id),
            type: "POST",
            data: data,
            success: function () {
                window.location.reload();
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

};

// let checkProductSuppliers = () => {
//     $('input[name="inquiry_product_ids[]"]').change(function () {
//         alert('test')
//         let $this = $(this);
//         let value = $this.is(':checked');
//         let selector = $this.closest('.product_wrapper').find($('input[name="inquiry_product_supplier_ids[]"]'));
//         selector.each(function () {
//             $(this).prop("checked", value);
//         });
//     });
// };

let showOrHideDraftRfq = () => {

    let count = 0;
    $('input[name="inquiry_product_supplier_ids[]"]').change(function () {
        let $this = $(this);
        let value = $this.is(':checked');
        if (value == true) {
            count += 1
        } else {
            count -= 1
        }
    });

};

export default addSuppliers