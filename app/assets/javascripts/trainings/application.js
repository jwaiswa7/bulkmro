let filterInput = document.getElementById('SearchInput');
filterInput.addEventListener('keyup', filterTitles);

function filterTitles(event) {
    let searched = event.target.value.toLowerCase();
    let listElement = document.getElementById('search-results');
    let searchCard = document.getElementById('search-results');
    if (searched.length > 3) {
        $.ajax({
            type: "GET",
            url: `/trainings/search?search=${searched}`,
            dataType: "json",
            success: function(data) {
                listElement.innerHTML = '';
                if (data.length == 0) {
                    var item = document.createElement('li');
                    item.appendChild(document.createTextNode('No results found!'));
                    listElement.appendChild(item);
                } else {
                    data.forEach(training => {
                        // create the link
                        var a = document.createElement('a');
                        a.href = `/trainings/${training.slug}`
                        // Create the list item
                        var item = document.createElement('li');
                        // Highlight the category
                        var category = document.createElement('strong');
                        category.appendChild(document.createTextNode(`${training.category} | `));
                        item.appendChild(category);

                        // Add the titile text
                        item.appendChild(document.createTextNode(training.title));

                        a.appendChild(item);
                        // add to the ul list
                        listElement.appendChild(a);
                    });
                }
                searchCard.classList.remove('d-none');
            }
        });
    } else {
        searchCard.classList.add('d-none');
    }
}