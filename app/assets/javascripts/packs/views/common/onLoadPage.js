const onLoadPage = () => {
    let table = $('.datatable').DataTable();
    table.on( 'draw.dt', function () {
        let json = table.ajax.json() ? table.ajax.json() : {};

        $.each(json.companyRating, function (index, company) {

            $("div.star").raty({'readOnly': true , 'score': company , 'precision': true})
        });
    } );
}
export default onLoadPage