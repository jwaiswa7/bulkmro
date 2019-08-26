import reportsquarterlyPurchaseData from "./quarterlyPurchaseData";
import reportsrevenueTrend from "./revenueTrend";
import reportscategorywiseRevenue from "./categorywiseRevenue";
import reportsmonthlySalesReport from "./monthlySalesReport";

let reports = {
    quarterlyPurchaseData: reportsquarterlyPurchaseData,
    revenueTrend: reportsrevenueTrend,
    categorywiseRevenue: reportscategorywiseRevenue,
    show: reportsmonthlySalesReport
};

export default reports