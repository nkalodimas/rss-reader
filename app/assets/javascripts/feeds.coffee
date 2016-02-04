# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
@mark_as_read = (feed_id, entry_id) ->
	entryRow = $("#entry#{entry_id}")
	if entryRow.hasClass('unread') == true
		$.ajax "/feeds/#{feed_id}/entries/#{entry_id}/read",
			type: 'POST'
			data: { read: true }
			error: (jqXHR, textStatus, errorThrown) ->
				console.log("AJAX Error: #{textStatus}")
			success: (data, textStatus, jqXHR) ->
				entryRow.removeClass("unread info")
				entryRow.find(".entryLink").first().removeAttr('onclick')
				unreadCount = parseInt($("#unreadCount").text(), 10)
				$("#unreadCount").text(--unreadCount)
	else
		console.log("mark_as_read was not unbound")