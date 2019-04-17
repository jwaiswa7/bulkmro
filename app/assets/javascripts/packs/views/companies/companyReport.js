const companyReport = () => {
    var dataTable = $('.datatable').dataTable();
    dataTable.api().page.len(-1).draw()
    dataTable.on('draw.dt', function () {
        $('.dataTables_paginate').hide()
    })
}

export default companyReport