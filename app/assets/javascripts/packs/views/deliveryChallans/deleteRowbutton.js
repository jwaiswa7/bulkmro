const deleteRow = () => {
    $('.delivery-challan-product-form .status-cross-danger').on('click',function(event){
        event.preventDefault();
        $(this).closest('tr').remove();
    })
};

export default deleteRow