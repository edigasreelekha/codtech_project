-- 1. List all photos and the usernames of their respective owners.
select 
	users.id,
	image_url,username 
from photos
left join users 
on photos.user_id = users.id;

-- 2. Find all comments, the text of the comment, the username of the commenter, and the URL of the photo the comment belongs to.
select 
	comment_text as comment,
    username as name,
    image_url as image  
from comments
left join users 
	on comments.user_id = users.id
join photos 
	on comments.photo_id = photos.user_id; 

-- 3. Show all photos that have been liked, along with the username of the user who liked them.
select photo_id,
	username
from likes
join photos 
	on likes.photo_id = photos.id
join users 
	on likes.user_id = users.id;

-- 4.  Retrieve a list of users and the number of photos they have posted. Include users who haven't posted any photos (display 0 for them).
select 
	users.id,
	username,
	count(photos.id) as photos_likes 
from photos
left join users 
	on photos.user_id = users.id
group by users.id,username
order by photos_likes desc ;
 
 -- 5. Find all photos that have at least one comment, displaying the photo URL and the number of comments.
select 
image_url,
	count(comments.id) as comment_count
from comments 
right join photos 
	on comments.photo_id = photos.id
group by image_url
order by comment_count desc; 

-- 6. List all users who have liked their own photo.
select 
	username,count(*) as self_likes 
from users
join photos 
	on users.id = photos.user_id 
join likes 
	on photos.id = likes.photo_id
where 
	users.id = likes.user_id
group by username
order by self_likes desc;

-- 7. Identify all users who have never posted a photo.
select
	username
from users
join photos 
	on users.id = photos.user_id
join likes 
	on photos.id = likes.photo_id
where
users.id = likes.user_id;

-- 8. Identify all users who have never posted a photo.
select
	username
from users
left join photos
	on users.id = photos.user_id
where 
photos.id is null;

-- 9. Find the usernames of users who follow more than 5 other users.
select username
from users
join follows
	on users.id = follows.follower_id
group by users.id,username
having
count(follower_id) > 5;

-- 10. List all photos that have been tagged with 'nature' (assuming 'sunset' exists as a tag_name). Show the photo URL.
select 
	image_url,
    tag_name
from photos
join photo_tags
	on  photos.id = photo_tags.photo_id
join tags
		on photo_tags.tag_id = tags.id
where
tag_name = 'sunset';

-- 11 Find users who have commented on photos but have not posted any photos themselves.
select distinct
	comments.user_id,
	username
from comments
join users
	on comments.user_id = users.id
join photos
	on comments.photo_id = photos.id
    where comments.user_id not in(
    select distinct user_id from photos);


