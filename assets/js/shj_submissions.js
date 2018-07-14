/**
 * Sharif Judge
 * @file shj_submissions.js
 * @author Mohammad Javad Naderi <mjnaderi@gmail.com>
 *
 *     Javascript codes for "All Submissions" and "Final Submissions" pages
 */

shj.modal_open = false;
$(document).ready(function () {
	$(document).on('click', '#select_all', function (e) {
		e.preventDefault();
		$('.code-column').selectText();
	});
	$(".btn").click(function () {
		var button = $(this);
		var row = button.parents('tr');
		var type = button.data('type');
		if (type == 'download') {
			window.location = shj.site_url + 'submissions/download_file/' + row.data('u') + '/' + row.data('a') + '/' + row.data('p') + '/' + row.data('s');
			return;
		}
		var view_code_request = $.ajax({
			cache: true,
			type: 'POST',
			url: shj.site_url + 'submissions/view_code',
			data: {
				type: type,
				username: row.data('u'),
				assignment: row.data('a'),
				problem: row.data('p'),
				submit_id: row.data('s'),
				shj_csrf_token: shj.csrf_token
			},
			success: function (data) {
				if (type == 'code')
					 data.text = shj.html_encode(data.text);
				$('.modal_inside').html('<pre class="code-column">'+data.text+'</pre>');
				$('.modal_inside').prepend('<p><code>'+data.file_name+' | Submit ID: '+row.data('s')+' | Username: '+row.data('u')+' | Problem: '+row.data('p')+'</code></p>');
				if (type == 'code'){
					$('pre.code-column').snippet(data.lang, {style: shj.color_scheme});
				}
				else
					$('pre.code-column').addClass('shj_code');
			}
		});
		if (!shj.modal_open) {
			shj.modal_open = true;
			$('#shj_modal').reveal(
				{
					animationspeed: 300,
					on_close_modal: function () {
						view_code_request.abort();
					},
					on_finish_modal: function () {
						$(".modal_inside").html('<div style="text-align: center;">Loading<br><img src="'+shj.base_url+'assets/images/loading.gif"/></div>');
						shj.modal_open = false;
					}
				}
			);
		}

	});
	$(".shj_rejudge").attr('title', 'Rejudge');
	$(".shj_rejudge").click(function () {
		var row = $(this).parents('tr');
		$.ajax({
			type: 'POST',
			url: shj.site_url + 'rejudge/rejudge_single',
			data: {
				username: row.data('u'),
				assignment: row.data('a'),
				problem: row.data('p'),
				submit_id: row.data('s'),
				shj_csrf_token: shj.csrf_token
			},
			beforeSend: shj.loading_start,
			complete: shj.loading_finish,
			error: shj.loading_error,
			success: function (response) {
				if (response.done) {
					row.children('.status').html('<div class="btn pending" data-code="0">PENDING</div>');
					noty({text: 'Rejudge in progress', layout: 'bottomRight', type: 'success', timeout: 2500});
				}
				else
					shj.loading_failed(response.message);
			}
		});
	});
	$(".set_final").click(
		function () {
			var row = $(this).parents('tr');
			var submit_id = row.data('s');
			var problem = row.data('p');
			var username = row.data('u');
			$.ajax({
				type: 'POST',
				url: shj.site_url + 'submissions/select',
				data: {
					submit_id: submit_id,
					problem: problem,
					username: username,
					shj_csrf_token: shj.csrf_token
				},
				beforeSend: shj.loading_start,
				complete: shj.loading_finish,
				error: shj.loading_error,
				success: function (response) {
					if (response.done) {
						$("tr[data-u='" + username + "'][data-p='" + problem + "'] i.set_final").removeClass('fa-check-circle-o color11').addClass('fa-circle-o');
						$("tr[data-u='" + username + "'][data-p='" + problem + "'][data-s='" + submit_id + "'] i.set_final").removeClass('fa-circle-o').addClass('fa-check-circle-o color11');
					}
					else
						shj.loading_failed(response.message);
				}
			});
		}
	);

});


$(document).ready(function(){
	function checkForPending() {
		let arr = []
		$("tr.sub-info").each(function() {
		var text = $(this).find("td.status div:first-child").text();
		if (text.trim() == 'PENDING') {
			var sub_id = $(this).attr('data-s');
			var username = $(this).attr('data-u');
			var problem = $(this).attr('data-p');
			var assignment = $(this).attr('data-a');
			arr.push([username, assignment, problem, sub_id]);
			put_position(username, assignment, problem, sub_id);
		}
		});
		return arr;
	}

	function getAjaxResponse(username, assignment, problem, sub_id){
		var request = $.ajax({
			type: 'POST',
			url: shj.site_url + 'submissions/update_row',
			data: {
				username: username,
				assignment: assignment,
				problem: problem,
				sub_id: sub_id,
				shj_csrf_token: shj.csrf_token
			},
			dataType: 'json',
			success: function(result) {
				if (result.status == 'PENDING') {

					setTimeout(() => {
						update_positions(checkForPending());
						getAjaxResponse(result.username, result.assignment, result.problem, result.submit_id);
					}, 1000);

				}
				else {
					if (result.status == 'SCORE') {
						/* Get the button, the final score, and score with jquery and
						 	change it to the ajax response */

						var final_score = Math.ceil(result.pre_score*parseInt(result.coefficient)/10000);

						var button;
						if (final_score <= 50) {
							button = $("tr[data-u='" + result.username +"'][data-a='" + result.assignment +"'][data-p='" + result.problem +"'][data-s='" + result.submit_id +"']").find("td.status").children('div.btn');
							button.addClass('shj-red');
						}

						else {
							button = $("tr[data-u='" + result.username +"'][data-a='" + result.assignment +"'][data-p='" + result.problem +"'][data-s='" + result.submit_id +"']").find("td.status").children('div.btn');
							button.addClass('shj-green');
						}

						button.text(final_score);

						var final_score_td = $("tr[data-u='" + result.username +"'][data-a='" + result.assignment +"'][data-p='" + result.problem +"'][data-s='" + result.submit_id +"']").find("td.final-score-td");
						final_score_td.text(final_score);

						var score = $("tr[data-u='" + result.username +"'][data-a='" + result.assignment +"'][data-p='" + result.problem +"'][data-s='" + result.submit_id +"']").find("td.score-td");
						score.text(result.pre_score/100);

						var position_in_queue = $("tr[data-u='" + result.username +"'][data-a='" + result.assignment +"'][data-p='" + result.problem +"'][data-s='" + result.submit_id +"']").find("td.status div:last-child").remove();

						update_positions(checkForPending());
						
						if (result.is_final == 1) {
							/* if the submission is final, unmark the previous final
								and check the new one */

							$("tr[data-u='" + result.username + "'][data-p='" + result.problem + "'] i.set_final").removeClass('fa-check-circle-o color11').addClass('fa-circle-o');

							$("tr[data-u='" + result.username + "'][data-p='" + result.problem + "'][data-s='" + result.submit_id + "'] i.set_final").removeClass('fa-circle-o').addClass('fa-check-circle-o color11');
						}

					}
					else {
						var button = $("tr[data-u='" + result.username +"'][data-a='" + result.assignment +"'][data-p='" + result.problem +"'][data-s='" + result.submit_id +"']").find("td.status").children('div.btn');
						button.addClass('shj-blue');
						button.text("Compilation Error");
						var position_in_queue = $("tr[data-u='" + result.username +"'][data-a='" + result.assignment +"'][data-p='" + result.problem +"'][data-s='" + result.submit_id +"']").find("td.status div:last-child").remove();	

					}
				}
			}
		});
	}

	function update_positions(array) {
		for(var i = 0; i < array.length; i++) {
			put_position(array[i][0],array[i][1], array[i][2], array[i][3]);
		}
	}

	function update_table(sub_array){
		for (var i = 0; i < sub_array.length; i++) {
			getAjaxResponse(sub_array[i][0], sub_array[i][1], sub_array[i][2],sub_array[i][3]);
		}
	}

	function put_position(username, assignment, problem, sub_id) {
		var request = $.ajax({
			type: 'POST',
			url: shj.site_url + 'queue/get_position_in_queue',
			data: {
				sub_id: sub_id,
				shj_csrf_token: shj.csrf_token
			},
			success: function (result) {
				if (result == '-1') {
				}
				else {
					var position = $("tr[data-u='" + username +"'][data-a='" + assignment +"'][data-p='" + problem +"'][data-s='" + sub_id +"']").find("td.status div:last-child");
					position.text("Position " + result + " in queue.");
				}
			}
		});
	}

	update_table(checkForPending());
});
