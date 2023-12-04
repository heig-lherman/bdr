-- ex6p4p3
-- Renvoyer les informations complètes sur les employés
-- du/des département(s) dont le salaire total des employés
-- est le maximum parmi tous les départements.

-- Solution perso (cost 48)
select * from company.employee
where dno in (
    select dno
    from company.employee
    group by dno
    having sum(salary) = (
        select max(sum_salary) from (
            select sum(salary) as sum_salary
            from company.employee
            group by dno
        ) as max_salary
    )
);

-- Solution proposée (cost 445)
select * from company.employee
where dno in (
    select dno
    from company.employee
    group by dno
    having sum(salary) >= all (
        select sum(salary)
        from company.employee
        group by dno
    )
);

-- ex6p4p15
-- En se basant sur l’analyse précédente, écrire une requête
-- récursive qui renvoie tous les subordonnés (directs et
-- indirects) du manager avec l’identifiant 2

with recursive subordinates as (
    select employee_id, manager_id, full_name
    from employees
    where manager_id = 2
    union (
        select e.employee_id, e.manager_id, e.full_name
        from employees e
            inner join subordinates s
            on e.manager_id = s.employee_id
    )
)
select *
from subordinates;

-- ex6p4p36
-- Réecrire la requête suivante afin d’inclure dans le
-- résultat les départements avec au moins 3 employés qui
-- n’ont aucun employé avec un salaire supérieur à 40’000
-- (afficher 0 pour le comptage correspondant).

/*
SELECT dno,
       count(*) as
           countBigSalary
FROM employee
WHERE salary > 40000
  and dno IN
      (SELECT dno
       FROM employee
       GROUP BY dno
       HAVING count(*) >=
              3)
GROUP BY dno;
*/

select dno, count(case when salary > 40000 then 1 end)
from company.employee
where dno in (select dno
              from company.employee
              group by dno
              having count(*) >= 3)
group by dno;
