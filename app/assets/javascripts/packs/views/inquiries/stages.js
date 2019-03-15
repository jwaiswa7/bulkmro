import treant from "../../components/treant";

const stages = () => {
    let url = $('.treant').data('nodes');

    $.get(url, function (response) {
        if (response['data'] != undefined) {
            let nodeStructure = response['data'];
            treant(nodeStructure);
        }
    })
};

export default stages