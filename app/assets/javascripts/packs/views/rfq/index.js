import bindSummaryBox from '../common/bindSummaryBox'
import updateSummaryBox from '../common/updateSummaryBox'


const index = () => {

    bindSummaryBox(".summary_box", '.status-filter')
    updateSummaryBox()
    aggregateSummaryBox()

};

export default index