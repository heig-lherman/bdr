-- region: company schema
create schema if not exists company;
-- endregion: company schema

-- region: company tables
create table company.employee
(
    fname     varchar(15) not null,
    minit     char(1),
    lname     varchar(15) not null,
    ssn       char(9)     not null,
    bdate     date,
    address   varchar(30),
    sex       char(1),
    salary    decimal(10, 2),
    super_ssn char(9),
    dno       integer     not null,
    primary key (ssn)
);

create table company.department
(
    dname          varchar(15) not null,
    dnumber        integer     not null,
    mgr_ssn        char(9),
    mgr_start_date date,
    primary key (dnumber)
);

create table company.dept_locations
(
    dnumber   integer not null,
    dlocation integer not null,
    primary key (dnumber, dlocation)
);

create table company.project
(
    pname     varchar(15) not null,
    pnumber   integer     not null,
    plocation integer,
    dnum      integer     not null,
    primary key (pnumber)
);

create table company.works_on
(
    essn  char(9)       not null,
    pno   integer       not null,
    hours decimal(3, 1) not null,
    primary key (essn, pno)
);

create table company.dependent
(
    essn           char(9)     not null,
    dependent_name varchar(15) not null,
    sex            char(1),
    bdate          date,
    relationship   varchar(8),
    primary key (essn, dependent_name)
);

create table company.location
(
    lnumber integer     not null,
    lname   varchar(15) not null,
    primary key (lnumber)
);
-- endregion: company tables

-- region: data insert on works_on
insert into company.works_on (essn, pno, hours)
values ('123456789', 3, 10),
       ('123456789', 4, 10),
       ('123456789', 5, 10);
-- > there is no project with number 3 and 4

delete
from company.department
where dnumber = 5;
-- > deletes the project that is linked to a works_on tuple
-- endregion: data insert on works_on

-- region: clear tables
truncate table company.department;
truncate table company.dependent;
truncate table company.dept_locations;
truncate table company.employee;
truncate table company.location;
truncate table company.project;
truncate table company.works_on;
-- endregion: clear tables

-- region: add foreign keys
alter table company.dept_locations
    add foreign key (dnumber) references company.department (dnumber);
alter table company.dept_locations
    add foreign key (dlocation) references company.location (lnumber);
alter table company.department
    add foreign key (mgr_ssn) references company.employee (ssn);
alter table company.employee
    add foreign key (dno) references company.department (dnumber);
alter table company.employee
    add foreign key (super_ssn) references company.employee (ssn);
alter table company.dependent
    add foreign key (essn) references company.employee (ssn);
alter table company.works_on
    add foreign key (essn) references company.employee (ssn);
alter table company.works_on
    add foreign key (pno) references company.project (pnumber);
alter table company.project
    add foreign key (dnum) references company.department (dnumber);
alter table company.project
    add foreign key (plocation) references company.location (lnumber);
-- endregion: add foreign keys

-- region: triggers to insert data
alter table company.department
    disable trigger all;
alter table company.dependent
    disable trigger all;
alter table company.dept_locations
    disable trigger all;
alter table company.employee
    disable trigger all;
alter table company.location
    disable trigger all;
alter table company.project
    disable trigger all;
alter table company.works_on
    disable trigger all;

alter table company.department
    enable trigger all;
alter table company.dependent
    enable trigger all;
alter table company.dept_locations
    enable trigger all;
alter table company.employee
    enable trigger all;
alter table company.location
    enable trigger all;
alter table company.project
    enable trigger all;
alter table company.works_on
    enable trigger all;
-- endregion: triggers to insert data

-- region: insertion département "IT" dnumber = 10
with employee as (
    insert into company.employee (fname, lname, ssn, dno)
        values ('Steve', 'Jobs', '555444333', 10)
        returning ssn)
insert
into company.department (dname, dnumber, mgr_ssn, mgr_start_date)
values ('IT', 10, (select ssn from employee), now());
-- endregion: insertion département "IT" dnumber = 10

-- region: various updates
update company.employee
set dno = 7
where ssn = '999887777';
--
delete
from company.employee
where ssn = '999887777';
--
insert into company.works_on (essn, pno, hours)
values ('123456789', 3, 10),
       ('123456789', 4, 10),
       ('123456789', 5, 10);
--
delete
from company.department
where dnumber = 5;
-- endregion: various updates

-- region: attempts on deletion
delete from company.employee
where ssn = '987654321';
alter table company.employee
    drop constraint employee_super_ssn_fkey;
alter table company.employee
    add foreign key (super_ssn) references company.employee (ssn)
    on delete set null;
--
update company.department
set dnumber = 7
where dnumber = 4;
alter table company.employee
    drop constraint employee_dno_fkey;
alter table company.employee
    add foreign key (dno) references company.department (dnumber)
    on update cascade;
-- endregion: attempts on deletion
