// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

function markdown_preview(url, inputsel, outputsel, showsel, tabsel) {
	$(outputsel).html("Rendering...");
	$(showsel).show('fast');
	$(tabsel).tab('show');
	$.ajax({
		type: 'POST',
		url: url,
		data: { text: $(inputsel).val() },
		dataType: 'json',
		success: function(data) {
			$(outputsel).html('<div class="well well-small">' + data.result + '</div>');
		},
		error: function(xhr, status) {
			$(outputsel).html("<b>Error: </b>" + status);
		}
	});
}
