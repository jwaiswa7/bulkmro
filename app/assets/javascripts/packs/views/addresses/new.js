const newAction = () => {
    getGSTfromAddress(false);

    $("#address_address_state_id").on('change',function(){
        getGSTfromAddress(true);
    })

    if ($('#address_gst').val() != ''){
        var full_gst_code = $('#address_gst').val()
        console.log('full_gst_cd.length'+full_gst_code.length)
        var gst_cd1 = full_gst_code.substring(0, 2);
        $('#gst_code_1').val(gst_cd1);
        if (full_gst_code.length == 15)
        {
            var gst_cd2 = full_gst_code.substring(2, 12);
            var gst_cd3 = full_gst_code.substring(12, 13);
            var gst_cd4 = full_gst_code.substring(13, 14);
            var gst_cd5 = full_gst_code.substring(14, 15);
            $('#gst_code_1').val(gst_cd1)
            $('#gst_code_2').val(gst_cd2)
            $('#gst_code_3').val(gst_cd3)
            $('#gst_code_4').val(gst_cd4)
            $('#gst_code_5').val(gst_cd5)
        }else{
            $('#gst_code_2,#gst_code_3,#gst_code_4,#gst_code_5').val('')
        }

    }

    $('.gst-change').on('input', function() {
        var full_gst_cd = $('#gst_code_1').val()+$('#gst_code_2').val()+$('#gst_code_3').val()+$('#gst_code_4').val()+$('#gst_code_5').val()
        $('#address_gst').val(full_gst_cd);
    });
}



let getGSTfromAddress = (isOnChange) => {
    var state_id = $("#address_address_state_id").val();
    $.ajax({
        url: Routes.get_gst_code_overseers_addresses_path(),
        data: { state_id: state_id },
        contentType: "application/json; charset=utf-8",
        dataType: "json",

        success: function (data) {
            $('#gst_code_1').val(data.gst_code)
            if (isOnChange){
                $('#address_gst').val('');
            }
        }
    });
}

export default newAction