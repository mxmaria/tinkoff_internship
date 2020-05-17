/* Со сколькими креативными агентствами мы работаем?
Креативным агентством считается тот партнер, 
у которого нет локаций для проведения квестов,
но при этом они пишут сценарии, которые мы используем. */

   SELECT COUNT(DISTINCT p.partner_rk) 
     FROM msu_analytics.partner p 
     JOIN msu_analytics.legend leg
       ON leg.partner_rk = p.partner_rk 
LEFT JOIN msu_analytics.location loc
       ON loc.partner_rk = p.partner_rk 
    WHERE loc.location_rk IS NULL 
      AND leg.legend_rk IS NOT NULL;


/*Выведите название того партнера,
на чьих локациях под руководством девушек операторов,
среднее время прохождения квеста ниже, чем у всех остальных.
В случае неоднозначного ответа, выведите того партнера,
у которого название лексикографически меньше.*/

   SELECT p.partner_nm AVG(g.time)
     FROM msu_analytics.partner p 
LEFT JOIN msu_analytics.location loc 
       ON loc.partner_rk = p.partner_rk
LEFT JOIN msu_analytics.quest q 
       ON q.location_rk = loc.location_rk
LEFT JOIN msu_analytics.game g 
       ON g.quest_rk = q.quest_rk
LEFT JOIN msu_analytics.employee empl 
       ON empl.employee_rk = g.employee_rk
WHERE empl.gender_cd = 'f'
GROUP BY 1
ORDER BY 2, 1
LIMIT 1;

/*У какого квеста (выпишите его quest_nm) разница доли 
состоявшихся квестов в январе и в феврале наибольшая по модулю?
Долей считать количество состоявшихся квестов поделить на количество заявленных.
В случае наличия нескольких квестов, подходящих под условие,
требуется вывести тот, у которого значение quest_rk больше.*/

WITH jan_table AS (
    SELECT q.quest_rk, q.quest_nm,
           CAST(SUM(game_flg) AS float)/CAST(COUNT(*) AS float) prop
      FROM msu_analytics.quest q 
      JOIN msu_analytics.game g 
        ON g.quest_rk = q.quest_rk
     WHERE date_part('month', g.game_dttm) = 1
  GROUP BY 1, 2
), feb_table AS (
    SELECT q.quest_rk, q.quest_nm,
           CAST(SUM(game_flg) AS float)/CAST(COUNT(*) AS float) prop
      FROM msu_analytics.quest q 
      JOIN msu_analytics.game g 
        ON g.quest_rk = q.quest_rk
     WHERE date_part('month', g.game_dttm) = 2
  GROUP BY 1, 2
)

    SELECT jt.quest_rk, jt.quest_nm, abs(jt.prop - ft.prop)
      FROM jan_table jt
      JOIN feb_table ft
        ON ft.quest_nm = jt.quest_nm
  ORDER BY 3 DESC, 1 DESC
  LIMIT 1;
