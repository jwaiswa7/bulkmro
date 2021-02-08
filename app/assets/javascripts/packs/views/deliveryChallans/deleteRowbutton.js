const deleteRow = () => {
    $('.delivery-challan-product-form .status-cross-danger').on('click',function(event){
        event.preventDefault();
        let id = $(this).parent().attr('data-id')
        $("input[member_id="+id+"]").attr('value',1);
        $(this).closest('tr').remove();
    })
};

export default deleteRow