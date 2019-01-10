import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from "../common/updateSummaryBox";

const notInvoiced = () => {
    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
};

export default notInvoiced