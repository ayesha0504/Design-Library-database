#part c
create database pro;
use pro;
create table person(
person_id int not null,
first_name varchar(10) not null,
middle_name varchar(10),
last_name varchar(10) not null,
city varchar(10),
dob date,
age int,
apt_no int,
street varchar(20),
zip_code int,
primary key(person_id));
create table employee(
person_id int,
start_date date,
emp_id int not null,
primary key(emp_id),
foreign key(person_id) references person(person_id));
create table phone(
phone_no int not null,
person_id int,
primary key(phone_no),
foreign key(person_id) references person(person_id));
create table card(
card_id int not null,
date_of_issue date,
membership_level varchar(10),
person_id int,
primary key(card_id),
foreign key(person_id) references person(person_id));
create table promotional_discount(
p_id int not null,
card_id int,
description varchar(30),
primary key(p_id),
foreign key(card_id) references card(card_id));
create table member(
person_id int,
mem_id int not null primary key,
foreign key(person_id) references person(person_id));
create table gold(
mem_id int,
foreign key(mem_id) references member(mem_id));
create table silver(
mem_id int,
foreign key(mem_id) references member(mem_id));
create table guest_log(
guest_id int not null,
name varchar(20),
mem_id int,
contact int not null,
primary key(guest_id),
foreign key(mem_id) references member(mem_id));
create table trainer(
trainer_id int not null primary key);
create table library_supervisor(
emp_id int not null,
trainer_id int not null,
foreign key(emp_id) references employee(emp_id),
foreign key(trainer_id) references trainer(trainer_id));
create table catalog_manager(
emp_id int not null,
trainer_id int not null,
foreign key(emp_id) references employee(emp_id),
foreign key(trainer_id) references trainer(trainer_id));
create table receptionist(
emp_id int not null,
trainer_id int not null,
foreign key(emp_id) references employee(emp_id),
foreign key(trainer_id) references trainer(trainer_id));
create table borrowing_details(
borrow_id int not null,
emp_id int not null,
date_of_issue date,
date_of_return date,
primary key(borrow_id),
foreign key(emp_id) references employee(emp_id));
create table payment_details(
payment_id int not null,
time_of_payment time,
amount int,
borrow_id int not null,
foreign key(borrow_id) references borrowing_details(borrow_id));
create table method(
payment_id int,
payment_method varchar(20) primary key,
foreign key(payment_id) references payment_details(payment_id));
create table publisher(
pub_id int not null primary key,
pub_name varchar(15));
create table book(
book_id int not null primary key,
book_title varchar(30),
pub_id int not null,
foreign key(pub_id) references publisher(pub_id));
create table author(
author_id int not null primary key,
author_name varchar(20),
book_id int not null,
foreign key(book_id) references book(book_id));
create table comments(
person_id int not null,
book_id int not null,
comment_no int not null primary key,
foreign key(person_id) references person(person_id),
foreign key(book_id) references book(book_id));
create table category(
book_id int not null,
category_type varchar(15),
foreign key(book_id) references book(book_id));
create table maintains(
emp_id int not null,
person_id int not null,
book_id int not null,
borrow_id int not null,
foreign key(borrow_id) references borrowing_details(borrow_id),
foreign key(emp_id) references employee(emp_id),
foreign key(person_id) references person(person_id),
foreign key(book_id) references book(book_id));

#part-d-1
create view topgoldmember as
select p.person_id,p.first_name, p.last_name, b.date_of_issue as date_of_enrollment
from person p, borrowing_details b, card c, maintains m
where p.person_id=c.person_id and p.person_id=m.person_id and
m.borrow_id=b.borrow_id and b.date_of_issue>date(current_date()
-interval 1 month)
group by p.person_id
having count(book_id)=2; # change to 5 while submitting

#part d-2
create view popularbooks as
select b.book_title, b.book_id
from book b, borrowing_details d, maintains m
where b.book_id=m.book_id and m.borrow_id=d.borrow_id and 
d.date_of_issue>date(current_date-interval 1 year)
group by b.book_id
order by count(b.book_id) desc;

#part d-3
create view bestratingpublisher as
select pub_name, avg(rating_score)
from publisher p, comments c, book b
where b.book_id=c.book_id and b.pub_id=p.pub_id
group by b.pub_id
having avg(rating_score)>=4
order by avg(rating_score) desc;

#part d-4
create view potentialgoldmember as
select p.first_name,p.last_name,ph.phone_no,p.person_id
from person p, phone ph, card c
where c.person_id=p.person_id and ph.person_id=p.person_id and 
c.membership_level='silver' and
p.person_id in
(select m.person_id
from maintains m, borrowing_details b
where m.borrow_id=b.borrow_id and p.person_id=m.person_id and
b.date_of_issue>date(current_date - interval 1 year)
group by m.person_id
having count(distinct month(b.date_of_issue))=12);

#part d-5
create view popularauthor as
select a.author_id, a.author_name, count(m.book_id)
from author a, borrowing_details b, maintains m
where a.book_id=m.book_id and b.borrow_id=m.borrow_id
group by m.book_id
order by count(m.book_id) desc;

#part e-2
select p.first_name, p.last_name, s.book_id
from person p, maintains s, borrowing_details b
where p.person_id in (
select e.person_id
from mem_card m, employee e
where m.person_id=e.person_id) and p.person_id=s.person_id and 
b.borrow_id=s.borrow_id and b.date_of_issue>
date(current_date - interval 1 month);

#part e-3
select avg(t.num), t.person_id
from (select count(m.book_id) as num, p.person_id
from potentialgoldmember p, maintains m
where m.person_id=p.person_id
group by m.person_id) as t
limit 5;

#part e-4
select p.pub_name, b.book_title
from popularbooks b, publisher p, book k
where k.pub_id=p.pub_id and b.book_id=k.book_id;

#part e-5
select b.book_title
from book b 
where b.book_id not in(
select m.book_id
from maintains m, borrowing_details d
where d.borrow_id=m.borrow_id and m.book_id=b.book_id and 
d.date_of_issue >= date(current_date - interval 5 month));

#part e-6
select m.person_id
from maintains m, (select count(p.author_id) as bookcount,
 p.author_id
from popularauthor p
group by p.author_id) as t,
(select count(w.book_id) as bookcount , w.author_id, w.book_id
from wrote w
group by w.author_id) as y
where t.bookcount=y.bookcount and t.author_id=y.author_id and 
y.book_id=m.book_id
group by person_id;

#part e-13
select p.person_id, p.first_name, p.last_name
from person p





