import bindSummaryBox from '../common/bindSummaryBox'


const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')

    $('body').on('shown.bs.modal', '#myModal', function (e) {
        let invoice_id = $(e.relatedTarget).data('entity-id');
        $('#invoice_id').val(invoice_id);
    });


    $('.bmro-over-scor').click(function(){
      // $('#pod-summary').toggleClass('bmrocol-openclose');
      // $('.logisowner').addClass('bmrocol-openclose');
      $('.logiscoll').removeClass('bmro-collaps2-bg');
      $('.logiscoll').removeClass('bmro-parent-bg');
    });


    $('.bmro-log-scor').click(function(){
      // $('#ownerwise-summary').toggleClass('bmrocol-openclose');
      // $('.overallscore').addClass('bmrocol-openclose');
      $('.bmor-minwidthset').removeClass('bmro-collaps2-bg');
      $('.bmor-minwidthset').removeClass('bmro-parent-bg');
    }); 
    // let options = {
    //     "sScrollX": "100%",
    //     "sScrollXInner": "110%",
    //     "bScrollCollapse": true,
    //     "colReorder": true
    // };
    //
    // $(document).ready(function() {
    //     $('datatable').dataTable(options);
    // });
};

export default index