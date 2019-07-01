import reportsmonthlyPurchaseData from "./monthlyPurchaseData";
import reportsrevenueTrend from "./revenueTrend";
import reportscategorywiseRevenue from "./categorywiseRevenue";
import reportsmonthlySalesReport from "./monthlySalesReport";

let reports = {
    monthlyPurchaseData: reportsmonthlyPurchaseData,
    revenueTrend: reportsrevenueTrend,
    categorywiseRevenue: reportscategorywiseRevenue,
    show: reportsmonthlySalesReport
};

export default reports