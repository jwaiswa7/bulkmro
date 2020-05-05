import getInquiryTasks from "./getInquiryTasks";
import getStatusRecords from "./getStatusRecords";
import myteamDropdown from '../common/myteamDropdown';

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
            let myTeamDiv = $('#myTeamViewer');
            let loader=`<div class="sales-loader"><div class="sprint-loader-wrapper"><i class="sprint-loader"></i></div></div>`;
            $.ajax({
                url: Routes.my_team_overseers_dashboard_path({format: "html"}),
                type: "GET",
                beforeSend: function () {
                    myTeamDiv.empty();
                    myTeamDiv.append(loader);
                    $('.sales-loader').show();
                    myTeamDiv.show();
                    $('#actionDashboardViewer').hide();
                    $('#performanceDashboardViewer').hide();
                },
                success: function (data) {
                    myTeamDiv.empty();
                    myTeamDiv[0].innerHTML = data.html;
                    myTeamDiv.show();
                    myteamDropdown();
                },
                complete: function () {
                    $('.sales-loader').hide();
                }
            });
        }
    }
    $(".bmro-sales-actions").click(function (event) {
        console.log(event);
        let viewId=$(this).attr('id')
        tabActivator(viewId);
    });
}
export default salesNavigationPanel;
