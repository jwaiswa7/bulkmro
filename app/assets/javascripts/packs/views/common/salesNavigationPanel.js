import getInquiryTasks from "./getInquiryTasks";
import getStatusRecords from "./getStatusRecords";

const salesNavigationPanel=function(){

        $(".bmro-sales-actions").each((i,element)=> {
            let viewId=element.id;
            if(element.classList.contains('activeDashboardView'))
            {
                tabActivator(viewId);
            }
            else
            {
                tabActivator('actionDashboard')
            }
        });
    function tabActivator(id) {
        $(".bmro-sales-actions").each((i,element) => {
            let viewId=element.id;
            if (viewId === id) {
                $(`#${viewId}`).addClass('activeDashboardView')
                dashboardViewer(id);
            } else {
                $(`#${viewId}`).removeClass('activeDashboardView')
            }
        })
    }
    function dashboardViewer(viewId){
        if( viewId ==='actionDashboard'){ 
            $('#actionDashboardViewer').show();
            $('#performanceDashboardViewer').hide();
            $('#myTeamViewer').hide();
        }
        else if(viewId ==='performanceDashboard'){
            $('#performanceDashboardViewer').show();
            $('#actionDashboardViewer').hide();
            $('#myTeamViewer').hide();
        }
        else if(viewId ==='myTeam'){
            $('#myTeamViewer').show();
            $('#actionDashboardViewer').hide();
            $('#performanceDashboardViewer').hide();
            // $.ajax({
            //     url: Routes.my_team_overseers_dashboard_path({format: "html"}),
            //     type: "GET",
            //     success: function (data) {
            //         debugger
            //         $('#myTeamViewer')[0].innerHTML = data.html;
            //         $('#myTeamViewer').show();
            //     }
            // });
        }
    }
    $(".bmro-sales-actions").click(function (event) {
        console.log(event);
        let viewId=$(this).attr('id')
        tabActivator(viewId);
    });
}
export default salesNavigationPanel;
