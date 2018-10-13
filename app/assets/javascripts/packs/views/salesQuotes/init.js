import salesQuotesCreate from "./create";
import salesQuotesEdit from "./edit";
import salesQuotesNew from "./new";
import salesQuotesNewRevision from "./newRevision";
import salesQuotesUpdate from "./update";

let salesQuotes = {
    create: salesQuotesCreate,
    edit: salesQuotesEdit,
    new: salesQuotesNew,
    newRevision: salesQuotesNewRevision,
    update: salesQuotesUpdate
}

export default salesQuotes