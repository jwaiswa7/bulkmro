import updateRowTotal from "../salesOrders/updateRowTotal"

const edit = () => {
    $('form').on('change','select[name*=status]',function(e){
        if($(e.target).val() == "Cancelled"){
            $('.status-cancelled').removeClass('d-none');
            $('.status-cancelled').find('textarea').attr("required",true);
        }
        else if($(e.target).val() == "Rejected"){
            $('.status-rejected').removeClass('d-none');
            $('.status-rejected').find('select').attr("required",true);
        }
        if($(e.target).val() != "Cancelled"){
            $('.status-cancelled').addClass('d-none');
            $('.status-cancelled').find('textarea').val('');
        }
        if($(e.target).val() != "Rejected"){
            $('.status-rejected').addClass('d-none');
            $('.status-rejected').find('select').val('');
        }
    });
    $('select[name*=status]').trigger('change');

    updateRowTotal();
};

export default edit