const newAction = () => {
    $('#tax_code_code').on('input',function(){
        //console.log($('#tax_code_chapter').val())
        if($('#tax_code_code').val().length > 0 && $('#tax_code_code').val().length <= 4){
            $('#tax_code_chapter').val($('#tax_code_code').val());
        }
        else if($('#tax_code_code').val().length == 0){
            $('#tax_code_chapter').val("0000")
        }
    })
}

export default newAction