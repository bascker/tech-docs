/* 创建数据表  */
/* person start */
create table PERSON
(
	id varchar(32) not null,
	first_name varchar(10) not null,
	last_name varchar(20) null,
	address varchar(255) null,
	city varchar(50) null
);

create unique index PERSON_id_uindex
	on PERSON (id);

alter table PERSON
	add constraint PERSON_pk
		primary key (id);
/* person end */

/* city start */
create table city
(
	id char(36) not null,
	name varchar(50) not null
);

create unique index city_id_uindex
	on city (id);

alter table city
	add constraint city_pk
		primary key (id);
/* city end */

/* 生成测试数据: UUID() 生成 32 位随机字符串(如 efec7311-bdd7-11e9-841e-7446a08a322b) */
insert into person values (REPLACE(UUID(), "-", ""), "张", "三", "滨江", "杭州");
insert into person values (REPLACE(UUID(), "-", ""), "李", "四", "下沙", "杭州");
insert into person values (REPLACE(UUID(), "-", ""), "王", "五", "滨江", "杭州");
insert into person values (REPLACE(UUID(), "-", ""), "马", "六", "上地", "北京");
insert into person values (REPLACE(UUID(), "-", ""), "马", "六", "天津港", "天津");
select * from person;

insert into city values (REPLACE(UUID(), "-", ""), "杭州");
insert into city values (REPLACE(UUID(), "-", ""), "上海");
insert into city values (REPLACE(UUID(), "-", ""), "广州");
insert into city values (REPLACE(UUID(), "-", ""), "北京");
insert into city values (REPLACE(UUID(), "-", ""), "深圳");
insert into city values (REPLACE(UUID(), "-", ""), "长沙");
insert into city values (REPLACE(UUID(), "-", ""), "武汉");
select * from city;