const onLoadPage = () => {
    /*$(document).ready(function() {
        $(window).on('load', (function () {
            $('div.star').raty({'readOnly': false , 'score': 3.5 , 'precision': true});
        }));

    });
    $('.paginate_button').click(function(){
        $('div.star').raty();
        console.log('Hello');
    });*/
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $.each([1,2,3], function (index) {
            $("div.star").raty({'readOnly': false , 'score': 3.5 , 'precision': true});
            console.log($("div.star"));
        })

    });
}
export default onLoadPage