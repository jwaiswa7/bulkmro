import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import commanComment from "../common/commanComment";

const index = () => {
        bindSummaryBox(".summary_box", '.status-filter')
        updateSummaryBox()
        commanComment('outward-dispatch','outward_dispatches');
}

export default index