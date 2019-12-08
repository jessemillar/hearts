var database = (function() {
  var json = null;
  $.ajax({
    'async': false,
    'global': false,
    'url': "decks.json",
    'dataType': "json",
    'success': function(data) {
      json = data;
    }
  });
  return json;
})();

$('#txt-search').keyup(function(){
	console.log(database[0].name);

            var searchField = $(this).val();
			if(searchField === '')  {
				$('#filter-records').html('');
				return;
			}

            var regex = new RegExp(searchField, "i");
            var output = '<div class="row">';
            var count = 1;
			  $.each(database, function(key, val){
				if ((val.name.search(regex) != -1) || (val.description.search(regex) != -1)) {
				  output += '<div class="col-md-6 well">';
				  output += '<div class="col-md-3"><img class="img-responsive" src="'+val.image+'" alt="'+ val.name +'" /></div>';
				  output += '<div class="col-md-7">';
				  output += '<h5>' + val.name + '</h5>';
				  output += '<p>' + val.description + '</p>'
				  output += '<p>' + val.owned + '</p>'
				  output += '</div>';
				  output += '</div>';
				  if(count%2 == 0){
					output += '</div><div class="row">'
				  }
				  count++;
				}
			  });
			  output += '</div>';
			  $('#filter-records').html(output);
});
