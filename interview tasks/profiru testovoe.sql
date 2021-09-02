USE test_database

--В каких командах есть вратари (‘GK’), получавшие карточки на турнире?

SELECT DISTINCT t.name
FROM players_stat p
JOIN teams t ON p.team_id = t.id
WHERE position = 'GK' AND yellow_cards >= 1
;

--Каков 90-ый перцентиль возраста игроков, сыгравших на турнире не менее 270 минут?

SELECT DISTINCT first_value(age) OVER (
ORDER BY CASE WHEN p <= 0.9 THEN p END DESC) answer
FROM (
SELECT age, percent_rank() OVER (ORDER BY age) p
FROM players_stat
) t;

--Представители какой команды чаще других получали желтые карточки во время игр?
SELECT t.name
FROM teams t
JOIN players_stat p ON p.team_id = t.id
WHERE yellow_cards = (SELECT MAX(yellow_cards) FROM teams)
;

--В каких командах голы на турнире забивали только нападающие ('AT')?
SELECT DISTINCT t.name
FROM player_stat p
JOIN teams t on p.team_id = t.id
WHERE team_id NOT IN (
SELECT DISTINCT team_id 
FROM players_stat
WHERE (position = 'GK' OR position = 'DF' OR position = 'MD') and scores >= 0
) AND scores >= 0 AND position = 'AT'
;

