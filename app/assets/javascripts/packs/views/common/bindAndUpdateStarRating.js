const bindAndUpdateStarRating = () => {
    let reviewQuestionsLength = $(".star").length
    for (let i = 0; i < reviewQuestionsLength; i++) {
        let starRating = ".star-"+i
        $(starRating).raty({scoreName: "review-score-"+i,click:function (score) {
                $(".rating-"+i).val(score)
            }});
    }
}

export default bindAndUpdateStarRating