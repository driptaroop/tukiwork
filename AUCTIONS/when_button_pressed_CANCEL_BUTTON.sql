begin
	CW_AUCTION_TIMEOUT;
	CW_AUCTION_LOCK;
	hide_window('CREDIT_OVERRIDE');
	--show_window('CWARCCPM');
	go_block('CWARCCPM');
end;	