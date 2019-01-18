const onLoadPage = () => {
    let table = $('.datatable').DataTable();
    table.on( 'draw.dt', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        // for(var i = 0; i < json['data'].length; i++) {
        //     $("div.star").raty({'readOnly': true , 'score': 4 , 'precision': true, 'hints': ['bad','poor','average','good','best']})
        // }

        // $("div.star").raty({'readOnly': true , 'score': 4 , 'precision': true, 'hints': ['bad','poor','average','good','best']})

        $.each(json.companyRating, function (index, ratings) {
            let star_id = "[data-id="+ ratings['id'] + "]";
            $(star_id).raty({'readOnly': true , 'score': ratings['rating'] , 'precision': true, 'hints': ['bad','poor','average','good','best']})
        });
    } );
}
export default onLoadPage