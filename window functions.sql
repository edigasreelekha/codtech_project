-- windows Functions:
-- 1. For each user, find their photos and assign a sequential number to each photo based on its created_at date (oldest first).
select 
	users.username,
    p.user_id,
    p.created_at,
    p.image_url,
row_number() over(partition by p.user_id order by p.created_at) as photo_seq_num
from 
	photos as p
join users
	on p.user_id = users.id;

-- 2.Rank photos by the total number of likes they received, showing the photo URL and its rank.
with photolikes as (
select
	photos.id as photo_id,
    photos.image_url,
    count(likes.user_id) as likedphotos
from photos
left join likes
	on photos.id = likes.photo_id
group by 
	photos.id,photos.image_url
    )
select image_url,likedphotos,
	dense_rank() over(order by likedphotos desc) as like_ranks
from photolikes;

-- 3.For each photo, display the photo URL, its created_at timestamp, and the created_at timestamp of the previous comment on that photo (if any).
select p.id,p.image_url,p.created_at, c.created_at,
lag(c.created_at) over (partition by p.id order by c.created_at) as pre_created_cmnt
from photos as p 
left join comments as c
	on p.id = c.photo_id
order by
	p.id,c.created_at;

-- 4.Calculate a running total of likes for each user's photos, ordered by created_at date of the photos.

with photolikescount as (
select  
	p.user_id,
	p.id as photo_id,
	p.image_url,
	p.created_at as photo_created_at,
    count(likes.user_id) as likes_on_photo
from photos as p
left join likes
	on p.id = likes.photo_id
group by 
	p.user_id,p.id,p.image_url,p.created_at
)
select 
plc.user_id,
u.username,
plc.image_url,
plc.photo_created_at,
plc.likes_on_photo,
sum(plc.likes_on_photo) over (partition by plc.user_id order by plc.photo_created_at) as running_likes
from photolikescount as plc
join users as u
	on plc.user_id = u.id
order by
	plc.user_id,plc.photo_created_at;
    
-- 5. For each user, find their 3 most recent photos.
select * from photos;
with ranked_photos as (
select 
	p.user_id,
    users.username,
    p.image_url,
    p.created_at,
    row_number () over (partition by p.user_id order by p.created_at) as rn
from  photos as p
left join users 
	on p.user_id = users.id
    )
select user_id,
	username,
	image_url,
	created_at
from ranked_photos
where rn <=  3;

-- 6. Divide all users into 4 groups based on the number of photos they have posted.
with user_photo_count as (
select 
	users.id as user_id,
	username,
    count(photos.id) as photo_count
from users
left join photos
	on users.id = photos.user_id
group by 
	users.id,username
)
select
	user_id,
    username,
    photo_count,
    ntile(4) over(order by photo_count) as group_photos
from user_photo_count
order by 
    photo_count,group_photos desc;
    
-- 7. Find the average number of comments per photo for each user.
with avg_comnt_cnt as (
select photos.id as photo_id,
	photos.user_id,
    count(comments.id) as num_counts
from photos
left join comments 
	on photos.id = comments.photo_id
group by 
	photos.id,photos.user_id
)
select pcc.user_id,users.username,
round(avg(pcc.num_counts),2) as avg_per_photo
from avg_comnt_cnt  as pcc
join users
	on pcc.user_id = users.id
group by
	pcc.user_id,users.username
order by
	users.id;

-- 8. For each photo, show the photo URL, its created_at date, and the created_at date of the next comment on that photo by the same user who posted the photo.
select p.image_url,
	p.created_at,c.comment_text,c.created_at,
lead(c.created_at) over(partition by p.id order by c.created_at) 
as nxt_cmmt
from photos as p
left join comments as c
	on p.id = c.photo_id and p.user_id = c.user_id
order by
	 p.id,c.created_at;
	
-- 9. Identify the user with the most comments in total, and the user with the most photos in total, using window functions or common table expressions (CTEs).    
with ucc as (
select 
	users.id as user_id, 
	users.username,
    count(comments.id) as totalcmt,
rank () over (order by count(comments.id) desc) as cmt_rnk
from users 
left join comments 
	on users.id = comments.user_id
group by
	users.id, users.username
),
upc as (
select 
	users.id as user_id,
    users.username,
	count(photos.id) as pht_cnt,
rank () over (order by count(photos.id) desc) as pht_rnk
from users
left join photos
	on users.id = photos.user_id
group by
		users.id, users.username
)
select 
	ucc.username as user_with_mostcmts,
	ucc.totalcmt
from ucc
where 
	cmt_rnk = 1
union all 
select 
	upc.username as user_with_mostphts,
	upc.pht_cnt
from upc
where 
	pht_rnk = 1;

-- 10 For each user, calculate the total number of comments they have made and the total number of comments on their own photos.
SELECT
    users.id AS user_id,
    users.username,
    COUNT(DISTINCT comments.id) AS total_comments_made,
    COUNT(DISTINCT CASE WHEN photos.user_id = users.id THEN comments_own.id END) AS total_comments_on_own_photos
FROM
    users
LEFT JOIN
    comments  ON users.id = comments.user_id
LEFT JOIN
    photos ON users.id = photos.user_id 
LEFT JOIN
    comments AS comments_own ON photos.id = comments_own.photo_id AND photos.user_id = comments_own.user_id
GROUP BY
    users.id, users.username
ORDER BY
    users.username;
	


