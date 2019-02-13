import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import onLoadPage from "../common/onLoadPage";

const index = () => {
    bindSummaryBox(".summary_box", '.status-filter');
    updateSummaryBox()
};

export default index