const onLoadPage = () => {
    let table = $('.datatable').DataTable();
    table.on( 'draw.dt', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        // for(var i = 0; i < json['data'].length; i++) {
        //     $("div.star").raty({'readOnly': true , 'score': 4 , 'precision': true, 'hints': ['bad','poor','average','good','best']})
        // }

        // $("div.star").raty({'readOnly': true , 'score': 4 , 'precision': true, 'hints': ['bad','poor','average','good','best']})

        $.each(json.companyRating, function (index, company) {
            console.log(company)
            $("div.star").raty({'readOnly': true , 'score': company , 'precision': true, 'hints': ['bad','poor','average','good','best']})
        });
    } );
}
export default onLoadPage