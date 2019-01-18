const productsSupplierRating = () => {
    $.each($('.datatable>tbody>tr>td>div.product_supplier_ratings'),function(){
        $(this).raty({'readOnly': true , 'score': $(this).attr('data-ratings') , 'precision': true, 'hints': ['bad','poor','average','good','best']})
    })
}

export default productsSupplierRating