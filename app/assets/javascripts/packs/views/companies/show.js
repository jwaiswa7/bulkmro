

const show = () => {
    let table = $('.datatable.review-table').DataTable();

    table.on( 'draw.dt', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $.each(json.companyRating, function (index, ratings) {
            let star_id = "[data-id="+ ratings['id'] + "]";
            $(star_id).raty({'readOnly': true , 'score': ratings['rating'] , 'precision': true, 'hints': ['bad','poor','average','good','best']})
        });
    } );

}

export default show;