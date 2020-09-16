const deleteRow = () => {
    $('.delivery-challan-product-form .status-cross-danger').on('click',function(){
        $(this).closest('tr').remove();
    })
};

export default deleteRow