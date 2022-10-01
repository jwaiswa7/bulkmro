import reportsquarterlyPurchaseData from "./quarterlyPurchaseData";
import reportsmonthlyPurchaseData from "./monthlyPurchaseData";
import reportsrevenueTrend from "./revenueTrend";
import reportscategorywiseRevenue from "./categorywiseRevenue";
import reportsmonthlySalesReport from "./monthlySalesReport";

let reports = {
    quarterlyPurchaseData: reportsquarterlyPurchaseData,
    monthlyPurchaseData: reportsmonthlyPurchaseData,
    revenueTrend: reportsrevenueTrend,
    categorywiseRevenue: reportscategorywiseRevenue,
    show: reportsmonthlySalesReport
};

export default reports
