SELECT handle.id, message.text 
	FROM message INNER JOIN handle 
		ON message.handle_id = handle.ROWID 
	WHERE is_from_me=0 AND 
	datetime(message.date/1000000000 + strftime("%s", "2001-01-01") ,"unixepoch","localtime") >= datetime('now','-20 seconds', 'localtime');