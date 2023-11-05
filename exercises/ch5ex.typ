= Exercice 1

$ pi_("ssn", "fname", "lname", "address")(sigma_("departement"="'recherche'")("employee")) $

= Exercice 2

$ 
  pi_("pnumber", "dnumber", "lname", "address", "bdate")(\
    sigma_("project.location"="'Stafford'" and "project.dnum"="department.dnumber" and "department.mgr_ssn"="'employee.ssn'") (\
      "project" times "department" times "employee"
    )
  )
$

= Exercice 3

$
  pi_("ssn", "fname")(\
    sigma_("dno"=5)("employee")
    div pi_("ssn", "pnumber")(
      sigma_("dnumber"=5)
    )
  )
$

