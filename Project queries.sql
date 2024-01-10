-- 1) Most used health care service

select code, health_service_type, (public + private + urban + rural) as total_cases_reported from
(select code, section as health_service_type, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
group by section, code) a 
order by total_cases_reported desc
limit 1;

-- 2) Least used health care service

select code, health_service_type, (public + private + urban + rural) as total_cases_reported from
(select code, section as health_service_type, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
group by section, code) a 
order by total_cases_reported asc
limit 1;

-- 3) Top 5 Health Services 

select code, health_service_type, (public + private + urban + rural) as total_cases_reported from
(select code, section as health_service_type, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
group by section, code) a 
order by total_cases_reported desc
limit 5;

-- 4) Child immunisation coverage in every sub district of Koraput

select sub_district, (public + private + urban + rural) as total from
(select sub_district, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
where section = 'CHILD IMMUNISATION'
group by sub_district) a 
order by total desc;

-- 5) Top 3 sub districts where maximum child immunisation took place

select sub_district, (public + private + urban + rural) as total from
(select sub_district, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
where section = 'CHILD IMMUNISATION'
group by sub_district) a 
order by total desc
limit 3;

-- 6) Ratio of child immunization in rural and urban areas

select rural / urban as ratio from 
(select section, sum(rural) as rural, sum(urban) as urban
from koraput_dataset
where section = 'CHILD IMMUNISATION'
group by section) a; 


-- 7) Total girls registered in AFHC

with cte as 
(select sum(public) as public_HF, sum(private) as private_HC, sum(rural) as rural_HC, sum(urban) as urban_HC
from koraput_dataset
where section = 'Adolescent Health' and indicator_name = 'Girls registered in AFHC')

select (public_HF + private_HC + rural_HC + urban_HC) as total_girls_registered
from cte;

-- Girls who received clinical services 

with cte as 
(select sum(public) as public_HF, sum(private) as private_HC, sum(rural) as rural_HC, sum(urban) as urban_HC
from koraput_dataset
where section = 'Adolescent Health' and indicator_name = 'Out of registered, Girls received clinical services')

select (public_HF + private_HC + rural_HC + urban_HC) as total_clinical_services
from cte;

-- Girls who received councelling 

with cte as 
(select sum(public) as public_HF, sum(private) as private_HC, sum(rural) as rural_HC, sum(urban) as urban_HC
from koraput_dataset
where section = 'Adolescent Health' and indicator_name = 'Out of registered, Girls received counselling')

select (public_HF + private_HC + rural_HC + urban_HC) as total_counselling
from cte;

-- Total Boys registered in AFHC 

with cte as 
(select sum(public) as public_HF, sum(private) as private_HC, sum(rural) as rural_HC, sum(urban) as urban_HC
from koraput_dataset
where section = 'Adolescent Health' and indicator_name = 'Boys registered in AFHC')

select (public_HF + private_HC + rural_HC + urban_HC) as total_boys_registered
from cte;

-- Boys who received clinical services 

with cte as 
(select sum(public) as public_HF, sum(private) as private_HC, sum(rural) as rural_HC, sum(urban) as urban_HC
from koraput_dataset
where section = 'Adolescent Health' and indicator_name = 'Out of registered, Boys received clinical services')

select (public_HF + private_HC + rural_HC + urban_HC) as total_clinical_services
from cte;

-- Boys who received councelling 

with cte as 
(select sum(public) as public_HF, sum(private) as private_HC, sum(rural) as rural_HC, sum(urban) as urban_HC
from koraput_dataset
where section = 'Adolescent Health' and indicator_name = 'Out of registered, Boys received counselling')

select (public_HF + private_HC + rural_HC + urban_HC) as total_counselling
from cte;

-- What % of girls registered in AFHC belonged to Rural areas

with cte as 
(select *, (public + private + rural + urban) as total_girls_registered from 
(select sum(public) as public, sum(private) as private, sum(rural) as rural, sum(urban) as urban
from koraput_dataset
where section = 'Adolescent Health' and indicator_name = 'Girls registered in AFHC') a)

select 100 * (rural/total_girls_registered) as rural_girls_perc from cte;

-- 8) Total cases in Health Care Facilities (HCF) (Classified) 

select sum(public) as public_HF, sum(private) as private_HC, sum(rural) as rural_HC, sum(urban) as urban_HC
from koraput_dataset;

-- 9) 2 services people go to private HF for

with cte as 
(select * from 
(select *, dense_rank() over (order by sum desc) as rn from
(select code, sum(private)
from koraput_dataset
group by code
order by sum desc) a) b 
where rn <= 2) 

,cte1 as 
(
select code, section
from koraput_dataset
group by code, section
)

select cte.code, cte.sum, cte.rn, cte1.section
from cte 
join cte1 on cte.code = cte1.code
order by rn asc;

-- 10) Ante Natal Care vs Post Natal Care Ratio

with ANC as 
(select public + private + urban + rural as total_ANC_services, 5 as common from
(select sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
where section = 'Ante Natal Care (ANC)') a) 
, PNC as 
(select public + private + urban + rural as total_PNC_services, 5 as common from
(select sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
where section = 'Post Natal Care (PNC)') b) 

select total_ANC_services/ total_PNC_services  as ratio 
from ANC
join PNC on ANC.common = PNC.common;

-- 11) No of Anganwadi centres that conducted Village Health and Nutrition day (Classified by Health Care Facility)

select indicator_name, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
where section = 'Patient Services' and indicator_name = 'Number of Anganwadi centres/ UPHCs reported to have conducted Village Health & Nutrition Day (VHNDs)/ Urban Health & Nutrition Day (UHNDs)/ Outreach / Special Outreach'
group by indicator_name;

-- 12) Total Lab Testing done 

select section, public + private + urban + rural as total_lab_tests from 
(select section, indicator_name, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
where section = 'Laboratory Testing' and indicator_name = 'Number of Lab Tests done'
group by section, indicator_name) a ;

-- 13) No of Childhood diseases reported 

select (public + private + urban + rural) as total_cases from
(select section, sum(public) as public, sum(private) as private, sum(urban) as urban, sum(rural) as rural
from koraput_dataset
where section = 'Number of cases of Childhood Diseases (0-5 years)'
group by section) a;

-- 14) Ratio of inpatient to outpatient 

with outpatient_data as 
(select sum(public) + sum(private) + sum(rural) + sum(urban) as total_outpatient, 5 as common from 
(select * from koraput_dataset
where section = 'Patient Services' and indicator_name like 'Outpatient%')a)

,inpatient_data as 
(
select sum(public) + sum(private) + sum(rural) + sum(urban) as total_inpatient, 5 as common from 
(select * from koraput_dataset
where section = 'Patient Services' and indicator_name like 'Inpatient%') b
)
select (total_inpatient / total_outpatient) from outpatient_data od join inpatient_data id on od.common = id.common;

-- 15) Total mental health cases 

select sum(public) + sum(private) + sum(rural) + sum(urban) as total_mental_health_cases
from koraput_dataset
where indicator_name in ('Outpatient - Mental illness' , 'Inpatient - Mental illness');

-- 16) Which sub district recorded the highest mental health cases

select sub_district, sum(public) + sum(private) + sum(rural) + sum(urban) as mental_health_cases
from koraput_dataset
where indicator_name in ('Outpatient - Mental illness' , 'Inpatient - Mental illness')
group by sub_district
order by mental_health_cases desc
limit 1;