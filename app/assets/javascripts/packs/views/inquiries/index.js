import statusChange from '../shared/statusChange'

const index = () => {
    let table = $('.datatable').DataTable();
    table.on('xhr', function () {
        let json = table.ajax.json();
        $.each(json.recordsSummary, function (index, summary) {
            let statusSize = summary["size"];
            let statusId = "#status_" + summary["status"]
            $(statusId).find('h5').text(statusSize);
        })
    });

    statusChange(".status_class", '#dropdown_status_column')
};

export default index