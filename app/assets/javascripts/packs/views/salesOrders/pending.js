import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
const pending = () => {
    bindSummaryBox(".summary_box",'.status-filter')
    updateSummaryBox()
};

export default pending