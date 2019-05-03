// Makes sure that the custom file inputs have the highlighted border on file selection
const tableHighlightWholly = () => {
    $('table[data-toggle="wholly"]').wholly({
        highlightHorizontal: 'bg-highlight-success',
        highlightVertical: 'bg-highlight-success'
    });
};

export default tableHighlightWholly