

const show = () => {
    window.scrollTo(0, 1000);
    let table = $('.datatable.review-table').DataTable();

    table.on( 'draw.dt', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};
        $.each(json.companyRating, function (index, ratings) {
            let star_id = "[data-id="+ ratings['id'] + "]";
            $(star_id).raty({'readOnly': true , 'score': ratings['rating'] , 'precision': true, 'hints': ['bad','poor','average','good','best']})
        });
    } );

}

// select optionn len
  $(".select-optionn-len").select2()
// select optionn len

export default show;