import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";
import aggregateSummaryBox from "./index";

const notInvoiced = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    aggregateSummaryBox()
};

export default notInvoiced