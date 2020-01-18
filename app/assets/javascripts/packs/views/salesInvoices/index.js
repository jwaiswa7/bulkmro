import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import exportFilteredRecords from '../common/exportFilteredRecords'
import removeHrefExport from '../common/removeHrefExport';


const index = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    let controller = camelize($('body').data().controller);
    exportFilteredRecords(Routes.export_filtered_records_overseers_sales_invoices_path(), 'Email sent with Filtered ' + controller.titleize() + '!')
    removeHrefExport();
    $('.sales-invoice-summary-box').click(function(){
    	var parentDiv = $(this).parent()
    	if($(parentDiv).hasClass('bmro-parent-bg')){
    		$(parentDiv).removeClass('bmro-parent-bg bmro-collaps2-bg')
    	} else {
    		$(parentDiv).addClass('bmro-parent-bg bmro-collaps2-bg')
    	} 
    	var collapseShowDiv = $('.collapse.show')
    	if($(collapseShowDiv).length > 0){
    		$.each(collapseShowDiv, function(index, value){
    			$(value).removeClass('show')
    		})
    	} 
    });
};

export default index