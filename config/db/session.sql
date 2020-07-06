

-- Delete a BC

select * from barcode bc where bc.status = 2

select * from wk_tag wt where wt.current_step_id = 2;

select * from wk_tag_com wtc where wtc.wk_tag_id IN (
	select id from wk_tag wt where wt.current_step_id = 2
);
