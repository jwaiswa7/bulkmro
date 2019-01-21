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
        else{
            $('.status-cancelled').addClass('d-none');
            $('.status-rejected').addClass('d-none');
            $('.status-cancelled').find('textarea').val('');
            $('.status-rejected').find('select').val('');
        }
    });
};

export default edit